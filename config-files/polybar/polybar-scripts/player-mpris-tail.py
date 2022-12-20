#!/usr/bin/env python3

import sys
import dbus
import os
from operator import itemgetter
import argparse
import re
from urllib.parse import unquote
import time
from dbus.mainloop.glib import DBusGMainLoop
from gi.repository import GLib
DBusGMainLoop(set_as_default=True)


FORMAT_STRING    = '{icon} {artist} - {title}'
FORMAT_REGEX     = re.compile(r'(\{:(?P<tag>.*?)(:(?P<format>[wt])(?P<formatlen>\d+))?:(?P<text>.*?):\})', re.I)
FORMAT_TAG_REGEX = re.compile(r'(?P<format>[wt])(?P<formatlen>\d+)')
SAFE_TAG_REGEX   = re.compile(r'[{}]')

NEEDS_POSITION        : bool

TRUNCATE_STRING       : str
ICON_PLAYING          : str
ICON_PAUSED           : str
ICON_STOPPED          : str
ICON_NONE             : str

SCROLL_CHARACTER_LIMIT: int
SCROLL_SPEED          : int


class Player:
    def __init__(self, session_bus: dbus.SessionBus, bus_name: str, owner: str = None, connect: bool = True, _print: 'function' = None) -> None:
        self._session_bus  : dbus.SessionBus = session_bus
        self.bus_name      : str             = bus_name
        self._disconnecting: bool            = False
        self.__print       : 'function'      = _print    # function pointer

        self.metadata: dict[str,] = {
            'artist' : '',
            'album'  : '',
            'title'  : '',
            'track'  : 0
        }

        self._rate                : float = 1.
        self._positionAtLastUpdate: float = 0.
        self._timeAtLastUpdate    : float = time.time()
        self._positionTimerRunning: bool  = False

        self._metadata                    = None
        self.status               : str   = 'stopped'
        self.icon                 : str   = ICON_NONE
        self.icon_reversed        : str   = ICON_PLAYING

        if owner != None: self.owner = owner
        else:             self.owner = self._session_bus.get_name_owner(bus_name)

        self._obj                  = self._session_bus.get_object(self.bus_name, '/org/mpris/MediaPlayer2')
        self._properties_interface = dbus.Interface(self._obj, dbus_interface='org.freedesktop.DBus.Properties')
        self._introspect_interface = dbus.Interface(self._obj, dbus_interface='org.freedesktop.DBus.Introspectable')
        self._media_interface      = dbus.Interface(self._obj, dbus_interface='org.mpris.MediaPlayer2')
        self._player_interface     = dbus.Interface(self._obj, dbus_interface='org.mpris.MediaPlayer2.Player')
        self._introspect           = self._introspect_interface.get_dbus_method('Introspect', dbus_interface=None)
        self._getProperty          = self._properties_interface.get_dbus_method('Get', dbus_interface=None)
        self._playerPlay           = self._player_interface.get_dbus_method('Play', dbus_interface=None)
        self._playerPause          = self._player_interface.get_dbus_method('Pause', dbus_interface=None)
        self._playerPlayPause      = self._player_interface.get_dbus_method('PlayPause', dbus_interface=None)
        self._playerStop           = self._player_interface.get_dbus_method('Stop', dbus_interface=None)
        self._playerPrevious       = self._player_interface.get_dbus_method('Previous', dbus_interface=None)
        self._playerNext           = self._player_interface.get_dbus_method('Next', dbus_interface=None)
        self._playerRaise          = self._media_interface.get_dbus_method('Raise', dbus_interface=None)
        self._signals              = dict()

        self.refreshPosition()
        self.refreshStatus()
        self.refreshMetadata()

        if connect:
            self.printStatus()
            self.connect()

    def play(self):        self._playerPlay()
    def pause(self):       self._playerPause()
    def playpause(self):   self._playerPlayPause()
    def stop(self):        self._playerStop()
    def previous(self):    self._playerPrevious()
    def next(self):        self._playerNext()
    def raisePlayer(self): self._playerRaise()

    def connect(self) -> None:
        if self._disconnecting != True:
            introspect_xml = self._introspect(self.bus_name, '/')
            if 'TrackMetadataChanged' in introspect_xml:
                self._signals['track_metadata_changed'] = self._session_bus.add_signal_receiver(self.onMetadataChanged, 'TrackMetadataChanged', self.bus_name)
            self._signals['seeked'] = self._player_interface.connect_to_signal('Seeked', self.onSeeked)
            self._signals['properties_changed'] = self._properties_interface.connect_to_signal('PropertiesChanged', self.onPropertiesChanged)

    def disconnect(self) -> None:
        self._disconnecting = True
        for signal_name, signal_handler in list(self._signals.items()):
            signal_handler.remove()
            del self._signals[signal_name]

    def refreshStatus(self) -> None:
        # Some clients (VLC) will momentarily create a new player before removing it again
        # so we can't be sure the interface still exists
        try:
            self.status = str(self._getProperty('org.mpris.MediaPlayer2.Player', 'PlaybackStatus')).lower()
            self.updateIcon()
            self.checkPositionTimer()
        except dbus.exceptions.DBusException:
            self.disconnect()

    def refreshMetadata(self) -> None:
        # Some clients (VLC) will momentarily create a new player before removing it again
        # so we can't be sure the interface still exists
        try:
            self._metadata = self._getProperty('org.mpris.MediaPlayer2.Player', 'Metadata')
            self._parseMetadata()
        except dbus.exceptions.DBusException:
            self.disconnect()

    def updateIcon(self) -> None:
        self.icon = (
            ICON_PLAYING if self.status == 'playing' else
            ICON_PAUSED if self.status == 'paused' else
            ICON_STOPPED if self.status == 'stopped' else
            ICON_NONE
        )
        self.icon_reversed = (
            ICON_PAUSED if self.status == 'playing' else
            ICON_PLAYING
        )

    def _print(self, status: str) -> None:
        self.__print(status, self)

    def _parseMetadata(self) -> None:
        if self._metadata != None:
            # Obtain properties from _metadata
            _artist     = _getProperty(self._metadata, 'xesam:artist', [''])
            _album      = _getProperty(self._metadata, 'xesam:album', '')
            _title      = _getProperty(self._metadata, 'xesam:title', '')
            _track      = _getProperty(self._metadata, 'xesam:trackNumber', '')
            _genre      = _getProperty(self._metadata, 'xesam:genre', [''])
            _disc       = _getProperty(self._metadata, 'xesam:discNumber', '')
            _length     = _getProperty(self._metadata, 'xesam:length', 0) or _getProperty(self._metadata, 'mpris:length', 0)
            _length_int = _length if type(_length) is int else int(float(_length))
            _fmt_length = ( # Formats using h:mm:ss if length > 1 hour, else m:ss
                f'{_length_int/1e6//60:.0f}:{_length_int/1e6%60:02.0f}'
                if _length_int < 3600*1e6 else
                f'{_length_int/1e6//3600:.0f}:{_length_int/1e6%3600//60:02.0f}:{_length_int/1e6%60:02.0f}'
            )
            _date       = _getProperty(self._metadata, 'xesam:contentCreated', '')
            _year       = _date[0:4] if len(_date) else ''
            _url        = _getProperty(self._metadata, 'xesam:url', '')
            _cover      = _getProperty(self._metadata, 'xesam:artUrl', '') or _getProperty(self._metadata, 'mpris:artUrl', '')
            _duration   = _getDuration(_length_int)
            # Update metadata
            self.metadata['artist']     = re.sub(SAFE_TAG_REGEX, """\1\1""", _metadataGetFirstItem(_artist))
            self.metadata['album']      = re.sub(SAFE_TAG_REGEX, """\1\1""", _metadataGetFirstItem(_album))
            self.metadata['title']      = re.sub(SAFE_TAG_REGEX, """\1\1""", _metadataGetFirstItem(_title))
            self.metadata['track']      = _track
            self.metadata['genre']      = re.sub(SAFE_TAG_REGEX, """\1\1""", _metadataGetFirstItem(_genre))
            self.metadata['disc']       = _disc
            self.metadata['date']       = re.sub(SAFE_TAG_REGEX, """\1\1""", _date)
            self.metadata['year']       = re.sub(SAFE_TAG_REGEX, """\1\1""", _year)
            self.metadata['url']        = _url
            self.metadata['filename']   = os.path.basename(_url)
            self.metadata['length']     = _length_int
            self.metadata['fmt-length'] = _fmt_length
            self.metadata['cover']      = re.sub(SAFE_TAG_REGEX, """\1\1""", _metadataGetFirstItem(_cover))
            self.metadata['duration']   = _duration

    def onMetadataChanged(self, track_id, metadata) -> None:
        self.refreshMetadata()
        self.printStatus()

    def onPropertiesChanged(self, interface: dbus.String, properties: dbus.Dictionary, signature: dbus.Array) -> None:
        updated = False
        if dbus.String('Metadata') in properties:
            _metadata = properties[dbus.String('Metadata')]
            if _metadata != self._metadata:
                self._metadata = _metadata
                self._parseMetadata()
                updated = True
        if dbus.String('PlaybackStatus') in properties:
            status = str(properties[dbus.String('PlaybackStatus')]).lower()
            if status != self.status:
                self.status = status
                self.checkPositionTimer()
                self.updateIcon()
                updated = True
        if dbus.String('Rate') in properties and dbus.String('PlaybackStatus') not in properties:
            self.refreshStatus()
        if NEEDS_POSITION and dbus.String('Rate') in properties:
            rate = properties[dbus.String('Rate')]
            if rate != self._rate:
                self._rate = rate
                self.refreshPosition()

        if updated:
            self.refreshPosition()
            self.printStatus()

    def checkPositionTimer(self) -> None:
        if NEEDS_POSITION and self.status == 'playing' and not self._positionTimerRunning:
            self._positionTimerRunning = True
            GLib.timeout_add_seconds(1, self._positionTimer)

    def onSeeked(self, position) -> None:
        self.refreshPosition()
        self.printStatus()

    def _positionTimer(self) -> bool:
        self.printStatus()
        self._positionTimerRunning = self.status == 'playing'
        return self._positionTimerRunning

    def refreshPosition(self) -> None:
        try:
            time_us = self._getProperty('org.mpris.MediaPlayer2.Player', 'Position')
        except dbus.exceptions.DBusException:
            time_us = 0

        self._timeAtLastUpdate = time.time()
        self._positionAtLastUpdate = time_us / 1000000

    def _getPosition(self) -> float:
        if self.status == 'playing':
            return self._positionAtLastUpdate + self._rate * (time.time() - self._timeAtLastUpdate)
        else:
            return self._positionAtLastUpdate

    def _statusReplace(self, match: re.Match, metadata: dict) -> str:
        tag         : str  = match.group('tag')
        format      : str  = match.group('format')
        formatlen   : int  = match.group('formatlen')
        text        : str  = match.group('text')
        tag_found   : bool = False
        reversed_tag: bool = False

        if tag.startswith('-'):
            tag = tag[1:]
            reversed_tag = True

        if format is None:
            tag_is_format_match = re.match(FORMAT_TAG_REGEX, tag)
            if tag_is_format_match:
                format = tag_is_format_match.group('format')
                formatlen = tag_is_format_match.group('formatlen')
                tag_found = True
        if format is not None:
            text = text.format_map(CleanSafeDict(**metadata))
            if format == 'w':
                formatlen = int(formatlen)
                text = text[:formatlen]
            elif format == 't':
                formatlen = int(formatlen)
                if len(text) > formatlen:
                    text = text[:max(formatlen - len(TRUNCATE_STRING), 0)] + TRUNCATE_STRING
        if tag_found is False and tag in metadata and len(metadata[tag]):
            tag_found = True

        if reversed_tag:
            tag_found = not tag_found

        if tag_found:
            return text
        else:
            return ''

    def printStatus(self) -> None:
        if self.status in [ 'playing', 'paused' ]:
            metadata: dict = { **self.metadata, 'icon': self.icon, 'icon-reversed': self.icon_reversed }
            if NEEDS_POSITION:
                metadata['position'] = time.strftime("%M:%S", time.gmtime(self._getPosition()))
            # replace metadata tags in text
            text = re.sub(FORMAT_REGEX, lambda match: self._statusReplace(match, metadata), FORMAT_STRING)
            # restore polybar tag formatting and replace any remaining metadata tags after that
            try:
                text = re.sub(r'􏿿p􏿿(.*?)􏿿p􏿿(.*?)􏿿p􏿿(.*?)􏿿p􏿿', r'%{\1}\2%{\3}', text.format_map(CleanSafeDict(**metadata)))
            except:
                print("Invalid format string")
            self._print(text)
        else:
            self._print(ICON_STOPPED)


