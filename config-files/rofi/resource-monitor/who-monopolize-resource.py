#!/bin/python3

import subprocess
import sys

try:
    CHOICE = sys.argv[1].lower()
except:
    CHOICE = "cpu"

# CHOICE = "mem"

MAX_COUNT = 10

def getLines(cn="cpu"):
    if cn is None:
        return
    else:
        if cn == "cpu":
            col = 1
        elif cn == "mem":
            col = 2
        else:
            col = 1
        command = f"ps -eo pcpu,pmem,comm | tail +2 | sort -hrk {col}"
        result = subprocess.run(command, shell=True, stdout=subprocess.PIPE)
        return result.stdout.decode("utf-8")

def getProcesses(lines):
    names = dict()
    lines = lines.split('\n')

    count = 0
    for line in lines:
        line = line.split(maxsplit=2)
        if len(line) == 0: continue
        name = line[2]

        if name in names:
            names[name] = [names[name][0] + float(line[0]), names[name][1] + float(line[1])]
        else:
            names[name] = [float(line[0]), float(line[1])]
    return names

def getSortedList(dicti, choice):
    if choice == "cpu":
        col = 1
    elif choice == "mem":
        col = 2
    else:
        col = 1

    theList = list(dicti.items())
    theList = theList[0:30]         # get maximum of 20 element

    for i in range(len(theList)):
        sorted = True
        for j in range(len(theList)-1):
            kiri = theList[j][1][col-1]
            kanan = theList[j+1][1][col-1]

            if kanan > kiri:
                theList[j], theList[j+1] = theList[j+1], theList[j]
                sorted = False

        if sorted:
            break

    # return theList
    return theList[0:MAX_COUNT]

def printOut(lst):
    for i, (n, (p, m)) in enumerate(lst):
        print(f"{round(p,1):>4} {round(m,1):>4} {n:<}")


def main():
    choice = CHOICE
    lines = getLines(choice)
    processDict = getProcesses(lines)
    processList = getSortedList(processDict, choice)
    printOut(processList)

if __name__ == "__main__":
    main()