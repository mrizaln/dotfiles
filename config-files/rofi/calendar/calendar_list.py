#!/usr/bin/env python3

import os
import argparse
import arrow
from ics import Calendar, Event

SOURCE_FILE = "/home/mrizaln/.config/rofi/calendar/calendar.ics"
TIMEZONE = "Asia/Jakarta"

def openCalendar(sourceFile: str) -> Calendar:
    calendar = Calendar()
    with open(sourceFile, 'r') as file_handler:
        calendar = Calendar(file_handler.read())
    return calendar

def getEvents(calendar: Calendar, startTime: float=-1, endTime: float=-1) -> list[Event]:
    if startTime == -1 or endTime == -1:
        return list(calendar.events)

    eventList: list[Event] = list()
    for event in iter(calendar.timeline):
        event_begin_time: float = event.begin.timestamp()
        event_end_time: float = event.end.timestamp()
        if (endTime < event_begin_time or startTime > event_end_time):
            continue
        eventList.append(event)
    return eventList

def createNewCalendar(eventList: list[Event], timezone: str=TIMEZONE) -> Calendar:
    calendar = Calendar()
    for event in eventList:
        # event.begin.replace(tzinfo=TIMEZONE)
        # event.end.replace(tzinfo=TIMEZONE)
        calendar.events.add(event)
    return calendar

def export(calendar: Calendar, fileName: str) -> None:
    with open(fileName, 'w') as f:
        f.writelines(calendar.serialize_iter())

def printCalendar(sourceFile: str, today: bool=False, timezone: str=TIMEZONE, full: bool=False) -> None:
    calendar = Calendar()
    with open(sourceFile, 'r') as file_handler:
        calendar = Calendar(file_handler.read())

    if today:
        it = calendar.timeline.today()
        for event in it:
            if full:
                print(event.begin.to(timezone).format(), end =' - ')
                print(event.end.to(timezone).format(), end = ' \t ')
                print(event.name, end = '\t')
                for ext in event.extra:
                    print(ext, end=' ')
                    print()
            else:
                begin: str = event.begin.to(timezone).format('HH:mm')
                end: str = event.end.to(timezone).format('HH:mm')
                time = begin + " - " + end
                if event.duration.total_seconds() > 24*60*60:
                    time = f"{event.begin.to(timezone).format('DD/MM')} - {event.end.to(timezone).format('DD/MM')}"
                print(f"{time:<17}", end='')
                print(event.name, end="    ")
                print(f"({event.location})")
    else:
        it = iter(calendar.timeline)
        for event in it:
            if full:
                print(event.begin.to(timezone).format(), end =' - ')
                print(event.end.to(timezone).format(), end = ' \t ')
                print(event.name, end = '\t')
                for ext in event.extra:
                    print(ext, end=' ')
                print()
            else:
                begin: str = event.begin.to(timezone).format('ddd (HH:mm)')
                time = begin
                if event.duration.total_seconds() > 24*60*60:
                    time = f"{event.begin.to(timezone).format('DD/MM')} - {event.end.to(timezone).format('DD/MM')}"
                print(time, end='\t')
                print(event.name, end="   ")
                print(f"({event.location})")


def cacheCalendar(sourceFile: str, destinationFile: str, startTime: float=-1, endTime: float=-1, timezone: str=TIMEZONE) -> None:
    sourceCalendar = openCalendar(sourceFile)
    sourceCalendar = parseRRULE(sourceCalendar)
    events = getEvents(sourceCalendar, startTime, endTime)
    newCalendar = createNewCalendar(events, timezone)
    export(newCalendar, destinationFile)

# parse event with RRULE from calendar
def parseRRULE(calendar: Calendar):
    calendar_temp: Calendar = calendar.clone()
    for event in calendar.events:
        for ext in event.extra:
            val = str(ext)
            if val.startswith("RRULE"):
                rrule = val.split(';')
                if rrule[2].startswith("COUNT"):
                    count = int(rrule[2].split("=")[1])        # COUNT=N
                    for i in range(count):
                        event_copy = event.clone()
                        event_copy.end = event_copy.end.shift(weeks=i+1)
                        event_copy.begin = event_copy.begin.shift(weeks=i+1)
                        calendar_temp.events.add(event_copy)
    return calendar_temp

def main():
    parser = argparse.ArgumentParser()

    parser.add_argument("-f", "--file", help="file to be processed. if used with --cache, it will use this file to create a cache",
                        action="store",
                        metavar="FILE",
                        default=None)
    parser.add_argument("-c", "--cache", help="create a cache of calendar (from FILE) for N days (using -d option), or from START to END (using -s and -e option). the CACHE_LOCATION needs to be an absolute path",
                        action="store",
                        metavar="CACHE_LOCATION",
                        default=None)
    parser.add_argument("-s", "--start", help="unix time",
                        action="store",
                        metavar="START",
                        default=None)
    parser.add_argument("-e", "--end", help="unix time",
                        action="store",
                        metavar="END",
                        default=None)
    parser.add_argument("-d", "--days", help="days interval from now. set to -1 to get all events",
                        type=int,
                        action="store",
                        metavar="DAYS",
                        default=None)
    parser.add_argument("-p", "--print", help="print a pretty list of all events",
                        action="store_true")
    parser.add_argument("-pf", "--print-full", help="print full format",
                        action="store_true")
    parser.add_argument("--today", help="use with print. print today events (not all events in a file)",
                        action="store_true")
    parser.add_argument("-tz", "--timezone",
                        action="store",
                        metavar="TIMEZONE",
                        default=None)
    parser.add_argument("-q", "--quiet", help="don't print anything (except from -p or -pf)",
                        action="store_true")

    args = parser.parse_args()

    QUIET = args.quiet
    CACHE = args.cache
    PRINT = args.print
    PRINT_FULL = args.print_full
    TZ = args.timezone if args.timezone is not None else TIMEZONE

    if args.file and not QUIET:
        print(f"using {args.file} as source")

    if CACHE:
        if not QUIET: print(f"using {CACHE} as cache location")

        if CACHE[0] != '/' and CACHE[0] != '~':         # -(c == / or c == ~)    c != / and c != ~
            print("CACHE_LOCATION needs to be an absolute path")
            exit(1)

        if not args.days and not (args.start and args.end):
            print("if -c option is used, you need to specify -s and -e, or -d")
            exit(1)

        if  not QUIET: print("caching...")

        if args.days is not None:
            time_now: float = arrow.utcnow().timestamp()
            time_later: float = arrow.utcnow().shift(days=int(args.days)).timestamp() if args.days != -1 else -1
            source = args.file if args.file is not None else SOURCE_FILE
            dest = os.path.join(CACHE, "calendar_cache.ics")
            cacheCalendar(source, dest, time_now, time_later, TZ)

    if PRINT:
        if not args.file:
            print("file needs to be specified")
            exit(1)

        file = args.file
        printCalendar(file, args.today, TZ)

    if PRINT_FULL:
        if not args.file:
            print("file needs to be specified")
            exit(1)

        file = args.file
        printCalendar(file, full=True)

def empty(*args, **kwargs):
    pass

if __name__ == "__main__":
    main()