class PlayerManager:
    def __init__(self, filter_list: list, block_mode: bool = True, connect: bool = True) -> None:
        self.filter_list    : list[str]                = filter_list
        self.block_mode     : bool                     = block_mode

        self._connect       : bool                     = connect
        self._session_bus   : dbus.SessionBus          = dbus.SessionBus()
        self.players        : dict[str, Player]        = dict()

        self.print_queue    : list[tuple[str, Player]] = list()
        self.connected      : bool                     = False
        self.player_statuses: dict[str, str]           = dict()

        self.refreshPlayerList()

        # main loop
        if self._connect:
            self.connect()
            loop = GLib.MainLoop()      # what the heck is this doing?
            try:
                loop.run()              # this also
            except KeyboardInterrupt:
                print("interrupt received, stopping…")

    def connect(self) -> None:
        self._session_bus.add_signal_receiver(
            self.onOwnerChangedName,
            'NameOwnerChanged'
        )
        self._session_bus.add_signal_receiver(
            self.onChangedProperties,
            'PropertiesChanged',
            path='/org/mpris/MediaPlayer2',
            sender_keyword='sender'
        )

    def onChangedProperties(self, interface: dbus.String, properties: dbus.Dictionary, signature: dbus.Array, sender: str = None) -> None:
        # print("interface: ", type(interface), ", properties: ", type(properties), ", signature: ", type(signature), ", sender: ", type(sender))
        # print("interface: ", interface, ", properties: ", properties, ", signature: ", signature, ", sender: ", sender)
        if sender in self.players:
            player = self.players[sender]
            # If we know this player, but haven't been able to set up a signal handler
            if 'properties_changed' not in player._signals:
                # Then trigger the signal handler manually
                player.onPropertiesChanged(interface, properties, signature)
        else:
            # If we don't know this player, get its name and add it
            bus_name = self.getBusNameFromOwner(sender)
            if bus_name is None:
                return
            self.addPlayer(bus_name, sender)
            player = self.players[sender]
            player.onPropertiesChanged(interface, properties, signature)

    def onOwnerChangedName(self, bus_name, old_owner, new_owner) -> None:
        if self.busNameIsAPlayer(bus_name):
            if new_owner and not old_owner:
                self.addPlayer(bus_name, new_owner)
            elif old_owner and not new_owner:
                self.removePlayer(old_owner)
            else:
                self.changePlayerOwner(bus_name, old_owner, new_owner)

    def getBusNameFromOwner(self, owner: str) -> str | None:
        player_bus_names: list[str] = [ bus_name for bus_name in self._session_bus.list_names() if self.busNameIsAPlayer(bus_name) ]
        for player_bus_name in player_bus_names:
            player_bus_owner: str = self._session_bus.get_name_owner(player_bus_name)
            if owner == player_bus_owner:
                return player_bus_name
        return None

    def busNameIsAPlayer(self, bus_name: str) -> bool:
        if bus_name.startswith('org.mpris.MediaPlayer2') == False:
            return False

        name = bus_name.split('.')[3]
        if self.block_mode is True:
            return name not in self.filter_list

        return name in self.filter_list

    def refreshPlayerList(self) -> None:
        player_bus_names = [ bus_name for bus_name in self._session_bus.list_names() if self.busNameIsAPlayer(bus_name) ]
        for player_bus_name in player_bus_names:
            self.addPlayer(player_bus_name)
            
        if self.connected != True:
            self.connected = True
            self.printQueue()

    def addPlayer(self, bus_name: str, owner: str = None) -> None:
        player = Player(self._session_bus, bus_name, owner=owner, connect=self._connect, _print=self.print)
        self.players[player.owner] = player

    def removePlayer(self, owner: str) -> None:
        if owner in self.players:
            self.players[owner].disconnect()
            del self.players[owner]
        # If there are no more players, clear the output
        if len(self.players) == 0:
            _printFlush(ICON_NONE)
        # Else, print the output of the next active player
        else:
            players = self.getSortedPlayerOwnerList()
            if len(players) > 0:
                self.players[players[0]].printStatus()

    def changePlayerOwner(self, bus_name: str, old_owner: str, new_owner: str):
        player = Player(self._session_bus, bus_name, owner=new_owner, connect=self._connect, _print=self.print)
        self.players[new_owner] = player
        del self.players[old_owner]

    # Get a list of player owners sorted by current status and age
    def getSortedPlayerOwnerList(self) -> list[str]:
        players = [
            {
                'number': int(owner.split('.')[-1]),
                'status': 2 if player.status == 'playing' else 1 if player.status == 'paused' else 0,
                'owner': owner
            }
            for owner, player in self.players.items()
        ]
        return [ info['owner'] for info in sorted(players, key=itemgetter('status', 'number'), reverse=True) ]

    # Get latest player that's currently playing
    def getCurrentPlayer(self) -> Player | None:
        playing_players = [
            player_owner for player_owner in self.getSortedPlayerOwnerList()
            if
                self.players[player_owner].status == 'playing' or
                self.players[player_owner].status == 'paused'
        ]
        return self.players[playing_players[0]] if playing_players else None

    def print(self, status: str, player: Player) -> None:
        self.player_statuses[player.bus_name] = status

        if self.connected:
            current_player = self.getCurrentPlayer()
            if current_player != None:
                _printFlush(self.player_statuses[current_player.bus_name])
            else:
                _printFlush(ICON_STOPPED)
        else:
            self.print_queue.append((status, player))

    def printQueue(self) -> None:
        for (status, player) in self.print_queue:
            self.print(status, player)
        self.print_queue.clear()


