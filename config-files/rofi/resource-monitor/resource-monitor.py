#!/bin/env python3

import subprocess
import sys

args = sys.argv

try:
    CHOICE = args[1].lower()        # if no argument added
    if CHOICE not in ("cpu", "mem", "swap", "comm"):
        raise
except:
    CHOICE = "cpu"

try:
    MAX_COUNT = int(args[2])        # if no 2nd argument
except:
    MAX_COUNT = -1

try:
    with open("/proc/meminfo", 'r') as meminfo:
        TOTAL_MEMORY = int(meminfo.readline().split()[1])
except:
    try:
        TOTAL_MEMORY = int(1024 * 1024 * float(input("error reading /proc/meminfo file. please input your system total memory in GB: ")))
    except:
        TOTAL_MEMORY = 0



class Process:
    def __init__(self, pid: list[int], pcpu: float, pmem: float, comm: str, swap: int = None) -> None:
        self.__pid: list[int] = pid        # list of pid with same comm
        self.__pcpu: float = pcpu
        self.__pmem: float = pmem
        self.__comm: str = comm
        # self.__swap: float = self.__getSwapUsage(pid)               # in kB           # NOTE: apparently swap usage lookups using command are quite expensive
        self.__swap: float = self.__getSwapUsageDirectly(pid)
        self.__memInBytes: int = self.__pmem * TOTAL_MEMORY / 100   # in kB


    def __str__(self) -> str:
        memInBytesWithOrder = self.__formatBytes(self.__memInBytes)
        swapInBytesWithOrder = self.__formatBytes(self.__swap)

        return f"| {round(self.__pcpu,1):>5} | {round(self.__pmem,1):>4} | {memInBytesWithOrder:>4} | {swapInBytesWithOrder:>4} | {self.__comm:<20} {str(self.__pid):<18}"


    def __formatBytes(self, kBytes: int) -> str:
        orderNames = {0: "k", 3: "M", 6: "G"}

        order = 0
        while (kBytes > 999):
            kBytes /= 1024
            order += 3

        if (order < 6):
            kBytes = int(kBytes)
        else:
            kBytes = round(kBytes, 1)

        return str(kBytes) + orderNames[order]


    # NOTE: apparently swap usage lookups using command are quite expensive
    # using UNIX command
    def __getSwapUsage(self, pid: list) -> int:
        totalSwap = 0

        for p in pid:
            swap = subprocess\
                    .run(f"grep 'VmSwap' /proc/{p}/status 2> /dev/null | tr -s ' ' | cut -d ' ' -f2", shell=True, stdout=subprocess.PIPE)\
                    .stdout\
                    .decode("utf-8")\
                    .strip()

            totalSwap += int(swap) if (swap) else 0         # add int(swap) to totalSwap if swap is not empty
        
        return totalSwap


    # read /proc/{$pid}/status file directly
    def __getSwapUsageDirectly(self, pid: list) -> int:
        totalSwap = 0

        for p in pid:
            file = f"/proc/{p}/status"

            try:
                with open(file, 'r') as procStatus:
                    line: str = procStatus.readlines()[30].strip()
                    swap = int(line.split()[1]) if line.startswith('VmSwap') else 0
                    totalSwap += swap
            
            except FileNotFoundError:
                pass

        return totalSwap


    def setPID(self, pid: list[int]):
        if (pid):
            self.__pid = pid

    def setPCPU(self, pcpu: float):
        if (pcpu):
            self.__pcpu = pcpu
        
    def setPMEM(self, pmem: float):
        if (pmem):
            self.__pmem = pmem

    def addPID(self, pid: list[int]):
        if (pid):
            self.__pid.extend(pid)
            # self.__swap += self.__getSwapUsage(pid)           # NOTE: apparently swap usage lookups using command are quite expensive
            self.__swap += self.__getSwapUsageDirectly(pid)

    def addPCPU(self, pcpu: float):
        if (pcpu):
            self.__pcpu += pcpu

    def addPMEM(self, pmem: float):
        if (pmem):
            self.__pmem += pmem
            self.__memInBytes += pmem * TOTAL_MEMORY / 100


    def getAttribute(self, type: str = None):
        if   type == "pid":  return self.__pid
        elif type == "pcpu": return self.__pcpu
        elif type == "pmem": return self.__pmem
        elif type == "comm": return self.__comm
        elif type == "swap": return self.__swap
        else:                return None



class ProcessArray:
    def __init__(self) -> None:
        self.__processArray: list[Process]  = list()
        self.__getProcesses()       # get a unique array of sorted processes by comm names


    def __getProcesses(self) -> None:
        processes = self.__processArray
        processNames = dict()       # used to keep track of unique processNames, thus used in order to filter unique processes only

        # use a command (linux command) to get processes list (outputs a string)
        command = f"ps -eo pid,pcpu,pmem,comm | tail +2 | tr -s ' '"       # the command outputs a sorted process by name (comm)
        result = subprocess\
            .run(command, shell=True, stdout=subprocess.PIPE)\
            .stdout\
            .decode("utf-8")\
            .rstrip()

        lines = result.split('\n')

        lastProcessIndex = -1        # used to keep track of last process added to the processes array
        for line in lines:
            line = line.split(maxsplit=3)

            if len(line) == 0: continue         # if there's nothing in the line, skip it

            pid = int(line[0])
            pcpu = float(line[1])
            pmem = float(line[2])
            comm = line[3].split('/')[0]        # some process have sub-processes that named something like: "parentProcess/subProcess", I take only the parentProcess name

            if (comm in processNames):
                process: Process = processes[lastProcessIndex]
                process.addPID([pid])         # add new pid to list of pids inside of process object
                process.addPCPU(pcpu)
                process.addPMEM(pmem)
            else:
                process = Process([pid], pcpu, pmem, comm)
                processes.append(process)       # add new process to the processes array
                lastProcessIndex += 1
                processNames[comm] = 1          # add new process name to the processName dict to inform that it is the first occured process


    def __sortProcessArray(self, sortBy: str = "cpu") -> None:        
        processArray = self.__processArray
        size = len(processArray)

        if   sortBy == "cpu": attrib = "pcpu"
        elif sortBy == "mem": attrib = "pmem"
        else:                 attrib = sortBy

        # bubble sort
        for i in range(size):
            swapped = False

            for j in range(size-i-1):
                left = processArray[j].getAttribute(attrib)         # get attrib value
                right = processArray[j+1].getAttribute(attrib)      # get attrib value

                if attrib == "comm":
                    right, left = left.lower(), right.lower()       # swap left-right and compare the lowercase version

                if right > left:    # compare
                    processArray[j], processArray[j+1] = processArray[j+1], processArray[j]
                    swapped = True

            if not swapped:
                break

    def getProcessArray(self):
        return self.__processArray


    def print(self, sortBy: str = "cpu", amount: int = -1) -> None:
        self.__sortProcessArray(sortBy)     # sort processArray

        processArraySize = len(self.__processArray)
        if amount < 0 or amount > processArraySize:
            amount = processArraySize
        
        for count, process in enumerate(self.__processArray[:amount]):
            print(f"{count+1:>{len(str(amount))}}", process)
            


def main() -> None:
    processes = ProcessArray()
    processes.print(CHOICE, MAX_COUNT)

    # for p in processes.getProcessArray():
    #     print(p.__str__())


if __name__ == "__main__":
    main()