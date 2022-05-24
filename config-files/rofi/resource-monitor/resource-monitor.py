#!/bin/env python3

import subprocess
import sys
import glob
import os

args = sys.argv

try:
    CHOICE = args[1].lower()        # if no argument added
    if CHOICE not in ("cpu", "mem", "swap", "comm", "pid"):
        raise
except:
    CHOICE = "cpu"

try:
    MAX_COUNT = int(args[2])        # if no 2nd argument
except:
    MAX_COUNT = -1


try:
    if args[3] == "--use-new": USE_NEW = True
    else: raise
except:
    USE_NEW = False


class Process:
    def __init__(self, pid: list[int], comm: str, mem: int = 0, pmem: float = 0, pcpu: float = 0, swap: int = 0) -> None:
        self.__pid = pid            # list of pid with same comm
        self.__comm = comm
        self.__pcpu = pcpu

        self.TOTAL_MEMORY = self.__getTotalMemory()

        # mem and pmem
        if (mem):
            self.__mem = mem                                   # in kB
            self.__pmem = 100 * mem / self.TOTAL_MEMORY if self.TOTAL_MEMORY else 0     # prevent divide by zero
        elif (pmem):
            self.__pmem = pmem
            self.__mem = self.__pmem * self.TOTAL_MEMORY / 100      # in kB
        else:
            self.__mem = 0
            self.__pmem = 0

        # swap
        if (swap):
            self.__swap = swap
        else:
            self.__swap = self.__getSwapUsage(pid)


    @classmethod
    def initFromProc(cls, procDir: str):
        if not procDir:
            return cls([-1], 0, 0, None)

        try:
            with open(f"{procDir}/stat", 'r') as procStatFile:       # read /proc/[pid]/stat file
                procStatString = procStatFile.read()
                # annoyingly, comm can contain space, and we need to take that into account
                # on the /proc/[pid]/stat file, the comm is inside a parantheses: [pid] ([comm]) [state]...
                procStat = procStatString.split(') ')[0].split(maxsplit=1)
                procStat = [procStat[0], procStat[1][1:]] + procStatString.split(') ')[1].split()

                    # (1) pid
                    # (2) comm
                    # (3) state
                    # (14) utime
                    # (15) stime
                    # (22) starttime
                    # (24) rss              # memory usage (?) i guess it's enough using this

                # print(procStat)

                pid: int = int(procStat[0])
                comm: str = procStat[1].split('/')[0]                 # "(comm)"   -->    "comm"
                                                                      # some process have sub-processes that named something like: "parentProcess/subProcess", I take only the parentProcess name
                # TODO: use a more sophisticated method of calculating memory usage
                mem: int = int(procStat[23])
                swap: int = cls.__getSwapUsage([pid])

                # calculate cpu usage
                utime = int(procStat[13])
                stime = int(procStat[14])
                starttime = int(procStat[21])

                pcpu = cls.__calculateCpuUsage(stime, utime, starttime)

        except FileNotFoundError:
            return None

        return cls([pid], comm, mem, 0, pcpu, swap)


    @staticmethod
    def __calculateCpuUsage(utime, stime, starttime) -> float:
        uptime: float = float(open("/proc/uptime").read().split()[0])   # in seconds
        clk_tck = os.sysconf(os.sysconf_names["SC_CLK_TCK"])
        utime = utime / clk_tck                                         # in seconds
        stime = stime / clk_tck                                         # in seconds
        starttime = starttime / clk_tck                                 # in seconds

        pcpu = 100 * (utime + stime) / (uptime - starttime)             # in percent

        return pcpu


    # read /proc/{$pid}/status file directly
    # TODO: read from /proc/[pid]/statm instead
    @staticmethod
    def __getSwapUsage(pid: list) -> int:
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


    @staticmethod
    def __getTotalMemory() -> int:
        try:
            with open("/proc/meminfo", 'r') as meminfo:
                totalMemory = int(meminfo.readline().split()[1])
        except:
            try:
                # totalMemory = int(1024 * 1024 * float(input("error reading /proc/meminfo file. please input your system total memory in GB: ")))
                raise       # temp
            except:
                totalMemory = 0

        return totalMemory


    def __str__(self) -> str:
        memInBytesWithOrder = self.formatBytes(self.__mem)
        swapInBytesWithOrder = self.formatBytes(self.__swap)

        return f"| {round(self.__pcpu,1):>5} | {round(self.__pmem,1):>4} | {memInBytesWithOrder:>4} | {swapInBytesWithOrder:>4} | {self.__comm:<20} {str(self.__pid):<18}"


    @staticmethod
    def formatBytes(kBytes: int) -> str:
        orderNames = {0: "k", 3: "M", 6: "G", 9: "T"}

        order = 0
        while (kBytes > 999):
            kBytes /= 1024
            order += 3

        if (order < 6):
            kBytes = int(kBytes)
        else:
            kBytes = round(kBytes, 1)

        return str(kBytes) + orderNames[order]


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
            self.__swap += self.__getSwapUsage(pid)

    def addPCPU(self, pcpu: float):
        if (pcpu):
            self.__pcpu += pcpu

    def addPMEM(self, pmem: float):
        if (pmem):
            self.__pmem += pmem
            self.__mem += pmem * self.TOTAL_MEMORY / 100


    def getAttribute(self, type: str = None):
        if   type == "pid":  return self.__pid
        elif type == "pcpu": return self.__pcpu
        elif type == "pmem": return self.__pmem
        elif type == "mem":  return self.__mem
        elif type == "comm": return self.__comm
        elif type == "swap": return self.__swap
        else:                return None