def _dbusValueToPython(value):
    if isinstance(value, dbus.Dictionary):
        return {_dbusValueToPython(key): _dbusValueToPython(value) for key, value in value.items()}
    elif isinstance(value, dbus.Array):
        return [ _dbusValueToPython(item) for item in value ]
    elif isinstance(value, dbus.Boolean):
        return int(value) == 1
    elif (
        isinstance(value, dbus.Byte) or
        isinstance(value, dbus.Int16) or
        isinstance(value, dbus.UInt16) or
        isinstance(value, dbus.Int32) or
        isinstance(value, dbus.UInt32) or
        isinstance(value, dbus.Int64) or
        isinstance(value, dbus.UInt64)
    ):
        return int(value)
    elif isinstance(value, dbus.Double):
        return float(value)
    elif (
        isinstance(value, dbus.ObjectPath) or
        isinstance(value, dbus.Signature) or
        isinstance(value, dbus.String)
    ):
        return unquote(str(value))

def _getProperty(properties, property, default = None):
    value = default
    if not isinstance(property, dbus.String):
        property = dbus.String(property)
    if property in properties:
        value = properties[property]
        return _dbusValueToPython(value)
    else:
        return value

def _getDuration(t: int):
        seconds = t / 1000000
        return time.strftime("%M:%S", time.gmtime(seconds))

