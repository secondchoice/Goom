from collections.abc import Iterable
import os
import ctypes
from ctypes import c_uint8 as c_uint8
import math
from PIL import Image
import sys
import json
import random
import struct
import re

from collections import OrderedDict


def get(file, format):
    return struct.unpack(format, file.read(struct.calcsize(format)))


def tos(x):
    return x.decode("utf-8").rstrip("\x00").upper()


def unpack_array(f, filelump, record, *args):
    f.seek(filelump.filepos)
    record_size = struct.calcsize(record.record_format)
    results = []
    for _ in range(filelump.size // record_size):
        results.append(record(f, *args))
    return results


def is_sky(texture_name):
    return bool(re.match(r".*SKY.*", texture_name))


# https://doom.fandom.com/wiki/Linedef_type


# fmt: off
door_types = {
    1: ['Reg', 'PR', 'No', 'Slow', '4s', 'Yes', 'Open, Wait, Then Close'],
    117: ['Reg', 'PR', 'No', 'Fast', '4s', 'No', 'Open, Wait, Then Close'],
    63: ['Reg', 'SR', 'No', 'Slow', '4s', 'No', 'Open, Wait, Then Close'],
    114: ['Reg', 'SR', 'No', 'Fast', '4s', 'No', 'Open, Wait, Then Close'],
    29: ['Reg', 'S1', 'No', 'Slow', '4s', 'No', 'Open, Wait, Then Close'],
    111: ['Reg', 'S1', 'No', 'Fast', '4s', 'No', 'Open, Wait, Then Close'],
    90: ['Reg', 'WR', 'No', 'Slow', '4s', 'No', 'Open, Wait, Then Close'],
    105: ['Reg', 'WR', 'No', 'Fast', '4s', 'No', 'Open, Wait, Then Close'],
    4: ['Reg', 'W1', 'No', 'Slow', '4s', 'Yes', 'Open, Wait, Then Close'],
    108: ['Reg', 'W1', 'No', 'Fast', '4s', 'No', 'Open, Wait, Then Close'],
    31: ['Reg', 'P1', 'No', 'Slow', '--,', 'No', 'Open and Stay Open'],
    118: ['Reg', 'P1', 'No', 'Fast', '--', 'No', 'Open and Stay Open'],
    61: ['Reg', 'SR', 'No', 'Slow', '--', 'No', 'Open and Stay Open'],
    115: ['Reg', 'SR', 'No', 'Fast', '--', 'No', 'Open and Stay Open'],
    103: ['Reg', 'S1', 'No', 'Slow', '--', 'No', 'Open and Stay Open'],
    112: ['Reg', 'S1', 'No', 'Fast', '--', 'No', 'Open and Stay Open'],
    86: ['Reg', 'WR', 'No', 'Slow', '--', 'No', 'Open and Stay Open'],
    106: ['Reg', 'WR', 'No', 'Fast', '--', 'No', 'Open and Stay Open'],
    2: ['Reg', 'W1', 'No', 'Slow', '--', 'No', 'Open and Stay Open'],
    109: ['Reg', 'W1', 'No', 'Fast', '--', 'No', 'Open and Stay Open'],
    46: ['Reg', 'GR', 'No', 'Slow', '--', 'No', 'Open and Stay Open'],
    42: ['Reg', 'SR', 'No', 'Slow', '--', 'No', 'Close and Stay Closed'],
    116: ['Reg', 'SR', 'No', 'Fast', '--', 'No', 'Close and Stay Closed'],
    50: ['Reg', 'S1', 'No', 'Slow', '--', 'No', 'Close and Stay Closed'],
    113: ['Reg', 'S1', 'No', 'Fast', '--', 'No', 'Close and Stay Closed'],
    75: ['Reg', 'WR', 'No', 'Slow', '--', 'No', 'Close and Stay Closed'],
    107: ['Reg', 'WR', 'No', 'Fast', '--', 'No', 'Close and Stay Closed'],
    3: ['Reg', 'W1', 'No', 'Slow', '--', 'No', 'Close and Stay Closed'],
    110: ['Reg', 'W1', 'No', 'Fast', '--', 'No', 'Close and Stay Closed'],
    196: ['Ext', 'SR', 'No', 'Slow', '30s', 'No', 'Close, Wait, Then Open'],
    175: ['Ext', 'S1', 'No', 'Slow', '30s', 'No', 'Close, Wait, Then Open'],
    76: ['Reg', 'WR', 'No', 'Slow', '30s', 'No', 'Close, Wait, Then Open'],
    16: ['Reg', 'W1', 'No', 'Slow', '30s', 'No Close, Wait, Then Open'],
    26: ['Reg', 'PR', 'Blue', 'Slow', '4s', 'No', 'Open, Wait, Then Close'],
    28: ['Reg', 'PR', 'Red', 'Slow', '4s', 'No', 'Open, Wait, Then Close'],
    27: ['Reg', 'PR', 'Yell', 'Slow', '4s', 'No', 'Open, Wait, Then Close'],
    32: ['Reg', 'P1', 'Blue', 'Slow', '--', 'No', 'Open and Stay Open'],
    33: ['Reg', 'P1', 'Red', 'Slow', '--', 'No', 'Open and Stay Open'],
    34: ['Reg', 'P1', 'Yell', 'Slow', '--', 'No', 'Open and Stay Open'],
    99: ['Reg', 'SR', 'Blue', 'Fast', '--', 'No', 'Open and Stay Open'],
    134: ['Reg', 'SR', 'Red', 'Fast', '--', 'No', 'Open and Stay Open'],
    136: ['Reg', 'SR', 'Yell', 'Fast', '--', 'No', 'Open and Stay Open'],
    133: ['Reg', 'S1', 'Blue', 'Fast', '--', 'No', 'Open and Stay Open'],
    135: ['Reg', 'S1', 'Red', 'Fast', '--', 'No', 'Open and Stay Open'],
    137: ['Reg', 'S1', 'Yell', 'Fast', '--', 'No', 'Open and Stay Open'],
}

floor_types = {
    60: ["Reg", "SR", "Dn", "Slow", "None", "--", "No", "No", "Lowest Neighbor Floor"],
    23: ["Reg", "S1", "Dn", "Slow", "None", "--", "No", "No", "Lowest Neighbor Floor"],
    82: ["Reg", "WR", "Dn", "Slow", "None", "--", "No", "No", "Lowest Neighbor Floor"],
    38: ["Reg", "W1", "Dn", "Slow", "None", "--", "No", "No", "Lowest Neighbor Floor"],
    177: ["Ext", "SR", "Dn", "Slow", "TxTy", "Num", "No", "No", "Lowest Neighbor Floor"],
    159: ["Ext", "S1", "Dn", "Slow", "TxTy", "Num", "No", "No", "Lowest Neighbor Floor"],
    84: ["Reg", "WR", "Dn", "Slow", "TxTy", "Num", "No", "No", "Lowest Neighbor Floor"],
    37: ["Reg", "W1", "Dn", "Slow", "TxTy", "Num", "No", "No", "Lowest Neighbor Floor"],
    69: ["Reg", "SR", "Up", "Slow", "None", "--", "No", "No", "Next Neighbor Floor"],
    18: ["Reg", "S1", "Up", "Slow", "None", "--", "No", "No", "Next Neighbor Floor"],
    128: ["Reg", "WR", "Up", "Slow", "None", "--", "No", "No", "Next Neighbor Floor"],
    119: ["Reg", "W1", "Up", "Slow", "None", "--", "No", "No", "Next Neighbor Floor"],
    132: ["Reg", "SR", "Up", "Fast", "None", "--", "No", "No", "Next Neighbor Floor"],
    131: ["Reg", "S1", "Up", "Fast", "None", "--", "No", "No", "Next Neighbor Floor"],
    129: ["Reg", "WR", "Up", "Fast", "None", "--", "No", "No", "Next Neighbor Floor"],
    130: ["Reg", "W1", "Up", "Fast", "None", "--", "No", "No", "Next Neighbor Floor"],
    222: ["Ext", "SR", "Dn", "Slow", "None", "--", "No", "No", "Next Neighbor Floor"],
    221: ["Ext", "S1", "Dn", "Slow", "None", "--", "No", "No", "Next Neighbor Floor"],
    220: ["Ext", "WR", "Dn", "Slow", "None", "--", "No", "No", "Next Neighbor Floor"],
    219: ["Ext", "W1", "Dn", "Slow", "None", "--", "No", "No", "Next Neighbor Floor"],
    64: ["Reg", "SR", "Up", "Slow", "None", "--", "No", "No", "Lowest Neighbor Ceiling"],
    101: ["Reg", "S1", "Up", "Slow", "None", "--", "No", "No", "Lowest Neighbor Ceiling"],
    91: ["Reg", "WR", "Up", "Slow", "None", "--", "No", "No", "Lowest Neighbor Ceiling"],
    5: ["Reg", "W1", "Up", "Slow", "None", "--", "No", "No", "Lowest Neighbor Ceiling"],
    24: ["Reg", "G1", "Up", "Slow", "None", "--", "No", "No", "Lowest Neighbor Ceiling"],
    65: ["Reg", "SR", "Up", "Slow", "None", "--", "No", "Yes", "Lowest Neighbor Ceiling - 8"],
    55: ["Reg", "S1", "Up", "Slow", "None", "--", "No", "Yes", "Lowest Neighbor Ceiling - 8"],
    94: ["Reg", "WR", "Up", "Slow", "None", "--", "No", "Yes", "Lowest Neighbor Ceiling - 8"],
    56: ["Reg", "W1", "Up", "Slow", "None", "--", "No", "Yes", "Lowest Neighbor Ceiling - 8"],
    45: ["Reg", "SR", "Dn", "Slow", "None", "--", "No", "No", "Highest Neighbor Floor"],
    102: ["Reg", "S1", "Dn", "Slow", "None", "--", "No", "No", "Highest Neighbor Floor"],
    83: ["Reg", "WR", "Dn", "Slow", "None", "--", "No", "No", "Highest Neighbor Floor"],
    19: ["Reg", "W1", "Dn", "Slow", "None", "--", "No", "No", "Highest Neighbor Floor"],
    70: ["Reg", "SR", "Dn", "Fast", "None", "--", "No", "No", "Highest Neighbor Floor + 8"],
    71: ["Reg", "S1", "Dn", "Fast", "None", "--", "No", "No", "Highest Neighbor Floor + 8"],
    98: ["Reg", "WR", "Dn", "Fast", "None", "--", "No", "No", "Highest Neighbor Floor + 8"],
    36: ["Reg", "W1", "Dn", "Fast", "None", "--", "No", "No", "Highest Neighbor Floor + 8"],
    180: ["Ext", "SR", "Up", "Slow", "None", "--", "No", "No", "Absolute 24"],
    161: ["Ext", "S1", "Up", "Slow", "None", "--", "No", "No", "Absolute 24"],
    92: ["Reg", "WR", "Up", "Slow", "None", "--", "No", "No", "Absolute 24"],
    58: ["Reg", "W1", "Up", "Slow", "None", "--", "No", "No", "Absolute 24"],
    179: ["Ext", "SR", "Up", "Slow", "TxTy", "Trg", "No", "No", "Absolute 24"],
    160: ["Ext", "S1", "Up", "Slow", "TxTy", "Trg", "No", "No", "Absolute 24"],
    93: ["Reg", "WR", "Up", "Slow", "TxTy", "Trg", "No", "No", "Absolute 24"],
    59: ["Reg", "W1", "Up", "Slow", "TxTy", "Trg", "No", "No", "Absolute 24"],
    176: ["Ext", "SR", "Up", "Slow", "None", "--", "No", "No", "Abs Shortest Lower Texture"],
    158: ["Ext", "S1", "Up", "Slow", "None", "--", "No", "No", "Abs Shortest Lower Texture"],
    96: ["Reg", "WR", "Up", "Slow", "None", "--", "No", "No", "Abs Shortest Lower Texture"],
    30: ["Reg", "W1", "Up", "Slow", "None", "--", "No", "No", "Abs Shortest Lower Texture"],
    178: ["Ext", "SR", "Up", "Slow", "None", "--", "No", "No", "Absolute 512"],
    140: ["Reg", "S1", "Up", "Slow", "None", "--", "No", "No", "Absolute 512"],
    147: ["Ext", "WR", "Up", "Slow", "None", "--", "No", "No", "Absolute 512"],
    142: ["Ext", "W1", "Up", "Slow", "None", "--", "No", "No", "Absolute 512"],
    190: ["Ext", "SR", "--", "----", "TxTy", "Trg", "No", "No", "None"],
    189: ["Ext", "S1", "--", "----", "TxTy", "Trg", "No", "No", "None"],
    154: ["Ext", "WR", "--", "----", "TxTy", "Trg", "No", "No", "None"],
    153: ["Ext", "W1", "--", "----", "TxTy", "Trg", "No", "No", "None"],
    78: ["Ext", "SR", "--", "----", "TxTy", "Num", "No", "No", "None"],
    241: ["Ext", "S1", "--", "----", "TxTy", "Num", "No", "No", "None"],
    240: ["Ext", "WR", "--", "----", "TxTy", "Num", "No", "No", "None"],
    239: ["Ext", "W1", "--", "----", "TxTy", "Num", "No", "No", "None"],
}

ceiling_types = {
    43: ["Reg", "SR", "Dn", "Fast", "None", "--", "No", "No", "Floor"],
    41: ["Reg", "S1", "Dn", "Fast", "None", "--", "No", "No", "Floor"],
    152: ["Ext", "WR", "Dn", "Fast", "None", "--", "No", "No", "Floor"],
    145: ["Ext", "W1", "Dn", "Fast", "None", "--", "No", "No", "Floor"],
    186: ["Ext", "SR", "Up", "Slow", "None", "--", "No", "No", "Highest Neighbor Ceiling"],
    166: ["Ext", "S1", "Up", "Slow", "None", "--", "No", "No", "Highest Neighbor Ceiling"],
    151: ["Ext", "WR", "Up", "Slow", "None", "--", "No", "No", "Highest Neighbor Ceiling"],
    40: ["Reg", "W1", "Up", "Slow", "None", "--", "No", "No", "Highest Neighbor Ceiling"],
    187: ["Ext", "SR", "Dn", "Slow", "None", "--", "No", "No", "8 Above Floor"],
    167: ["Ext", "S1", "Dn", "Slow", "None", "--", "No", "No", "8 Above Floor"],
    72: ["Reg", "WR", "Dn", "Slow", "None", "--", "No", "No", "8 Above Floor"],
    44: ["Reg", "W1", "Dn", "Slow", "None", "--", "No", "No", "8 Above Floor"],
    205: ["Ext", "SR", "Dn", "Slow", "None", "--", "No", "No", "Lowest Neighbor Ceiling"],
    203: ["Ext", "S1", "Dn", "Slow", "None", "--", "No", "No", "Lowest Neighbor Ceiling"],
    201: ["Ext", "WR", "Dn", "Slow", "None", "--", "No", "No", "Lowest Neighbor Ceiling"],
    199: ["Ext", "W1", "Dn", "Slow", "None", "--", "No", "No", "Lowest Neighbor Ceiling"],
    206: ["Ext", "SR", "Dn", "Slow", "None", "--", "No", "No", "Highest Neighbor Floor"],
    204: ["Ext", "S1", "Dn", "Slow", "None", "--", "No", "No", "Highest Neighbor Floor"],
    202: ["Ext", "WR", "Dn", "Slow", "None", "--", "No", "No", "Highest Neighbor Floor"],
    200: ["Ext", "W1", "Dn", "Slow", "None", "--", "No", "No", "Highest Neighbor Floor"],
}

platform_types = {
    66: ["Reg", "SR", "--", "Slow", "Tx", "Trg", "No", "Raise 24 Units"],
    15: ["Reg", "S1", "--", "Slow", "Tx", "Trg", "No", "Raise 24 Units"],
    148: ["Ext", "WR", "--", "Slow", "Tx", "Trg", "No", "Raise 24 Units"],
    143: ["Ext", "W1", "--", "Slow", "Tx", "Trg", "No", "Raise 24 Units"],
    67: ["Reg", "SR", "--", "Slow", "Tx0", "Trg", "No", "Raise 32 Units"],
    14: ["Reg", "S1", "--", "Slow", "Tx0", "Trg", "No", "Raise 32 Units"],
    149: ["Ext", "WR", "--", "Slow", "Tx0", "Trg", "No", "Raise 32 Units"],
    144: ["Ext", "W1", "--", "Slow", "Tx0", "Trg", "No", "Raise 32 Units"],
    68: ["Reg", "SR", "--", "Slow", "Tx0", "Trg", "No", "Raise Next Floor"],
    20: ["Reg", "S1", "--", "Slow", "Tx0", "Trg", "No", "Raise Next Floor"],
    95: ["Reg", "WR", "--", "Slow", "Tx0", "Trg", "No", "Raise Next Floor"],
    22: ["Reg", "W1", "--", "Slow", "Tx0", "Trg", "No", "Raise Next Floor"],
    47: ["Reg", "G1", "--", "Slow", "Tx0", "Trg", "No", "Raise Next Floor"],
    181: ["Ext", "SR", "3s", "Slow", "None", "--", "No", "Lowest and Highest Floor (perpetual)"],
    162: ["Ext", "S1", "3s", "Slow", "None", "--", "No", "Lowest and Highest Floor (perpetual)"],
    87: ["Reg", "WR", "3s", "Slow", "None", "--", "No", "Lowest and Highest Floor (perpetual)"],
    53: ["Reg", "W1", "3s", "Slow", "None", "--", "No", "Lowest and Highest Floor (perpetual)"],
    182: ["Ext", "SR", "--", "----", "----", "--", "--", "Stop"],
    163: ["Ext", "S1", "--", "----", "----", "--", "--", "Stop"],
    89: ["Reg", "WR", "--", "----", "----", "--", "--", "Stop"],
    54: ["Reg", "W1", "--", "----", "----", "--", "--", "Stop"],
    62: ["Reg", "SR", "3s", "Slow", "None", "--", "No", "Lowest Neighbor Floor (lift)"],
    21: ["Reg", "S1", "3s", "Slow", "None", "--", "No", "Lowest Neighbor Floor (lift)"],
    88: ["Reg", "WR", "3s", "Slow", "None", "--", "No", "Lowest Neighbor Floor (lift)"],
    10: ["Reg", "W1", "3s", "Slow", "None", "--", "No", "Lowest Neighbor Floor (lift)"],
    123: ["Reg", "SR", "3s", "Fast", "None", "--", "No", "Lowest Neighbor Floor (lift)"],
    122: ["Reg", "S1", "3s", "Fast", "None", "--", "No", "Lowest Neighbor Floor (lift)"],
    120: ["Reg", "WR", "3s", "Fast", "None", "--", "No", "Lowest Neighbor Floor (lift)"],
    121: ["Reg", "W1", "3s", "Fast", "None", "--", "No", "Lowest Neighbor Floor (lift)"],
    211: ["Ext", "SR", "--", "Inst", "None", "--", "No", "Ceiling (toggle)"],
    212: ["Ext", "WR", "--", "Inst", "None", "--", "No", "Ceiling (toggle)"],
}

crusher_types = {
    184: ["Ext", "SR", "Slow", "No", "No", "Start"],
    49: ["Reg", "S1", "Slow", "No", "No", "Start"],
    73: ["Reg", "WR", "Slow", "No", "No", "Start"],
    25: ["Reg", "W1", "Slow", "No", "No", "Start"],
    183: ["Ext", "SR", "Fast", "No", "No", "Start"],
    164: ["Ext", "S1", "Fast", "No", "No", "Start"],
    77: ["Reg", "WR", "Fast", "No", "No", "Start"],
    6: ["Reg", "W1", "Fast", "No", "No", "Start"],
    185: ["Ext", "SR", "Slow", "No", "Yes", "Start"],
    165: ["Ext", "S1", "Slow", "No", "Yes", "Start"],
    150: ["Ext", "WR", "Slow", "No", "Yes", "Start"],
    141: ["Reg", "W1", "Slow", "No", "Yes", "Start"],
    188: ["Ext", "SR", "----", "--", "--", "Stop"],
    168: ["Ext", "S1", "----", "--", "--", "Stop"],
    74: ["Reg", "WR", "----", "--", "--", "Stop"],
    57: ["Reg", "W1", "----", "--", "--", "Stop"],
}

stair_types = {
    258: ["Ext", "SR", "Up", "Slow", "8", "No", "No"],
    7: ["Reg", "S1", "Up", "Slow", "8", "No", "No"],
    256: ["Ext", "WR", "Up", "Slow", "8", "No", "No"],
    8: ["Reg", "W1", "Up", "Slow", "8", "No", "No"],
    259: ["Ext", "SR", "Up", "Fast", "16", "No", "No"],
    127: ["Reg", "S1", "Up", "Fast", "16", "No", "No"],
    257: ["Ext", "WR", "Up", "Fast", "16", "No", "No"],
    100: ["Reg", "W1", "Up", "Fast", "16", "No", "No"],
}

elevator_types = {
    230: ["Ext", "SR", "Fast", "Next Highest Floor"],
    229: ["Ext", "S1", "Fast", "Next Highest Floor"],
    228: ["Ext", "WR", "Fast", "Next Highest Floor"],
    227: ["Ext", "W1", "Fast", "Next Highest Floor"],
    234: ["Ext", "SR", "Fast", "Next Lowest Floor"],
    233: ["Ext", "S1", "Fast", "Next Lowest Floor"],
    232: ["Ext", "WR", "Fast", "Next Lowest Floor"],
    231: ["Ext", "W1", "Fast", "Next Lowest Floor"],
    238: ["Ext", "SR", "Fast", "Current Floor"],
    237: ["Ext", "S1", "Fast", "Current Floor"],
    236: ["Ext", "WR", "Fast", "Current Floor"],
    235: ["Ext", "W1", "Fast", "Current Floor"],
}

thing_types = {
    1: ["1", "S", "16", "PLAY", "+", "", "Player 1 start"],
    2: ["2", "S", "16", "PLAY", "+", "", "Player 2 start"],
    3: ["3", "S", "16", "PLAY", "+", "", "Player 3 start"],
    4: ["4", "S", "16", "PLAY", "+", "", "Player 4 start"],
    5: ["5", "S", "20", "BKEY", "AB", "P", "Blue keycard"],
    6: ["6", "S", "20", "YKEY", "AB", "P", "Yellow keycard"],
    7: ["7", "R", "128", "SPID", "+", "MO", "Spider Mastermind"],
    8: ["8", "S", "20", "BPAK", "A", "P", "Backpack"],
    9: ["9", "S", "20", "SPOS", "+", "MO", "Former Human Sergeant"],
    10: ["A", "S", "16", "PLAY", "W", "", "Bloody mess"],
    11: ["B", "S", "20", "none", "-", "", "Deathmatch start"],
    12: ["C", "S", "16", "PLAY", "W", "", "Bloody mess"],
    13: ["D", "S", "20", "RKEY", "AB", "P", "Red keycard"],
    14: ["E", "S", "20", "none1", "-", "", "Teleport landing"],
    15: ["F", "S", "16", "PLAY", "N", "", "Dead player"],
    16: ["10", "R", "40", "CYBR", "+", "MO", "Cyberdemon"],
    17: ["11", "R", "20", "CELP", "A", "P2", "Cell charge pack"],
    18: ["12", "S", "20", "POSS", "L", "", "Dead former human"],
    19: ["13", "S", "20", "SPOS", "L", "", "Dead former sergeant"],
    20: ["14", "S", "20", "TROO", "M", "", "Dead imp"],
    21: ["15", "S", "30", "SARG", "N", "", "Dead demon"],
    22: ["16", "R", "31", "HEAD", "L", "", "Dead cacodemon"],
    23: ["17", "R", "16", "SKUL", "K", "", "Dead lost soul (invisible)"],
    24: ["18", "S", "16", "POL5", "A", "", "Pool of blood and flesh"],
    25: ["19", "R", "16", "POL1", "A", "O", "Impaled human"],
    26: ["1A", "R", "16", "POL6", "AB", "O", "Twitching impaled human"],
    27: ["1B", "R", "16", "POL4", "A", "O", "Skull on a pole"],
    28: ["1C", "R", "16", "POL2", "A", "O", "Five skulls shish kebab"],
    29: ["1D", "R", "16", "POL3", "AB", "O", "Pile of skulls and candles"],
    30: ["1E", "R", "16", "COL1", "A", "O", "Tall green pillar"],
    31: ["1F", "R", "16", "COL2", "A", "O", "Short green pillar"],
    32: ["20", "R", "16", "COL3", "A", "O", "Tall red pillar"],
    33: ["21", "R", "16", "COL4", "A", "O", "Short red pillar"],
    34: ["22", "S", "16", "CAND", "A", "", "Candle"],
    35: ["23", "S", "16", "CBRA", "A", "O", "Candelabra"],
    36: ["24", "R", "16", "COL5", "AB", "O", "Short green pillar with beating heart"],
    37: ["25", "R", "16", "COL6", "A", "O", "Short red pillar with skull"],
    38: ["26", "R", "20", "RSKU", "AB", "P", "Red skull key"],
    39: ["27", "R", "20", "YSKU", "AB", "P", "Yellow skull key"],
    40: ["28", "R", "20", "BSKU", "AB", "P", "Blue skull key"],
    41: ["29", "R", "16", "CEYE", "ABCB", "O", "Evil eye"],
    42: ["2A", "R", "16", "FSKU", "ABC", "O", "Floating skull"],
    43: ["2B", "R", "16", "TRE1", "A", "O", "Burnt tree"],
    44: ["2C", "R", "16", "TBLU", "ABCD", "O", "Tall blue firestick"],
    45: ["2D", "R", "16", "TGRN", "ABCD", "O", "Tall green firestick"],
    46: ["2E", "S", "16", "TRED", "ABCD", "O", "Tall red firestick"],
    47: ["2F", "R", "16", "SMIT", "A", "O", "Stalagmite"],
    48: ["30", "S", "16", "ELEC", "A", "O", "Tall techno pillar"],
    49: ["31", "R", "16", "GOR1", "ABCB", "O^", "Hanging victim, twitching"],
    50: ["32", "R", "16", "GOR2", "A", "O^", "Hanging victim, arms out"],
    51: ["33", "R", "16", "GOR3", "A", "O^", "Hanging victim, one-legged"],
    52: ["34", "R", "16", "GOR4", "A", "O^", "Hanging pair of legs"],
    53: ["35", "R", "16", "GOR5", "A", "O^", "Hanging leg"],
    54: ["36", "R", "32", "TRE2", "A", "O", "Large brown tree"],
    55: ["37", "R", "16", "SMBT", "ABCD", "O", "Short blue firestick"],
    56: ["38", "R", "16", "SMGT", "ABCD", "O", "Short green firestick"],
    57: ["39", "R", "16", "SMRT", "ABCD", "O", "Short red firestick"],
    58: ["3A", "S", "30", "SARG", "+", "MO", "Spectre"],
    59: ["3B", "R", "16", "GOR2", "A", "^", "Hanging victim, arms out"],
    60: ["3C", "R", "16", "GOR4", "A", "^", "Hanging pair of legs"],
    61: ["3D", "R", "16", "GOR3", "A", "^", "Hanging victim, one-legged"],
    62: ["3E", "R", "16", "GOR5", "A", "^", "Hanging leg"],
    63: ["3F", "R", "16", "GOR1", "ABCB", "^", "Hanging victim, twitching"],
    64: ["40", "2", "20", "VILE", "+", "MO", "Arch-Vile"],
    65: ["41", "2", "20", "CPOS", "+", "MO", "Chaingunner"],
    66: ["42", "2", "20", "SKEL", "+", "MO", "Revenant"],
    67: ["43", "2", "48", "FATT", "+", "MO", "Mancubus"],
    68: ["44", "2", "64", "BSPI", "+", "MO", "Arachnotron"],
    69: ["45", "2", "24", "BOS2", "+", "MO", "Hell Knight"],
    70: ["46", "2", "10", "FCAN", "ABC", "O", "Burning barrel"],
    71: ["47", "2", "31", "PAIN", "+", "MO^", "Pain Elemental"],
    72: ["48", "2", "16", "KEEN", "A+", "MO^", "Commander Keen"],
    73: ["49", "2", "16", "HDB1", "A", "O^", "Hanging victim, guts removed"],
    74: ["4A", "2", "16", "HDB2", "A", "O^", "Hanging victim, guts and brain removed"],
    75: ["4B", "2", "16", "HDB3", "A", "O^", "Hanging torso, looking down"],
    76: ["4C", "2", "16", "HDB4", "A", "O^", "Hanging torso, open skull"],
    77: ["4D", "2", "16", "HDB5", "A", "O^", "Hanging torso, looking up"],
    78: ["4E", "2", "16", "HDB6", "A", "O^", "Hanging torso, brain removed"],
    79: ["4F", "2", "16", "POB1", "A", "", "Pool of blood"],
    80: ["50", "2", "16", "POB2", "A", "", "Pool of blood"],
    81: ["51", "2", "16", "BRS1", "A", "", "Pool of brains"],
    82: ["52", "2", "20", "SGN2", "A", "WP3", "Super shotgun"],
    83: ["53", "2", "20", "MEGA", "ABCD", "AP", "Megasphere"],
    84: ["54", "2", "20", "SSWV", "+", "MO", "Wolfenstein SS"],
    85: ["55", "2", "16", "TLMP", "ABCD", "O", "Tall techno floor lamp"],
    86: ["56", "2", "16", "TLP2", "ABCD", "O", "Short techno floor lamp"],
    87: ["57", "2", "0", "none4", "-", "", "Spawn spot"],
    88: ["58", "2", "16", "BBRN", "+", "O5", "Boss Brain"],
    89: ["59", "2", "20", "none6", "-", "", "Spawn shooter"],
    2001: ["7D1", "S", "20", "SHOT", "A", "WP3", "Shotgun"],
    2002: ["7D2", "S", "20", "MGUN", "A", "WP3", "Chaingun"],
    2003: ["7D3", "S", "20", "LAUN", "A", "WP3", "Rocket launcher"],
    2004: ["7D4", "R", "20", "PLAS", "A", "WP3", "Plasma rifle"],
    2005: ["7D5", "S", "20", "CSAW", "A", "WP7", "Chainsaw"],
    2006: ["7D6", "R", "20", "BFUG", "A", "WP3", "BFG 9000"],
    2007: ["7D7", "S", "20", "CLIP", "A", "P2", "Ammo clip"],
    2008: ["7D8", "S", "20", "SHEL", "A", "P2", "Shotgun shells"],
    2010: ["7DA", "S", "20", "ROCK", "A", "P2", "Rocket"],
    2011: ["7DB", "S", "20", "STIM", "A", "P8", "Stimpack"],
    2012: ["7DC", "S", "20", "MEDI", "A", "P8", "Medikit"],
    2013: ["7DD", "S", "20", "SOUL", "ABCDCB", "AP", "Soul sphere"],
    2014: ["7DE", "S", "20", "BON1", "ABCDCB", "AP", "Health potion"],
    2015: ["7DF", "S", "20", "BON2", "ABCDCB", "AP", "Spiritual armor"],
    2018: ["7E2", "S", "20", "ARM1", "AB", "P9", "Green armor"],
    2019: ["7E3", "S", "20", "ARM2", "AB", "P10", "Blue armor"],
    2022: ["7E6", "R", "20", "PINV", "ABCD", "AP", "Invulnerability"],
    2023: ["7E7", "R", "20", "PSTR", "A", "AP", "Berserk"],
    2024: ["7E8", "S", "20", "PINS", "ABCD", "AP", "Invisibility"],
    2025: ["7E9", "S", "20", "SUIT", "A", "P", "Radiation suit"],
    2026: ["7EA", "S", "20", "PMAP", "ABCDCB", "AP11", "Computer map"],
    2028: ["7EC", "S", "16", "COLU", "A", "O", "Floor lamp"],
    2035: ["7F3", "S", "10", "BAR1", "AB+", "O", "Barrel"],
    2045: ["7FD", "S", "20", "PVIS", "AB", "AP", "Light amplification visor"],
    2046: ["7FE", "S", "20", "BROK", "A", "P2", "Box of rockets"],
    2047: ["7FF", "R", "20", "CELL", "A", "P2", "Cell charge"],
    2048: ["800", "S", "20", "AMMO", "A", "P2", "Box of ammo"],
    2049: ["801", "S", "20", "SBOX", "A", "P2", "Box of shells"],
    3001: ["BB9", "S", "20", "TROO", "+", "MO", "Imp"],
    3002: ["BBA", "S", "30", "SARG", "+", "MO", "Demon"],
    3003: ["BBB", "S", "24", "BOSS", "+", "MO", "Baron of Hell"],
    3004: ["BBC", "S", "20", "POSS", "+", "MO", "Former Human Trooper"],
    3005: ["BBD", "R", "31", "HEAD", "+", "MO^", "Cacodemon"],
    3006: ["BBE", "R", "16", "SKUL", "+", "M12O^", "Lost Soul"],
}

# fmt: on


class FileLump:
    record_format = "<ii8s"

    def __init__(self, f):
        (self.filepos, self.size, self.name,) = get(f, self.record_format)
        self.name = tos(self.name)

    def __str__(self):
        return f"Lump {self.name:8s} pos:{self.filepos:8d} size:{self.size:8d}"


class LineDefFlagsBits(ctypes.LittleEndianStructure):
    _fields_ = [
        ("blocks_players_monsters", c_uint8, 1),
        ("blocks_monsters", c_uint8, 1),
        ("two_sided", c_uint8, 1),
        ("upper_unpegged", c_uint8, 1),
        ("lower_unpegged", c_uint8, 1),
        ("secret", c_uint8, 1),
        ("blocks_sound", c_uint8, 1),
        ("automap_never", c_uint8, 1),
        ("automap_always", c_uint8, 1),
    ]


class LineDef:
    record_format = "<hhhhhHH"

    class Flags(ctypes.Union):
        _fields_ = [("b", LineDefFlagsBits), ("asbyte", c_uint8)]

    def __init__(self, f, map):
        self.map = map
        (
            self.start_vertex_id,
            self.end_vertex_id,
            self.flags,
            self.special_type,
            self.sector_tag,
            self.front_sidedef_id,
            self.back_sidedef_id,
        ) = get(f, LineDef.record_format)
        flags = self.Flags()
        flags.asbyte = self.flags
        self.flags = flags

    @property
    def front_sidedef(self):
        return self.map.sidedefs[self.front_sidedef_id]

    @property
    def back_sidedef(self):
        return (
            self.map.sidedefs[self.back_sidedef_id]
            if self.back_sidedef_id < 65535
            else None
        )

    @property
    def vertexes(self):
        return [
            self.map.get_vertex(self.start_vertex_id),
            self.map.get_vertex(self.end_vertex_id),
        ]

    @property
    def blocks_players(self):
        return self.flags

    def length(self):
        v1, v2 = self.vertexes
        dx = v2[0] - v1[0]
        dy = v2[1] - v1[1]
        return math.sqrt(dx * dx + dy * dy)

    def __str__(self):
        return f"LineDef {self.start_vertex_id}->{self.end_vertex_id} {self.front_sidedef_id} {self.back_sidedef_id}"

    def flip(self):
        self.start_vertex_id, self.end_vertex_id = (
            self.end_vertex_id,
            self.start_vertex_id,
        )
        self.front_sidedef_id, self.back_sidedef_id = (
            self.back_sidedef_id,
            self.front_sidedef_id,
        )

    def reorient(self):
        if self.back_sidedef:
            lower_raise = (
                self.back_sidedef.sector.floor_height
                - self.front_sidedef.sector.floor_height
            )
            if lower_raise < 0:
                self.flip()


class SideDef:
    record_format = "<hh8s8s8sh"

    def __init__(self, f, map):
        self.map = map
        (
            self.x_offset,
            self.y_offset,
            self.upper_texture_name,
            self.lower_texture_name,
            self.middle_texture_name,
            self.sector_id,
        ) = get(f, SideDef.record_format)
        self.upper_texture_name = tos(self.upper_texture_name)
        self.lower_texture_name = tos(self.lower_texture_name)
        self.middle_texture_name = tos(self.middle_texture_name)

    @property
    def sector(self):
        return self.map.sectors[self.sector_id]

    @property
    def upper_texture(self):
        return self.map.wad.get_texture(self.upper_texture_name)

    @property
    def middle_texture(self):
        return self.map.wad.get_texture(self.middle_texture_name)

    @property
    def lower_texture(self):
        return self.map.wad.get_texture(self.lower_texture_name)

    def __str__(self):
        return f"SideDef {self.x_offset} {self.y_offset} {self.upper_texture_name} {self.lower_texture_name} {self.middle_texture_name} {self.sector_id}"


class Vertex:
    record_format = "<hh"

    def __init__(self, f):
        (self.x, self.y,) = get(f, Vertex.record_format)

    def __str__(self):
        return f"Vertex {self.x} {self.y}"


class Thing:
    record_format = "<hhhhh"

    def __init__(self, f, map):
        self.map = map
        (self.x, self.y, self.angle, self.type, self.flags) = get(
            f, Thing.record_format
        )

    def __str__(self):
        return f"Thing {self.x} {self.y} {self.angle} {self.type} {self.flags}"


class Sector:
    record_format = "<hh8s8shhh"

    def __init__(self, f, map):
        self.map = map
        (
            self._floor_height,
            self._ceiling_height,
            self.floor_texture_name,
            self.ceiling_texture_name,
            self.light_level,
            self.special_type,
            self.tag_number,
        ) = get(f, Sector.record_format)
        self.floor_texture_name = tos(self.floor_texture_name)
        self.ceiling_texture_name = tos(self.ceiling_texture_name)
        self._floor_height = [self._floor_height,] * 2
        self._ceiling_height = [self._ceiling_height,] * 2

    @property
    def floor_height(self):
        return (
            self.map.phase * (self._floor_height[1] - self._floor_height[0])
            + self._floor_height[0]
        )

    @property
    def ceiling_height(self):
        return (
            self.map.phase * (self._ceiling_height[1] - self._ceiling_height[0])
            + self._ceiling_height[0]
        )

    @property
    def floor_texture(self):
        return self.map.wad.get_flat(self.floor_texture_name)

    @property
    def ceiling_texture(self):
        if is_sky(self.ceiling_texture_name):
            sky_number = int(self.map.name[1])
            return self.map.wad.get_texture(f"SKY{sky_number}")
        else:
            return self.map.wad.get_flat(self.ceiling_texture_name)

    def __str__(self):
        return f"Sector {self.floor_height} {self.ceiling_height} {self.floor_texture_name} {self.ceiling_texture_name} {self.light_level} {self.special_type} {self.tag_number}"

    def neighbors(self):
        neighbors = []
        for linedef in self.map.linedefs:
            front_sidedef = linedef.front_sidedef
            back_sidedef = linedef.back_sidedef
            if not back_sidedef:
                continue
            if front_sidedef.sector is self:
                neighbors.append(back_sidedef.sector)
            elif back_sidedef.sector is self:
                neighbors.append(front_sidedef.sector)
        return neighbors


class Flat:
    record_format = "<4096B"

    def __init__(self, f, name, wad):
        self.wad = wad
        self.name = name
        self.width = 64
        self.height = 64
        self.pixels = get(f, Flat.record_format)

    def __str__(self):
        return f"Flat {self.name:8s} {len(self.pixels)}"


class PlayPal:
    record_format = "<768B"

    def __init__(self, f, wad):
        self.wad = wad
        self.colors = get(f, PlayPal.record_format)
        self.colors = list(zip(self.colors[0::3], self.colors[1::3], self.colors[2::3]))

    def __str__(self):
        return f"PlayPal {len(self.colors)}"


class Patch:
    def __init__(self, f, name, wad):
        self.name = name
        pos = f.tell()
        (self.width, self.height, self.left_offset, self.top_offset) = get(f, "<HHhh")
        self.columns = []
        columnofs = get(f, f"<{self.width}I")
        for offset in columnofs:
            f.seek(pos + offset)
            self.columns.append([])
            while True:
                (topdelta,) = get(f, "<B")
                if topdelta == 255:
                    break
                length, _ = get(f, "<BB")
                data = get(f, f"<{length}B")
                _ = get(f, f"<B")
                self.columns[-1].append((topdelta, data))

    def __str__(self):
        return f"Patch w:{self.width} h:{self.height} x:{self.left_offset} y:{self.top_offset}"

    @property
    def pixels(self):
        data = [[-1] * self.width for _ in range(self.height)]
        for x, column in enumerate(self.columns):
            for post in column:
                for i in range(len(post[1])):
                    data[i + post[0]][x] = post[1][i]
        return data


class MapPatch:
    record_format = "<hhhhh"

    def __init__(self, f, texture):
        self.texture = texture
        (self.originx, self.originy, self.patch, self.stepdir, self.colormap,) = get(
            f, MapPatch.record_format
        )

    def __str__(self):
        return f"MapPatch x:{self.originx} y:{self.originy} p:{self.patch} s:{self.stepdir} c:{self.colormap}"


class Texture:
    def __init__(self, f, wad):
        self.wad = wad
        (
            self.name,
            self.masked,
            self.width,
            self.height,
            self.columndirectory,
            self.patchcount,
        ) = get(f, "<8sIHHIH")
        self.patches = []
        self.name = tos(self.name)
        for _ in range(self.patchcount):
            self.patches.append(MapPatch(f, self))

    def __str__(self):
        return f"Texture {self.name} {self.masked} {self.width} {self.height} {self.columndirectory} {self.patchcount}"

    @property
    def pixels(self):
        pixels = [[-1] * self.width for _ in range(self.height)]
        for patchm in self.patches:
            name = self.wad.pnames[patchm.patch]
            patch = self.wad.patches[name]
            patch_pixels = patch.pixels
            for x in range(self.width):
                for y in range(self.height):
                    xp = x - patchm.originx  # + patch.left_offset
                    yp = y - patchm.originy  # + patch.top_offset
                    if 0 <= xp and xp < patch.width:
                        if 0 <= yp and yp < patch.height:
                            value = patch_pixels[yp][xp]
                            if value >= 0:
                                pixels[y][x] = value
        return pixels


class Map:
    name = None
    things = []
    linedefs = []
    sidedefs = []
    vertexes = []
    sectors = []
    phase = 0

    def __init__(self, name, wad):
        self.wad = wad
        self.name = name

    def get_vertex(self, id):
        v = self.vertexes[id]
        return [v.x, v.y]


class Wad:
    def __init__(self, wad_file):
        self.maps = []
        self.colormaps = []
        self.playpals = []
        self.flats = None
        self.patches = None
        self.sprites = None
        self.textures = []
        self.pnames = []
        self.wad_format = "DOOM"
        with open(wad_file, "rb") as f:
            (self.infotableofs, self.numlumps, self.infotableofs) = get(f, "<4sii")

            self.filelumps = []
            for i in range(self.numlumps):
                filelump_size = struct.calcsize(FileLump.record_format)
                f.seek(self.infotableofs + i * filelump_size)
                self.filelumps.append(FileLump(f))
                # print(self.filelumps[-1])

            self.maps = []

            filelump = None
            lump_iterator = iter(self.filelumps)

            def nextlump():
                nonlocal filelump
                filelump = next(lump_iterator)

            def lump_array(prefix, record):
                results = []
                try:
                    while True:
                        if filelump.name == prefix + "_END":
                            break
                        elif re.match(prefix + r"[12]_(START|END)", filelump.name):
                            nextlump()
                        else:
                            f.seek(filelump.filepos)
                            results.append(record(f, filelump.name, self))
                            nextlump()
                except StopIteration:
                    assert False, "Missing terminator " + prefix + "_END"
                return results

            nextlump()
            try:
                while True:
                    if re.match("E\dM\d|MAP\d\d", filelump.name):
                        map = Map(filelump.name, self)

                        while True:
                            nextlump()
                            if filelump.name == "THINGS":
                                map.things = unpack_array(f, filelump, Thing, map)
                            elif filelump.name == "LINEDEFS":
                                map.linedefs = unpack_array(f, filelump, LineDef, map)
                            elif filelump.name == "SIDEDEFS":
                                map.sidedefs = unpack_array(f, filelump, SideDef, map)
                            elif filelump.name == "VERTEXES":
                                map.vertexes = unpack_array(f, filelump, Vertex)
                            elif filelump.name == "SEGS":
                                pass
                            elif filelump.name == "SEGS":
                                pass
                            elif filelump.name == "SSECTORS":
                                pass
                            elif filelump.name == "NODES":
                                pass
                            elif filelump.name == "SECTORS":
                                map.sectors = unpack_array(f, filelump, Sector, map)
                            elif filelump.name == "REJECT":
                                pass
                            elif filelump.name == "BLOCKMAP":
                                pass
                            else:
                                break

                        self.maps.append(map)
                    elif filelump.name == "PLAYPAL":
                        self.playpals = unpack_array(f, filelump, PlayPal, self)
                        nextlump()
                    elif filelump.name == "TEXTURE1" or filelump.name == "TEXTURE2":
                        f.seek(filelump.filepos)
                        (numtextures,) = get(f, "<i")
                        offsets = get(f, f"<{numtextures}i")
                        for ofs in offsets:
                            f.seek(filelump.filepos + ofs)
                            self.textures.append(Texture(f, self))
                        nextlump()
                    elif filelump.name == "COLORMAP":
                        # 34 x 256 colormaps
                        self.colormaps = get(f, "<8704B")
                        self.colormaps = [
                            self.colormaps[i : i + 256]
                            for i in range(0, len(self.colormaps), 256)
                        ]
                        nextlump()
                    elif filelump.name == "PNAMES":
                        f.seek(filelump.filepos)
                        (nummappatches,) = get(f, "<i")
                        for _ in range(nummappatches):
                            self.pnames.append(tos(get(f, "<8s")[0]))
                        nextlump()
                    elif filelump.name == "F_START":
                        nextlump()
                        self.flats = lump_array("F", Flat)
                        nextlump()
                    elif filelump.name == "P_START":
                        nextlump()
                        self.patches = lump_array("P", Patch)
                        nextlump()
                    elif filelump.name == "S_START":
                        nextlump()
                        self.sprites = lump_array("S", Patch)
                        nextlump()
                    else:
                        nextlump()
            except StopIteration:
                pass
        self.textures = OrderedDict(zip([t.name for t in self.textures], self.textures))
        self.flats = OrderedDict(zip([t.name for t in self.flats], self.flats))
        self.patches = OrderedDict(zip([t.name for t in self.patches], self.patches))
        self.sprites = OrderedDict(zip([t.name for t in self.sprites], self.sprites))

    def get_texture(self, name):
        if name == "-":
            return None
        return self.textures[name]

    def get_sprite(self, name):
        return self.sprites[name]

    def get_flat(self, name):
        return self.flats[name]

    def get_sidedefs_for_linedef(self, map_id, linedef):
        sidedef_front_id = linedef.front_sidedef_id
        sidedef_back_id = linedef.back_sidedef_id
        sidedef_front = self.maps[map_id].sidedefs[sidedef_front_id]
        sidedef_back = (
            self.maps[map_id].sidedefs[sidedef_back_id]
            if sidedef_back_id < 65535
            else None
        )
        return sidedef_front, sidedef_back

    def print(self):
        for e in wad.maps:
            print("map", e.name)
            print(f"\tLineDefs: {len(e.linedefs)}")
            for linedef in e.linedefs[:3]:
                print("\t\t", linedef)
            print(f"\tSideDefs: {len(e.sidedefs)}")
            for sidedef in e.sidedefs[:3]:
                print("\t\t", sidedef)
            print(f"\tVertexs: {len(e.vertexes)}")
            for vertex in e.vertexes[:3]:
                print("\t\t", vertex)
            print(f"\tSectors: {len(e.sectors)}")
            for sector in e.sectors[:3]:
                print("\t\t", sector)
        print(f"\tFlats: {len(wad.flats)}")
        for flat in wad.flats[:3]:
            print("\t\t", flat)
        print(f"PlayPals: {len(wad.playpals)}")
        for playpal in wad.playpals[:3]:
            print("\t", playpal)
        print(f"Colormap: {len(wad.colormaps)}")
        for i in wad.colormaps[:3]:
            print("\t", i)
        print(f"Patches: {len(wad.patches)}")
        for patch in wad.patches[:3]:
            print("\t", patch)
        print(f"Textures: {len(wad.textures)}")
        for texture in wad.textures[:3]:
            print("\t", texture)


wad = Wad(sys.argv[1])


def make_door_animation(door_linedef):
    door_type = door_types[door_linedef.special_type]
    door_sectors = []
    if door_type[1][0] == "P":
        if door_linedef.back_sidedef is not None:
            door_sectors = [door_linedef.back_sidedef.sector]
    else:
        sectors = door_linedef.map.sectors
        door_sectors = [s for s in sectors if s.tag_number == door_linedef.sector_tag]

    for door_sector in door_sectors:
        floor_height = door_sector.floor_height
        ceiling_height = 100_000

        for linedef in door_linedef.map.linedefs:
            back_sidedef = linedef.back_sidedef
            if back_sidedef and back_sidedef.sector is door_sector:
                ceiling_height = min(
                    linedef.front_sidedef.sector.ceiling_height, ceiling_height
                )

        door_sector._floor_height[1] = floor_height
        door_sector._ceiling_height[1] = ceiling_height


def make_floor_animation(floor_linedef):
    floor_type = floor_types[floor_linedef.special_type]
    sectors = floor_linedef.map.sectors
    floor_sectors = [s for s in sectors if s.tag_number == floor_linedef.sector_tag]
    for floor_sector in floor_sectors:
        ceiling_height = floor_sector.ceiling_height
        floor_height = floor_sector.floor_height
        neighbors = floor_sector.neighbors()

        if floor_type[-1] == "Lowest Neighbor Floor":
            floor_height = min([s.floor_height for s in neighbors + [floor_sector]])

        elif floor_type[-1] == "Next Neighbor Floor" and floor_type[2] == "Dn":
            floor_height = max(
                [s.floor_height for s in neighbors if s.floor_height < floor_height]
            )

        elif floor_type[-1] == "Next Neighbor Floor" and floor_type[2] == "Up":
            floor_height = min(
                [s.floor_height for s in neighbors if s.floor_height > floor_height]
            )

        elif floor_type[-1] == "Lowest Neighbor Ceiling":
            floor_height = min([s.ceiling_height for s in neighbors + [floor_sector]])

        elif floor_type[-1] == "Lowest Neighbor Ceiling - 8":
            floor_height = (
                min([s.ceiling_height for s in neighbors + [floor_sector]]) - 8
            )

        elif floor_type[-1] == "Highest Neighbor Floor":
            floor_height = max([s.floor_height for s in neighbors + [floor_sector]])

        elif floor_type[-1] == "Highest Neighbor Floor + 8":
            floor_height = max([s.floor_height for s in neighbors + [floor_sector]]) + 8

        elif floor_type[-1] == "Absolute 24":
            floor_height += 24 if floor_type[2] == "Up" else -24

        elif floor_type[-1] == "Absolute 512":
            floor_height += 512 if floor_type[2] == "Up" else -512

        floor_sector._floor_height[1] = floor_height
        floor_sector._ceiling_height[1] = ceiling_height


def make_platform_animation(platform_linedef):
    platform_type = platform_types[platform_linedef.special_type]
    sectors = platform_linedef.map.sectors
    platform_sector = next(
        s for s in sectors if s.tag_number == platform_linedef.sector_tag
    )
    ceiling_height = platform_sector.ceiling_height
    floor_height = platform_sector.floor_height
    neighbors = platform_sector.neighbors()

    if platform_type[-1] == "Raise 24 Units":
        floor_height += 24

    elif platform_type[-1] == "Raise 32 Units":
        floor_height += 32

    elif platform_type[-1] == "Raise Next Floor":
        # This means that the "high" height is the lowest surrounding floor
        # higher than the platform. If no higher adjacent floor exists no
        # motion will occur.
        floor_height = min(
            [s.floor_height for s in neighbors if s.floor_height > floor_height]
        )

    elif platform_type[-1] == "Lowest and Highest Floor (perpetual)":
        # This target sets the "low" height to the lowest neighboring
        # floor, including the floor itself, and the "high" height to the
        # highest neighboring floor, including the floor itself. When this
        # target is used the floor moves perpetually between the two
        # heights. Once triggered this type of linedef runs permanently,
        # even if the motion is temporarily suspended with a Stop type. No
        # other floor action can be commanded on the sector after this type
        # is begun.
        floor_height = max([s.floor_height for s in neighbors + [platform_sector]])

    elif platform_type[-1] == "Stop":
        floor_height = 0  # ??

    elif platform_type[-1] == "Lowest Neighbor Floor (lift)":
        # This means that the platforms "low" height is the height of the
        # lowest surrounding floor, including the platform itself. The
        # "high" height is the original height of the floor.
        floor_height = min([s.floor_height for s in neighbors + [platform_sector]])

    elif platform_type[-1] == "Ceiling (toggle)":
        # This target sets the "high" height to the ceiling of the sector
        # and the "low" height to the floor height of the sector and is
        # only used in the instant toggle type that switches the floor
        # between the ceiling and its original height on each activation.
        # This is also the ONLY instant platform type.
        floor_height = ceiling_height

    platform_sector._floor_height[1] = floor_height
    platform_sector._ceiling_height[1] = ceiling_height


def compute_animations(wad):
    for map in wad.maps:
        map.phase = 0
        for linedef in map.linedefs:
            if linedef.special_type in door_types:
                make_door_animation(linedef)
            elif linedef.special_type in floor_types:
                make_floor_animation(linedef)
            elif linedef.special_type in platform_types:
                make_platform_animation(linedef)


compute_animations(wad)


def flatten(pixels):
    if isinstance(pixels[0], Iterable):
        return [pixel for row in pixels for pixel in row]
    else:
        return pixels


def pack_rgb(triplet):
    return triplet[0] * (256 * 256) + triplet[1] * 256 + triplet[2]


def get_world_texture(world, texture):
    if texture is None:
        return -1
    name = texture.name.strip("\x00")
    if name == "-":
        return -1
    if name not in world["textures"]:
        id = len(world["textures"])
        if isinstance(texture, Flat):
            prefix = "flat"
            offset = [0, 0]
        elif isinstance(texture, Texture):
            prefix = "texture"
            offset = [0, 0]
        elif isinstance(texture, Patch):
            prefix = "sprite"
            offset = [texture.left_offset, texture.height - texture.top_offset]
        else:
            assert False
        texture = {
            "id": id,
            "offset": offset,
            "name": f"{prefix}_{name.upper()}",
            "isSky": is_sky(name),
        }
        world["textures"][name] = texture
    return world["textures"][name]["id"]


def export_sectors(wad, map_id):
    map = wad.maps[map_id]
    sectors = []
    for id, wad_sector in enumerate(map.sectors):
        map.phase = 0
        sector = {
            "id": id,
            "bottom": {
                "texture": get_world_texture(world, wad_sector.floor_texture),
                "height": wad_sector.floor_height,
            },
            "top": {
                "texture": get_world_texture(world, wad_sector.ceiling_texture),
                "height": wad_sector.ceiling_height,
            },
            "light": wad_sector.light_level,
        }
        map.phase = 1
        if wad_sector.floor_height != sector["bottom"]["height"]:
            sector["bottom"]["altHeight"] = wad_sector.floor_height
        if wad_sector.ceiling_height != sector["top"]["height"]:
            sector["top"]["altHeight"] = wad_sector.ceiling_height
        sectors.append(sector)
    return sectors


def export_walls(wad, map_id):
    walls = []
    map = wad.maps[map_id]
    for linedef_id, linedef in enumerate(map.linedefs):
        linedef.reorient()

        v1, v2 = linedef.vertexes
        length = linedef.length()
        sidedef_front = linedef.front_sidedef
        sidedef_back = linedef.back_sidedef

        def get_texture_height(name):
            texture = wad.get_texture(name)
            return texture.height if texture else 0

        upper_unpegged = linedef.flags.b.upper_unpegged
        lower_unpegged = linedef.flags.b.lower_unpegged
        upper_texture_height = get_texture_height(sidedef_front.upper_texture_name)
        middle_texture_height = get_texture_height(sidedef_front.middle_texture_name)
        lower_texture_height = get_texture_height(sidedef_front.lower_texture_name)

        # https://doomwiki.org/wiki/Texture_alignment

        def get_uv(t):
            map.phase = t

            ox = sidedef_front.x_offset
            oy = sidedef_front.y_offset
            upper_uv = [[ox + length, 0], [ox, 0]]
            middle_uv = [[ox + length, 0], [ox, 0]]
            lower_uv = [[ox + length, 0], [ox, 0]]

            sector_front = sidedef_front.sector
            if sidedef_back:
                sector_back = sidedef_back.sector
                box = sidedef_back.x_offset
                boy = sidedef_back.y_offset

                # The bottom step always goes up (faces the player on phase=0)
                bottom_raise = sector_back.floor_height - sector_front.floor_height
                assert bottom_raise >= -1e-6 or map.phase == 1

                # The top step can go down (faces the player) or up (does not)
                top_raise = sector_back.ceiling_height - sector_front.ceiling_height

                # midh usually is >=0 but it can also be negative for
                # elevators or similar structures
                midh = min(
                    sector_front.ceiling_height, sector_back.ceiling_height
                ) - max(sector_front.floor_height, sector_back.floor_height)

                if lower_unpegged:
                    # top of lower texture at top of upper wall part
                    lower_uv[1][1] = oy + abs(top_raise) + max(midh, 0)
                    lower_uv[0][1] = lower_uv[1][1] + bottom_raise
                else:
                    # top of lower texture `pegged' at the top of the lower wall part
                    lower_uv[1][1] = oy
                    lower_uv[0][1] = lower_uv[1][1] + bottom_raise

                if upper_unpegged:
                    # top of upper texture at top of the upper wall part
                    upper_uv[1][1] = oy if top_raise < 0 else boy
                    upper_uv[0][1] = upper_uv[1][1] + abs(top_raise)
                else:
                    # bottom of upper texture `pegged' at the bottom of the upper wall part
                    upper_uv[0][1] = (
                        oy if top_raise < 0 else boy
                    ) + upper_texture_height
                    upper_uv[1][1] = upper_uv[0][1] - abs(top_raise)

                if midh >= 0:
                    if lower_unpegged:
                        # bottom of middle texture at bottom of wall
                        middle_uv[0][1] = oy + middle_texture_height
                        middle_uv[1][1] = middle_uv[0][1] - midh
                    else:
                        # top of middle texture `pegged' at top of wall
                        middle_uv[1][1] = oy
                        middle_uv[0][1] = middle_uv[1][1] + midh

            else:
                midh = sector_front.ceiling_height - sector_front.floor_height
                # assert midh >= -1e-5
                if lower_unpegged:
                    # bottom of middle texture at bottom of wall
                    middle_uv[0][1] = oy + middle_texture_height
                    middle_uv[1][1] = middle_uv[0][1] - midh
                else:
                    # top of middle texture `pegged' at top of wall
                    middle_uv[1][1] = oy
                    middle_uv[0][1] = middle_uv[1][1] + midh
                top_raise = -1

            top_texture = (
                sidedef_front.upper_texture
                if top_raise < 0
                else sidedef_back.upper_texture
            )
            mid_texture = sidedef_front.middle_texture
            bottom_texture = sidedef_front.lower_texture

            # A wall between to sky flats is not drawn.
            if sidedef_back:
                if is_sky(sector_front.ceiling_texture.name) and is_sky(
                    sector_back.ceiling_texture.name
                ):
                    top_texture = None

            map.phase = 0
            return (
                lower_uv,
                middle_uv,
                upper_uv,
                bottom_texture,
                mid_texture,
                top_texture,
            )

        (
            lower_uv,
            middle_uv,
            upper_uv,
            bottom_texture,
            mid_texture,
            top_texture,
        ) = get_uv(0)

        wall = {
            "base": [v2, v1],
            "top": {"uv": upper_uv, "texture": get_world_texture(world, top_texture),},
            "middle": {
                "uv": middle_uv,
                "texture": get_world_texture(world, mid_texture),
            },
            "bottom": {
                "uv": lower_uv,
                "texture": get_world_texture(world, bottom_texture),
            },
            "frontSector": sidedef_front.sector_id,
            "backSector": sidedef_back.sector_id if sidedef_back else None,
        }

        (
            lower_uv,
            middle_uv,
            upper_uv,
            bottom_texture,
            mid_texture,
            top_texture,
        ) = get_uv(1)

        if lower_uv != wall["bottom"]["uv"]:
            wall["bottom"]["altUv"] = lower_uv

        if middle_uv != wall["middle"]["uv"]:
            wall["middle"]["altUv"] = middle_uv

        if upper_uv != wall["top"]["uv"]:
            wall["top"]["altUv"] = upper_uv

        walls.append(wall)
    return walls


def export_sprites(wad):
    for wad_sprite in wad.sprites:
        sprite = {
            "name": wad_sprite.name,
            "x": wad_sprite.x_offset,
            "y": wad_sprite.y_offset,
        }


def export_player(wad, map_id):
    map = wad.maps[map_id]
    player = next(thing for thing in map.things if thing.type == 1)
    return {"position": [player.x, player.y], "angle": player.angle / 180 * math.pi}


def export_things(wad, map_id):
    map = wad.maps[map_id]
    things = []
    for thing in map.things:
        sprite_prefix = thing_types[thing.type][3]
        sprite_names = [n for n in wad.sprites.keys() if n.startswith(sprite_prefix)]
        sprite_textures = [
            get_world_texture(world, wad.get_sprite(n)) for n in sprite_names
        ]
        things.append(
            {
                "position": [thing.x, thing.y],
                "angle": thing.angle / 180 * math.pi,
                "textures": sprite_textures,
            }
        )
    return things


def export_palettes(wad):
    palettes = []
    for colormap in wad.colormaps[:32]:
        palettes.append([pack_rgb(wad.playpals[0].colors[entry]) for entry in colormap])
    return palettes


world = {
    "maps": [],
    "textures": {},
    "palettes": export_palettes(wad),
}

for map_id in range(len(wad.maps)):
    map = {
        "name": wad.maps[map_id].name,
        "sectors": export_sectors(wad, map_id),
        "walls": export_walls(wad, map_id),
        "things": export_things(wad, map_id),
        "player": export_player(wad, map_id),
    }
    world["maps"].append(map)

world["textures"] = list(world["textures"].values())

os.makedirs(sys.argv[2], exist_ok=True)

with open(os.path.join(sys.argv[2], "world.json"), "w") as f:
    json.dump(world, f, indent=2, sort_keys=True)


def save_images(records, prefix):
    for record in records.values():
        pixels = flatten(record.pixels)

        colors = [max(p, 0) for p in pixels]
        mask = [p >= 0 for p in pixels]

        im = Image.frombytes("P", (record.width, record.height), bytes(colors), "raw")
        im.putpalette(flatten(wad.playpals[0].colors))
        im.save(os.path.join(sys.argv[2], f"{prefix}_{record.name}.png"))

        if any([m == 0 for m in mask]):
            im = Image.frombytes("P", (record.width, record.height), bytes(mask), "raw")
            im.putpalette([0, 0, 0, 255, 255, 255])
            im.save(os.path.join(sys.argv[2], f"{prefix}_{record.name}_mask.png"))


if True:
    save_images(wad.flats, "flat")
    save_images(wad.textures, "texture")
    save_images(wad.sprites, "sprite")
    # save_images(wad.patches, 'patch')