class ProcessArray:
    def __init__(self, fromProcFile: bool = False) -> None:
        self.__processArray: list[Process] = list()

        if fromProcFile:
            self.__getProcInformationFromProcFiles()
        else:
            self.__getProcesses()       # get a unique array of sorted processes by comm names


    def __getProcInformationFromProcFiles(self) -> None:
        processes = self.__processArray
        procDirs = glob.glob("/proc/[0-9]*")            # return /proc/[pid] directories

        for procDir in procDirs:
            process = Process.initFromProc(procDir)
            if process:                                 # if process is not None
                comm = process.getAttribute("comm")
                processes.append(process)

        self.__mergeProcessesWithSameComm()


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

        index = -1        # used to keep track of last process added to the processes array
        for line in lines:
            line = line.split(maxsplit=3)

            if len(line) == 0: continue         # if there's nothing in the line, skip it

            pid = int(line[0])
            pcpu = float(line[1])
            pmem = float(line[2])
            comm = line[3].split('/')[0]        # some process have sub-processes that named something like: "parentProcess/subProcess", I take only the parentProcess name

            if (comm in processNames):
                sameProcessIndex = processNames[comm]
                process: Process = processes[sameProcessIndex]
                process.addPID([pid])         # add new pid to list of pids inside of process object
                process.addPCPU(pcpu)
                process.addPMEM(pmem)
            else:
                process = Process([pid], comm, 0, pmem, pcpu, 0)
                processes.append(process)       # add new process to the processes array
                index += 1
                processNames[comm] = index          # add new process name to the processName dict to inform that it is the first occured process


    def __sortProcessArray(self, sortBy: str = "") -> None:
        processArray = self.__processArray
        size = len(processArray)

        if sortBy == "":
            return

        if   sortBy == "cpu": attrib = "pcpu"
        # elif sortBy == "mem": attrib = "pmem"         # redundant
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


    def __mergeProcesses(self, proc1: Process, proc2: Process):
        # TODO: implement the merging
        comm: str       = proc1.getAttribute("comm")
        pid:  list[int] = proc1.getAttribute("pid")  + proc2.getAttribute("pid")
        pcpu: float     = proc1.getAttribute("pcpu") + proc2.getAttribute("pcpu")
        pmem: float     = proc1.getAttribute("pmem") + proc2.getAttribute("pmem")
        mem:  int       = proc1.getAttribute("mem")  + proc2.getAttribute("mem")
        swap: int       = proc1.getAttribute("swap") + proc2.getAttribute("swap")

        # print("comm: ", proc1.getAttribute("comm"))
        # print("pid : ", proc1.getAttribute("pid"),  proc2.getAttribute("pid"),  pid)
        # print("pcpu: ", proc1.getAttribute("pcpu"), proc2.getAttribute("pcpu"), pcpu)
        # print("pmem: ", proc1.getAttribute("pmem"), proc2.getAttribute("pmem"), pmem)
        # print("mem : ", proc1.getAttribute("mem"),  proc2.getAttribute("mem"),  mem)
        # print("swap: ", proc1.getAttribute("swap"), proc2.getAttribute("swap"), swap)
        # print()

        mergedProcess = Process(pid, comm, mem, pmem, pcpu, swap)

        return mergedProcess


    # NOTE: something is wrong with this function
    def __mergeProcessesWithSameComm(self) -> None:
        processes = self.__processArray

        newProcessArray: list[Process] = list()
        newArrayIndex = -1
        processCommNames = dict()                       # format: {comm: index}
        for process in processes:
            comm = process.getAttribute("comm")
            # print(comm, process)
            if comm in processCommNames:
                previousProcessIndex = processCommNames[comm]
                previousProcess = newProcessArray[previousProcessIndex]
                newProcessArray[previousProcessIndex] = self.__mergeProcesses(previousProcess, process)       # merge previousProcess (already in processCommNames) with process and replace previousProcess by the new merged one
            else:
                newArrayIndex += 1
                newProcessArray.append(process)
                processCommNames[comm] = newArrayIndex

        self.__processArray = newProcessArray


    def findProcessByComm(self, comm: str, indexOnly: bool = False):
        found = False
        count = -1
        processes = self.__processArray
        for process in processes:
            count += 1
            if process.getAttribute("comm") == comm:
                found = True
                break

        if not found:
            process = None
            count = -1

        return count if indexOnly else (process, count)


    def getProcessArray(self):
        return self.__processArray


    def getTotalMemoryUsage(self):
        processes = self.__processArray

        totalMem: int = 0
        for process in processes:
            totalMem += process.getAttribute("mem")

        return Process.formatBytes(totalMem)


    def print(self, sortBy: str = "cpu", amount: int = -1) -> None:
        self.__sortProcessArray(sortBy)     # sort processArray

        processArraySize = len(self.__processArray)
        if amount < 0 or amount > processArraySize:
            amount = processArraySize

        for count, process in enumerate(self.__processArray[:amount]):
            print(f"{count+1:>{len(str(amount))}}", process)



def main() -> None:
    processes = ProcessArray(fromProcFile=USE_NEW)
    processes.print(CHOICE, MAX_COUNT)


if __name__ == "__main__":
    main()
