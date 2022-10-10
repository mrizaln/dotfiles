#!/usr/bin/env python3

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

def getEvents(calendar: Calendar, startTime: float, endTime: float) -> list[Event]:
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

def printCalendar(sourceFile: str, today: bool=False, timezone: str=TIMEZONE) -> None:
    calendar = Calendar()
    with open(sourceFile, 'r') as file_handler:
        calendar = Calendar(file_handler.read())

    if today:
        it = calendar.timeline.today()
        for event in it:
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
            begin: str = event.begin.to(timezone).format('ddd (HH:mm)')
            time = begin
            if event.duration.total_seconds() > 24*60*60:
                time = f"{event.begin.to(timezone).format('DD/MM')} - {event.end.to(timezone).format('DD/MM')}"
            print(time, end='\t')
            print(event.name, end="   ")
            print(f"({event.location})")


def cacheCalendar(sourceFile: str, destinationFile: str, startTime: float, endTime: float, timezone: str=TIMEZONE) -> None:
    sourceCalendar = openCalendar(sourceFile)
    events = getEvents(sourceCalendar, startTime, endTime)
    newCalendar = createNewCalendar(events, timezone)
    export(newCalendar, destinationFile)


def main():
    parser = argparse.ArgumentParser()

    parser.add_argument("-f", "--file", help="file to be processed. if used with --cache, it will use this file to create a cache",
                        action="store",
                        metavar="FILE",
                        default=None)
    parser.add_argument("-c", "--cache", help="cache calendar for N days (using -d option), or from START to END (using -s and -e option)",
                        action="store_true")
    parser.add_argument("-p", "--print", help="print a pretty list of all events",
                        action="store_true")
    parser.add_argument("--today", help="use with print. print today events (not all events in a file)",
                        action="store_true")
    parser.add_argument("-s", "--start", help="unix time",
                        action="store",
                        metavar="START",
                        default=None)
    parser.add_argument("-e", "--end", help="unix time",
                        action="store",
                        metavar="END",
                        default=None)
    parser.add_argument("-d", "--days", help="days interval from now",
                        action="store",
                        metavar="DAYS",
                        default=None)
    parser.add_argument("-tz", "--timezone",
                        action="store",
                        metavar="TIMEZONE",
                        default=None)

    args = parser.parse_args()
    
    CACHE = args.cache
    PRINT = args.print
    TZ = args.timezone if args.timezone is not None else TIMEZONE


    if CACHE:
        if not args.days and not (args.start and args.end):
            print("if -c option is used, you need to specify -s and -e, or -d")
            exit(1)

        if args.days is not None:
            time_now: float = arrow.utcnow().timestamp()
            time_later: float = arrow.utcnow().shift(days=int(args.days)).timestamp()
            source = args.file if args.file is not None else SOURCE_FILE
            dest = "calendar_cache.ics"
            cacheCalendar(source, dest, time_now, time_later, TZ)

    if PRINT:
        if not args.file:
            print("file needs to be specified")
            exit(1)
        
        file = args.file
        printCalendar(file, args.today, TZ)


if __name__ == "__main__":
    main()