def _metadataGetFirstItem(_value):
    if type(_value) is list:
        # Returns the string representation of the first item on _value if it has at least one item.
        # Returns an empty string if _value is empty.
        return str(_value[0]) if len(_value) else ''
    else:
        # If _value isn't a list just return the string representation of _value.
        return str(_value)

class CleanSafeDict(dict):
    def __missing__(self, key):
        return '{{{}}}'.format(key)


"""
Seems to assure print() actually prints when no terminal is connected
"""
#=====[ old way ]=====
# _last_status = ''
# def _printFlush(status: str, **kwargs) -> None:
#     global _last_status
#     if status != _last_status:
#         print(status, **kwargs)
#         sys.stdout.flush()
#         _last_status = status

SCROLL_CHARACTER_LIMIT: int = 30
currentScrollCharacter: int = 0
timeoutReference = "" 
SCROLL_SPEED = 250
_last_status = ''
def _printFlush(status, **kwargs):
    global _last_status
    global SCROLL_CHARACTER_LIMIT
    global timeoutReference
    if status != _last_status:
        if timeoutReference != "":
            GLib.source_remove(timeoutReference)
            timeoutReference = ""
        if SCROLL_CHARACTER_LIMIT != 0 and len(status) > SCROLL_CHARACTER_LIMIT:
            _printScrolling(status, **kwargs)
        else:
            print(status, **kwargs)
            sys.stdout.flush()

        _last_status = status

