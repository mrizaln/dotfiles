#!/usr/bin/env python3

import math
import shutil
import subprocess


class Partition:
    PATH_MAX_LEN = 25
    NAME_MAX_LEN = 10

    # size and usedSize is in bytes
    def __init__(self, name: str = "", path: str = "", size: int = 0, usedSize: int = 0) -> None:
        self.name: str = name if len(name) < self.NAME_MAX_LEN else name[:self.NAME_MAX_LEN-1] + "…"
        self.path: str = path if len(path) < self.PATH_MAX_LEN else path[:self.PATH_MAX_LEN-1] + "…"
        self.size: int = size
        self.usedSize: int = usedSize + 0.05*self.size      # see: https://askubuntu.com/questions/249387/df-h-used-space-avail-free-space-is-less-than-the-total-size-of-home

    # size is in kbytes
    @classmethod
    def from_percentage(cls, name: str = "", path: str = "", size: int = 0, usedPercentage: float = 0) -> None:
        usedSize: int = int(usedPercentage * size / 100)
        cls.__init__(name, path, size, usedSize)

    # progress is normalized
    def print(self, terminalWidth: int):
        try:
            progress = self.usedSize / self.size
        except:
            progress = 0

        width = terminalWidth - self.PATH_MAX_LEN - self.NAME_MAX_LEN - 20

        free = self.size - self.usedSize
        free = f"{formatBytes(free):>6} free"

        size = f"{formatBytes(self.size):>6}"

        usedPercentage = f"{round(progress*100, 1):>4}%"

        # 0 <= progress <= 1
        progress = min(1, max(0, progress))
        whole_width = math.floor(progress * width)
        remainder_width = (progress * width) % 1
        part_width = math.floor(remainder_width * 8)
        part_char = [" ", "▏", "▎", "▍", "▌", "▋", "▊", "▉"][part_width]

        if (width - whole_width - 1) < 0:
            part_char = ""
        bar = "[" + "█" * whole_width + part_char + " " * (width - whole_width - 13) + "]" if terminalWidth >= 100 else ''

        line = f"{self.name:<{self.NAME_MAX_LEN}} {self.path:<{self.PATH_MAX_LEN}} {size} {bar} ({usedPercentage}) {free}"
        print(line)


def toBytes(size: str):
    if size[-1] in [1, 2, 3, 4, 5, 6, 7, 8, 9, 0]:
        return int(size)

    ordering = {'k': 3, 'M': 6, 'G': 9}
    return int(size[:-1]) * ordering[size[-1]]


def formatBytes(kBytes: int) -> str:
    orderNames = {0: "k", 3: "M", 6: "G", 9: "T"}

    order = 0
    while (kBytes > 1023):
        kBytes /= 1024
        order += 3

    if (order < 6):
        kBytes = int(kBytes)
    else:
        kBytes = round(kBytes, 1)

    return str(kBytes) + orderNames[order]


def test():
    part = Partition("/dev/sda6", "/home", 123987, 123000)
    terminalWidth, _ = shutil.get_terminal_size((80, 20))
    part.print(terminalWidth)


def main():
    # get list of filesystems
    command = "df 2> /dev/null | tail +2 | sort -k1"
    result = subprocess\
        .run(command, shell=True, stdout=subprocess.PIPE)\
        .stdout\
        .decode("utf-8")\
        .rstrip()
    lines = result.split('\n')

    terminalWidth, _ = shutil.get_terminal_size((80, 20))

    # 0 5 1 4
    parts = []
    for n, line in enumerate(lines):
        line = line.split()
        part = Partition(line[0], line[5], int(line[1]), int(line[2]))
#        print(line[0], line [5], line[1], line[2], sep = '\t')
        parts.append(part)

    parts = sorted(parts, key=lambda part: 0.95 - part.usedSize/part.size)
    for part in parts:
        part.print(terminalWidth)


if __name__ == "__main__":
#    test()
    main()