def _printScrolling(string, **kwargs):
    global SCROLL_CHARACTER_LIMIT
    global currentScrollCharacter
    global SCROLL_SPEED
    global timeoutReference

    printString = string[currentScrollCharacter:currentScrollCharacter+SCROLL_CHARACTER_LIMIT]

    if SCROLL_CHARACTER_LIMIT + currentScrollCharacter  > len(string):
        rolloverAmmount =  SCROLL_CHARACTER_LIMIT + currentScrollCharacter - len(string) 
        printString += string[0: rolloverAmmount]

    print(printString, **kwargs)
    sys.stdout.flush()

    # if(currentScrollCharacter < len(string)-1):
    if currentScrollCharacter == 0:
        currentScrollCharacter += 1
        timeoutReference = GLib.timeout_add(5*SCROLL_SPEED, _printScrolling,string)
    elif currentScrollCharacter < len(string)-SCROLL_CHARACTER_LIMIT:
        currentScrollCharacter += 1
        timeoutReference = GLib.timeout_add(SCROLL_SPEED, _printScrolling,string)
    else:
        currentScrollCharacter = 0
        timeoutReference = GLib.timeout_add(5*SCROLL_SPEED, _printScrolling,string)

# main function
def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('command', help="send the given command to the active player",
                        choices=[ 'play', 'pause', 'play-pause', 'stop', 'previous', 'next', 'status', 'list', 'current', 'metadata', 'raise' ],
                        default=None,
                        nargs='?')
    parser.add_argument('-b', '--blacklist', help="ignore a player by it's bus name. Can be given multiple times (e.g. -b vlc -b audacious)",
                        action='append',
                        metavar="BUS_NAME",
                        default=[])
    parser.add_argument('-w', '--whitelist', help="permit a player by it's bus name like --blacklist. will block --blacklist if given",
                        action='append',
                        metavar="BUS_NAME",
                        default=[])
    parser.add_argument('-f', '--format', default='{icon} {:artist:{artist} - :}{:title:{title}:}{:-title:{filename}:}')
    parser.add_argument('-s', '--scroll', default='0',help="when the text is to long scroll trough it. Set to the number of characters that get shown")
    parser.add_argument('--scroll-speed', default='250',help="delay in ms until the next character is shown.")
    parser.add_argument('--truncate-text', default='…')
    parser.add_argument('--icon-playing', default='⏵')
    parser.add_argument('--icon-paused', default='⏸')
    parser.add_argument('--icon-stopped', default='⏹')
    parser.add_argument('--icon-none', default='')

    args = parser.parse_args()

    global FORMAT_STRING  ; FORMAT_STRING   = re.sub(r'%\{(.*?)\}(.*?)%\{(.*?)\}', r'􏿿p􏿿\1􏿿p􏿿\2􏿿p􏿿\3􏿿p􏿿', args.format)
    global NEEDS_POSITION ; NEEDS_POSITION  = "{position}" in FORMAT_STRING

    global TRUNCATE_STRING       ; TRUNCATE_STRING        = args.truncate_text
    global ICON_PLAYING          ; ICON_PLAYING           = args.icon_playing
    global ICON_PAUSED           ; ICON_PAUSED            = args.icon_paused
    global ICON_STOPPED          ; ICON_STOPPED           = args.icon_stopped
    global ICON_NONE             ; ICON_NONE              = args.icon_none
    global SCROLL_CHARACTER_LIMIT; SCROLL_CHARACTER_LIMIT = int(args.scroll)
    global SCROLL_SPEED          ; SCROLL_SPEED           = int(args.scroll_speed)

    block_mode: bool = len(args.whitelist) == 0
    filter_list: list = args.blacklist if block_mode else args.whitelist

    if args.command is None:
        PlayerManager(filter_list=filter_list, block_mode=block_mode)
    else:
        player_manager = PlayerManager(filter_list=filter_list, block_mode=block_mode, connect=False)
        current_player = player_manager.getCurrentPlayer()
        if args.command == 'play' and current_player:
            current_player.play()
        elif args.command == 'pause' and current_player:
            current_player.pause()
        elif args.command == 'play-pause' and current_player:
            current_player.playpause()
        elif args.command == 'stop' and current_player:
            current_player.stop()
        elif args.command == 'previous' and current_player:
            current_player.previous()
        elif args.command == 'next' and current_player:
            current_player.next()
        elif args.command == 'status' and current_player:
            current_player.printStatus()
        elif args.command == 'list':
            print("\n".join(sorted([
                "{} : {}".format(player.bus_name.split('.')[3], player.status)
                for player in player_manager.players.values() ])))
        elif args.command == 'current' and current_player:
            print("{} : {}".format(current_player.bus_name.split('.')[3], current_player.status))
        elif args.command == 'metadata' and current_player:
            print(_dbusValueToPython(current_player._metadata))
        elif args.command == 'raise' and current_player:
            current_player.raisePlayer()


if __name__ == "__main__":
    main()
