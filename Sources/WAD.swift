//  WAD.swift
//  Goom

import Foundation
import OrderedCollections

let thingTypes:
    [Int: (
        hex: String, version: String, radius: Int, height: Int, sprite: String, sequence: String,
        class: String, description: String
    )] = [
        1: ("1", "S", 16, 56, "PLAY", "+", "", "Player 1 start"),
        2: ("2", "S", 16, 56, "PLAY", "+", "", "Player 2 start"),
        3: ("3", "S", 16, 56, "PLAY", "+", "", "Player 3 start"),
        4: ("4", "S", 16, 56, "PLAY", "+", "", "Player 4 start"),
        5: ("5", "S", 20, 16, "BKEY", "AB", "P", "Blue keycard"),
        6: ("6", "S", 20, 16, "YKEY", "AB", "P", "Yellow keycard"),
        7: ("7", "R", 128, 100, "SPID", "+", "MO", "Spider Mastermind"),
        8: ("8", "S", 20, 16, "BPAK", "A", "P", "Backpack"),
        9: ("9", "S", 20, 56, "SPOS", "+", "MO", "Former Human Sergeant"),
        10: ("A", "S", 16, 16, "PLAY", "W", "", "Bloody mess"),
        11: ("B", "S", 20, 56, "none", "-", "", "Deathmatch start"),
        12: ("C", "S", 16, 16, "PLAY", "W", "", "Bloody mess"),
        13: ("D", "S", 20, 16, "RKEY", "AB", "P", "Red keycard"),
        14: ("E", "S", 20, 16, "none1", "-", "", "Teleport landing"),
        15: ("F", "S", 16, 16, "PLAY", "N", "", "Dead player"),
        16: ("10", "R", 40, 110, "CYBR", "+", "MO", "Cyberdemon"),
        17: ("11", "R", 20, 16, "CELP", "A", "P2", "Cell charge pack"),
        18: ("12", "S", 20, 16, "POSS", "L", "", "Dead former human"),
        19: ("13", "S", 20, 16, "SPOS", "L", "", "Dead former sergeant"),
        20: ("14", "S", 20, 16, "TROO", "M", "", "Dead imp"),
        21: ("15", "S", 30, 16, "SARG", "N", "", "Dead demon"),
        22: ("16", "R", 31, 16, "HEAD", "L", "", "Dead cacodemon"),
        23: ("17", "R", 16, 16, "SKUL", "K", "", "Dead lost soul (invisible)"),
        24: ("18", "S", 16, 16, "POL5", "A", "", "Pool of blood and flesh"),
        25: ("19", "R", 16, 16, "POL1", "A", "O", "Impaled human"),
        26: ("1A", "R", 16, 16, "POL6", "AB", "O", "Twitching impaled human"),
        27: ("1B", "R", 16, 16, "POL4", "A", "O", "Skull on a pole"),
        28: ("1C", "R", 16, 16, "POL2", "A", "O", "Five skulls shish kebab"),
        29: ("1D", "R", 16, 16, "POL3", "AB", "O", "Pile of skulls and candles"),
        30: ("1E", "R", 16, 16, "COL1", "A", "O", "Tall green pillar"),
        31: ("1F", "R", 16, 16, "COL2", "A", "O", "Short green pillar"),
        32: ("20", "R", 16, 16, "COL3", "A", "O", "Tall red pillar"),
        33: ("21", "R", 16, 16, "COL4", "A", "O", "Short red pillar"),
        34: ("22", "S", 16, 16, "CAND", "A", "", "Candle"),
        35: ("23", "S", 16, 16, "CBRA", "A", "O", "Candelabra"),
        36: ("24", "R", 16, 16, "COL5", "AB", "O", "Short green pillar with beating heart"),
        37: ("25", "R", 16, 16, "COL6", "A", "O", "Short red pillar with skull"),
        38: ("26", "R", 20, 16, "RSKU", "AB", "P", "Red skull key"),
        39: ("27", "R", 20, 16, "YSKU", "AB", "P", "Yellow skull key"),
        40: ("28", "R", 20, 16, "BSKU", "AB", "P", "Blue skull key"),
        41: ("29", "R", 16, 16, "CEYE", "ABCB", "O", "Evil eye"),
        42: ("2A", "R", 16, 16, "FSKU", "ABC", "O", "Floating skull"),
        43: ("2B", "R", 16, 16, "TRE1", "A", "O", "Burnt tree"),
        44: ("2C", "R", 16, 16, "TBLU", "ABCD", "O", "Tall blue firestick"),
        45: ("2D", "R", 16, 16, "TGRN", "ABCD", "O", "Tall green firestick"),
        46: ("2E", "S", 16, 16, "TRED", "ABCD", "O", "Tall red firestick"),
        47: ("2F", "R", 16, 16, "SMIT", "A", "O", "Stalagmite"),
        48: ("30", "S", 16, 16, "ELEC", "A", "O", "Tall techno pillar"),
        49: ("31", "R", 16, 68, "GOR1", "ABCB", "O^", "Hanging victim, twitching"),
        50: ("32", "R", 16, 84, "GOR2", "A", "O^", "Hanging victim, arms out"),
        51: ("33", "R", 16, 84, "GOR3", "A", "O^", "Hanging victim, one-legged"),
        52: ("34", "R", 16, 68, "GOR4", "A", "O^", "Hanging pair of legs"),
        53: ("35", "R", 16, 52, "GOR5", "A", "O^", "Hanging leg"),
        54: ("36", "R", 32, 16, "TRE2", "A", "O", "Large brown tree"),
        55: ("37", "R", 16, 16, "SMBT", "ABCD", "O", "Short blue firestick"),
        56: ("38", "R", 16, 16, "SMGT", "ABCD", "O", "Short green firestick"),
        57: ("39", "R", 16, 16, "SMRT", "ABCD", "O", "Short red firestick"),
        58: ("3A", "S", 30, 56, "SARG", "+", "MO", "Spectre"),
        59: ("3B", "R", 16, 84, "GOR2", "A", "^", "Hanging victim, arms out"),
        60: ("3C", "R", 16, 68, "GOR4", "A", "^", "Hanging pair of legs"),
        61: ("3D", "R", 16, 52, "GOR3", "A", "^", "Hanging victim, one-legged"),
        62: ("3E", "R", 16, 52, "GOR5", "A", "^", "Hanging leg"),
        63: ("3F", "R", 16, 68, "GOR1", "ABCB", "^", "Hanging victim, twitching"),
        64: ("40", "2", 20, 56, "VILE", "+", "MO", "Arch-Vile"),
        65: ("41", "2", 20, 56, "CPOS", "+", "MO", "Chaingunner"),
        66: ("42", "2", 20, 56, "SKEL", "+", "MO", "Revenant"),
        67: ("43", "2", 48, 64, "FATT", "+", "MO", "Mancubus"),
        68: ("44", "2", 64, 64, "BSPI", "+", "MO", "Arachnotron"),
        69: ("45", "2", 24, 64, "BOS2", "+", "MO", "Hell Knight"),
        70: ("46", "2", 10, 16, "FCAN", "ABC", "O", "Burning barrel"),
        71: ("47", "2", 31, 56, "PAIN", "+", "MO^", "Pain Elemental"),
        72: ("48", "2", 16, 72, "KEEN", "A+", "MO^", "Commander Keen"),
        73: ("49", "2", 16, 88, "HDB1", "A", "O^", "Hanging victim, guts removed"),
        74: ("4A", "2", 16, 88, "HDB2", "A", "O^", "Hanging victim, guts and brain removed"),
        75: ("4B", "2", 16, 64, "HDB3", "A", "O^", "Hanging torso, looking down"),
        76: ("4C", "2", 16, 64, "HDB4", "A", "O^", "Hanging torso, open skull"),
        77: ("4D", "2", 16, 64, "HDB5", "A", "O^", "Hanging torso, looking up"),
        78: ("4E", "2", 16, 64, "HDB6", "A", "O^", "Hanging torso, brain removed"),
        79: ("4F", "2", 16, 16, "POB1", "A", "", "Pool of blood"),
        80: ("50", "2", 16, 16, "POB2", "A", "", "Pool of blood"),
        81: ("51", "2", 16, 16, "BRS1", "A", "", "Pool of brains"),
        82: ("52", "2", 20, 16, "SGN2", "A", "WP3", "Super shotgun"),
        83: ("53", "2", 20, 16, "MEGA", "ABCD", "AP", "Megasphere"),
        84: ("54", "2", 20, 56, "SSWV", "+", "MO", "Wolfenstein SS"),
        85: ("55", "2", 16, 16, "TLMP", "ABCD", "O", "Tall techno floor lamp"),
        86: ("56", "2", 16, 16, "TLP2", "ABCD", "O", "Short techno floor lamp"),
        87: ("57", "2", 20, 32, "none4", "-", "", "Spawn spot"),
        88: ("58", "2", 16, 16, "BBRN", "+", "O5", "Boss Brain"),
        89: ("59", "2", 20, 32, "none6", "-", "", "Spawn shooter"),
        2001: ("7D1", "S", 20, 16, "SHOT", "A", "WP3", "Shotgun"),
        2002: ("7D2", "S", 20, 16, "MGUN", "A", "WP3", "Chaingun"),
        2003: ("7D3", "S", 20, 16, "LAUN", "A", "WP3", "Rocket launcher"),
        2004: ("7D4", "R", 20, 16, "PLAS", "A", "WP3", "Plasma rifle"),
        2005: ("7D5", "S", 20, 16, "CSAW", "A", "WP7", "Chainsaw"),
        2006: ("7D6", "R", 20, 16, "BFUG", "A", "WP3", "BFG 9000"),
        2007: ("7D7", "S", 20, 16, "CLIP", "A", "P2", "Ammo clip"),
        2008: ("7D8", "S", 20, 16, "SHEL", "A", "P2", "Shotgun shells"),
        2010: ("7DA", "S", 20, 16, "ROCK", "A", "P2", "Rocket"),
        2011: ("7DB", "S", 20, 16, "STIM", "A", "P8", "Stimpack"),
        2012: ("7DC", "S", 20, 16, "MEDI", "A", "P8", "Medikit"),
        2013: ("7DD", "S", 20, 16, "SOUL", "ABCDCB", "AP", "Soul sphere"),
        2014: ("7DE", "S", 20, 16, "BON1", "ABCDCB", "AP", "Health potion"),
        2015: ("7DF", "S", 20, 16, "BON2", "ABCDCB", "AP", "Spiritual armor"),
        2018: ("7E2", "S", 20, 16, "ARM1", "AB", "P9", "Green armor"),
        2019: ("7E3", "S", 20, 16, "ARM2", "AB", "P10", "Blue armor"),
        2022: ("7E6", "R", 20, 16, "PINV", "ABCD", "AP", "Invulnerability"),
        2023: ("7E7", "R", 20, 16, "PSTR", "A", "AP", "Berserk"),
        2024: ("7E8", "S", 20, 16, "PINS", "ABCD", "AP", "Invisibility"),
        2025: ("7E9", "S", 20, 16, "SUIT", "A", "P", "Radiation suit"),
        2026: ("7EA", "S", 20, 16, "PMAP", "ABCDCB", "AP11", "Computer map"),
        2028: ("7EC", "S", 16, 16, "COLU", "A", "O", "Floor lamp"),
        2035: ("7F3", "S", 10, 42, "BAR1", "AB+", "O", "Barrel"),
        2045: ("7FD", "S", 20, 16, "PVIS", "AB", "AP", "Light amplification visor"),
        2046: ("7FE", "S", 20, 16, "BROK", "A", "P2", "Box of rockets"),
        2047: ("7FF", "R", 20, 16, "CELL", "A", "P2", "Cell charge"),
        2048: ("800", "S", 20, 16, "AMMO", "A", "P2", "Box of ammo"),
        2049: ("801", "S", 20, 16, "SBOX", "A", "P2", "Box of shells"),
        3001: ("BB9", "S", 20, 56, "TROO", "+", "MO", "Imp"),
        3002: ("BBA", "S", 30, 56, "SARG", "+", "MO", "Demon"),
        3003: ("BBB", "S", 24, 64, "BOSS", "+", "MO", "Baron of Hell"),
        3004: ("BBC", "S", 20, 56, "POSS", "+", "MO", "Former Human Trooper"),
        3005: ("BBD", "R", 31, 56, "HEAD", "+", "MO^", "Cacodemon"),
        3006: ("BBE", "R", 16, 56, "SKUL", "+", "M12O^", "Lost Soul"),
    ]

enum Speed {
    case slow
    case fast
    case inst
    case na
}

let doorTypes:
    [Int: (
        class: String, trigger: String, lock: String, speed: Speed, wait: String, monsters: Bool?,
        function: String
    )] = [
        1: ("Reg", "PR", "No", .slow, "4s", true, "Open, Wait, Then Close"),
        117: ("Reg", "PR", "No", .fast, "4s", false, "Open, Wait, Then Close"),
        63: ("Reg", "SR", "No", .slow, "4s", false, "Open, Wait, Then Close"),
        114: ("Reg", "SR", "No", .fast, "4s", false, "Open, Wait, Then Close"),
        29: ("Reg", "S1", "No", .slow, "4s", false, "Open, Wait, Then Close"),
        111: ("Reg", "S1", "No", .fast, "4s", false, "Open, Wait, Then Close"),
        90: ("Reg", "WR", "No", .slow, "4s", false, "Open, Wait, Then Close"),
        105: ("Reg", "WR", "No", .fast, "4s", false, "Open, Wait, Then Close"),
        4: ("Reg", "W1", "No", .slow, "4s", true, "Open, Wait, Then Close"),
        108: ("Reg", "W1", "No", .fast, "4s", false, "Open, Wait, Then Close"),
        31: ("Reg", "P1", "No", .slow, "--,", false, "Open and Stay Open"),
        118: ("Reg", "P1", "No", .fast, "--", false, "Open and Stay Open"),
        61: ("Reg", "SR", "No", .slow, "--", false, "Open and Stay Open"),
        115: ("Reg", "SR", "No", .fast, "--", false, "Open and Stay Open"),
        103: ("Reg", "S1", "No", .slow, "--", false, "Open and Stay Open"),
        112: ("Reg", "S1", "No", .fast, "--", false, "Open and Stay Open"),
        86: ("Reg", "WR", "No", .slow, "--", false, "Open and Stay Open"),
        106: ("Reg", "WR", "No", .fast, "--", false, "Open and Stay Open"),
        2: ("Reg", "W1", "No", .slow, "--", false, "Open and Stay Open"),
        109: ("Reg", "W1", "No", .fast, "--", false, "Open and Stay Open"),
        46: ("Reg", "GR", "No", .slow, "--", false, "Open and Stay Open"),
        42: ("Reg", "SR", "No", .slow, "--", false, "Close and Stay Closed"),
        116: ("Reg", "SR", "No", .fast, "--", false, "Close and Stay Closed"),
        50: ("Reg", "S1", "No", .slow, "--", false, "Close and Stay Closed"),
        113: ("Reg", "S1", "No", .fast, "--", false, "Close and Stay Closed"),
        75: ("Reg", "WR", "No", .slow, "--", false, "Close and Stay Closed"),
        107: ("Reg", "WR", "No", .fast, "--", false, "Close and Stay Closed"),
        3: ("Reg", "W1", "No", .slow, "--", false, "Close and Stay Closed"),
        110: ("Reg", "W1", "No", .fast, "--", false, "Close and Stay Closed"),
        196: ("Ext", "SR", "No", .slow, "30s", false, "Close, Wait, Then Open"),
        175: ("Ext", "S1", "No", .slow, "30s", false, "Close, Wait, Then Open"),
        76: ("Reg", "WR", "No", .slow, "30s", false, "Close, Wait, Then Open"),
        16: ("Reg", "W1", "No", .slow, "30s", false, "Close, Wait, Then Open"),
        26: ("Reg", "PR", "Blue", .slow, "4s", false, "Open, Wait, Then Close"),
        28: ("Reg", "PR", "Red", .slow, "4s", false, "Open, Wait, Then Close"),
        27: ("Reg", "PR", "Yell", .slow, "4s", false, "Open, Wait, Then Close"),
        32: ("Reg", "P1", "Blue", .slow, "--", false, "Open and Stay Open"),
        33: ("Reg", "P1", "Red", .slow, "--", false, "Open and Stay Open"),
        34: ("Reg", "P1", "Yell", .slow, "--", false, "Open and Stay Open"),
        99: ("Reg", "SR", "Blue", .fast, "--", false, "Open and Stay Open"),
        134: ("Reg", "SR", "Red", .fast, "--", false, "Open and Stay Open"),
        136: ("Reg", "SR", "Yell", .fast, "--", false, "Open and Stay Open"),
        133: ("Reg", "S1", "Blue", .fast, "--", false, "Open and Stay Open"),
        135: ("Reg", "S1", "Red", .fast, "--", false, "Open and Stay Open"),
        137: ("Reg", "S1", "Yell", .fast, "--", false, "Open and Stay Open"),
    ]

enum FloorTarget  {
    case lowestNeighborFloor
    case highestNeighborFloor
    case highestNeighborFloorPlus8
    case nextNeighborFloor
    case lowestNeighborCeiling
    case lowestNeighborCeilingMinus8
    case absolute24
    case absolute512
    case absoluteShortestLowerTexture
    case none
}

let floorTypes:
    [Int: (
        class: String, trigger: String, direction: String, speed: Speed, chg: String, mdl: String,
        monsters: Bool, crushing: Bool, target: FloorTarget
    )] = [
        60: ("Reg", "SR", "Dn", .slow, "None", "--", false, false, .lowestNeighborFloor),
        23: ("Reg", "S1", "Dn", .slow, "None", "--", false, false, .lowestNeighborFloor),
        82: ("Reg", "WR", "Dn", .slow, "None", "--", false, false, .lowestNeighborFloor),
        38: ("Reg", "W1", "Dn", .slow, "None", "--", false, false, .lowestNeighborFloor),
        177: ("Ext", "SR", "Dn", .slow, "TxTy", "Num", false, false, .lowestNeighborFloor),
        159: ("Ext", "S1", "Dn", .slow, "TxTy", "Num", false, false, .lowestNeighborFloor),
        84: ("Reg", "WR", "Dn", .slow, "TxTy", "Num", false, false, .lowestNeighborFloor),
        37: ("Reg", "W1", "Dn", .slow, "TxTy", "Num", false, false, .lowestNeighborFloor),
        69: ("Reg", "SR", "Up", .slow, "None", "--", false, false, .nextNeighborFloor),
        18: ("Reg", "S1", "Up", .slow, "None", "--", false, false, .nextNeighborFloor),
        128: ("Reg", "WR", "Up", .slow, "None", "--", false, false, .nextNeighborFloor),
        119: ("Reg", "W1", "Up", .slow, "None", "--", false, false, .nextNeighborFloor),
        132: ("Reg", "SR", "Up", .fast, "None", "--", false, false, .nextNeighborFloor),
        131: ("Reg", "S1", "Up", .fast, "None", "--", false, false, .nextNeighborFloor),
        129: ("Reg", "WR", "Up", .fast, "None", "--", false, false, .nextNeighborFloor),
        130: ("Reg", "W1", "Up", .fast, "None", "--", false, false, .nextNeighborFloor),
        222: ("Ext", "SR", "Dn", .slow, "None", "--", false, false, .nextNeighborFloor),
        221: ("Ext", "S1", "Dn", .slow, "None", "--", false, false, .nextNeighborFloor),
        220: ("Ext", "WR", "Dn", .slow, "None", "--", false, false, .nextNeighborFloor),
        219: ("Ext", "W1", "Dn", .slow, "None", "--", false, false, .nextNeighborFloor),
        64: ("Reg", "SR", "Up", .slow, "None", "--", false, false, .lowestNeighborCeiling),
        101: ("Reg", "S1", "Up", .slow, "None", "--", false, false, .lowestNeighborCeiling),
        91: ("Reg", "WR", "Up", .slow, "None", "--", false, false, .lowestNeighborCeiling),
        5: ("Reg", "W1", "Up", .slow, "None", "--", false, false, .lowestNeighborCeiling),
        24: ("Reg", "G1", "Up", .slow, "None", "--", false, false, .lowestNeighborCeiling),
        65: ("Reg", "SR", "Up", .slow, "None", "--", false, true, .lowestNeighborCeilingMinus8),
        55: ("Reg", "S1", "Up", .slow, "None", "--", false, true, .lowestNeighborCeilingMinus8),
        94: ("Reg", "WR", "Up", .slow, "None", "--", false, true, .lowestNeighborCeilingMinus8),
        56: ("Reg", "W1", "Up", .slow, "None", "--", false, true, .lowestNeighborCeilingMinus8),
        45: ("Reg", "SR", "Dn", .slow, "None", "--", false, false, .highestNeighborFloor),
        102: ("Reg", "S1", "Dn", .slow, "None", "--", false, false, .highestNeighborFloor),
        83: ("Reg", "WR", "Dn", .slow, "None", "--", false, false, .highestNeighborFloor),
        19: ("Reg", "W1", "Dn", .slow, "None", "--", false, false, .highestNeighborFloor),
        70: ("Reg", "SR", "Dn", .fast, "None", "--", false, false, .highestNeighborFloorPlus8),
        71: ("Reg", "S1", "Dn", .fast, "None", "--", false, false, .highestNeighborFloorPlus8),
        98: ("Reg", "WR", "Dn", .fast, "None", "--", false, false, .highestNeighborFloorPlus8),
        36: ("Reg", "W1", "Dn", .fast, "None", "--", false, false, .highestNeighborFloorPlus8),
        180: ("Ext", "SR", "Up", .slow, "None", "--", false, false, .absolute24),
        161: ("Ext", "S1", "Up", .slow, "None", "--", false, false, .absolute24),
        92: ("Reg", "WR", "Up", .slow, "None", "--", false, false, .absolute24),
        58: ("Reg", "W1", "Up", .slow, "None", "--", false, false, .absolute24),
        179: ("Ext", "SR", "Up", .slow, "TxTy", "Trg", false, false, .absolute24),
        160: ("Ext", "S1", "Up", .slow, "TxTy", "Trg", false, false, .absolute24),
        93: ("Reg", "WR", "Up", .slow, "TxTy", "Trg", false, false, .absolute24),
        59: ("Reg", "W1", "Up", .slow, "TxTy", "Trg", false, false, .absolute24),
        176: ("Ext", "SR", "Up", .slow, "None", "--", false, false, .absoluteShortestLowerTexture),
        158: ("Ext", "S1", "Up", .slow, "None", "--", false, false, .absoluteShortestLowerTexture),
        96: ("Reg", "WR", "Up", .slow, "None", "--", false, false, .absoluteShortestLowerTexture),
        30: ("Reg", "W1", "Up", .slow, "None", "--", false, false, .absoluteShortestLowerTexture),
        178: ("Ext", "SR", "Up", .slow, "None", "--", false, false, .absolute512),
        140: ("Reg", "S1", "Up", .slow, "None", "--", false, false, .absolute512),
        147: ("Ext", "WR", "Up", .slow, "None", "--", false, false, .absolute512),
        142: ("Ext", "W1", "Up", .slow, "None", "--", false, false, .absolute512),
        190: ("Ext", "SR", "--", .na, "TxTy", "Trg", false, false, .none),
        189: ("Ext", "S1", "--", .na, "TxTy", "Trg", false, false, .none),
        154: ("Ext", "WR", "--", .na, "TxTy", "Trg", false, false, .none),
        153: ("Ext", "W1", "--", .na, "TxTy", "Trg", false, false, .none),
        78: ("Ext", "SR", "--", .na, "TxTy", "Num", false, false, .none),
        241: ("Ext", "S1", "--", .na, "TxTy", "Num", false, false, .none),
        240: ("Ext", "WR", "--", .na, "TxTy", "Num", false, false, .none),
        239: ("Ext", "W1", "--", .na, "TxTy", "Num", false, false, .none),
    ]

enum CeilingTarget  {
    case floor
    case highestNeighborCeiling
    case eightAboveFloor
    case lowestNeighborFloor
    case highestNeighborFloor
    case lowestNeighborCeiling
    case none
}


let ceilingTypes:
    [Int: (
        class: String, trigger: String, direction: String, speed: Speed, chg: String, mdl: String,
        monsters: Bool, crushnig: Bool, target: CeilingTarget
    )] =
        [
            43: ("Reg", "SR", "Dn", .fast, "None", "--", false, false, .floor),
            41: ("Reg", "S1", "Dn", .fast, "None", "--", false, false, .floor),
            152: ("Ext", "WR", "Dn", .fast, "None", "--", false, false, .floor),
            145: ("Ext", "W1", "Dn", .fast, "None", "--", false, false, .floor),
            186: ("Ext", "SR", "Up", .slow, "None", "--", false, false, .highestNeighborCeiling),
            166: ("Ext", "S1", "Up", .slow, "None", "--", false, false, .highestNeighborCeiling),
            151: ("Ext", "WR", "Up", .slow, "None", "--", false, false, .highestNeighborCeiling),
            40: ("Reg", "W1", "Up", .slow, "None", "--", false, false, .highestNeighborCeiling),
            187: ("Ext", "SR", "Dn", .slow, "None", "--", false, false, .eightAboveFloor),
            167: ("Ext", "S1", "Dn", .slow, "None", "--", false, false, .eightAboveFloor),
            72: ("Reg", "WR", "Dn", .slow, "None", "--", false, false, .eightAboveFloor),
            44: ("Reg", "W1", "Dn", .slow, "None", "--", false, false, .eightAboveFloor),
            205: ("Ext", "SR", "Dn", .slow, "None", "--", false, false, .lowestNeighborCeiling),
            203: ("Ext", "S1", "Dn", .slow, "None", "--", false, false, .lowestNeighborCeiling),
            201: ("Ext", "WR", "Dn", .slow, "None", "--", false, false, .lowestNeighborCeiling),
            199: ("Ext", "W1", "Dn", .slow, "None", "--", false, false, .lowestNeighborCeiling),
            206: ("Ext", "SR", "Dn", .slow, "None", "--", false, false, .highestNeighborFloor),
            204: ("Ext", "S1", "Dn", .slow, "None", "--", false, false, .highestNeighborFloor),
            202: ("Ext", "WR", "Dn", .slow, "None", "--", false, false, .highestNeighborFloor),
            200: ("Ext", "W1", "Dn", .slow, "None", "--", false, false, .highestNeighborFloor),
        ]

let platformTypes:
    [Int: (
        class: String, trigger: String, direction: String, speed: Speed, chg: String, mdl: String,
        monsters: Bool?, target: String
    )] = [
        66: ("Reg", "SR", "--", .slow, "Tx", "Trg", false, "Raise 24 Units"),
        15: ("Reg", "S1", "--", .slow, "Tx", "Trg", false, "Raise 24 Units"),
        148: ("Ext", "WR", "--", .slow, "Tx", "Trg", false, "Raise 24 Units"),
        143: ("Ext", "W1", "--", .slow, "Tx", "Trg", false, "Raise 24 Units"),
        67: ("Reg", "SR", "--", .slow, "Tx0", "Trg", false, "Raise 32 Units"),
        14: ("Reg", "S1", "--", .slow, "Tx0", "Trg", false, "Raise 32 Units"),
        149: ("Ext", "WR", "--", .slow, "Tx0", "Trg", false, "Raise 32 Units"),
        144: ("Ext", "W1", "--", .slow, "Tx0", "Trg", false, "Raise 32 Units"),
        68: ("Reg", "SR", "--", .slow, "Tx0", "Trg", false, "Raise Next Floor"),
        20: ("Reg", "S1", "--", .slow, "Tx0", "Trg", false, "Raise Next Floor"),
        95: ("Reg", "WR", "--", .slow, "Tx0", "Trg", false, "Raise Next Floor"),
        22: ("Reg", "W1", "--", .slow, "Tx0", "Trg", false, "Raise Next Floor"),
        47: ("Reg", "G1", "--", .slow, "Tx0", "Trg", false, "Raise Next Floor"),
        181: ("Ext", "SR", "3s", .slow, "None", "--", false, "Lowest and Highest Floor (perpetual)"),
        162: ("Ext", "S1", "3s", .slow, "None", "--", false, "Lowest and Highest Floor (perpetual)"),
        87: ("Reg", "WR", "3s", .slow, "None", "--", false, "Lowest and Highest Floor (perpetual)"),
        53: ("Reg", "W1", "3s", .slow, "None", "--", false, "Lowest and Highest Floor (perpetual)"),
        182: ("Ext", "SR", "--", .na, "----", "--", nil, "Stop"),
        163: ("Ext", "S1", "--", .na, "----", "--", nil, "Stop"),
        89: ("Reg", "WR", "--", .na, "----", "--", nil, "Stop"),
        54: ("Reg", "W1", "--", .na, "----", "--", nil, "Stop"),
        62: ("Reg", "SR", "3s", .slow, "None", "--", false, "Lowest Neighbor Floor (lift)"),
        21: ("Reg", "S1", "3s", .slow, "None", "--", false, "Lowest Neighbor Floor (lift)"),
        88: ("Reg", "WR", "3s", .slow, "None", "--", false, "Lowest Neighbor Floor (lift)"),
        10: ("Reg", "W1", "3s", .slow, "None", "--", false, "Lowest Neighbor Floor (lift)"),
        123: ("Reg", "SR", "3s", .fast, "None", "--", false, "Lowest Neighbor Floor (lift)"),
        122: ("Reg", "S1", "3s", .fast, "None", "--", false, "Lowest Neighbor Floor (lift)"),
        120: ("Reg", "WR", "3s", .fast, "None", "--", false, "Lowest Neighbor Floor (lift)"),
        121: ("Reg", "W1", "3s", .fast, "None", "--", false, "Lowest Neighbor Floor (lift)"),
        211: ("Ext", "SR", "--", .inst, "None", "--", false, "Ceiling (toggle)"),
        212: ("Ext", "WR", "--", .inst, "None", "--", false, "Ceiling (toggle)"),
    ]

let crusherTypes:
    [Int: (
        class: String, trigger: String, speed: Speed, monsters: Bool?, sillent: Bool?,
        action: String
    )] = [
        184: ("Ext", "SR", .slow, false, false, "Start"),
        49: ("Reg", "S1", .slow, false, false, "Start"),
        73: ("Reg", "WR", .slow, false, false, "Start"),
        25: ("Reg", "W1", .slow, false, false, "Start"),
        183: ("Ext", "SR", .fast, false, false, "Start"),
        164: ("Ext", "S1", .fast, false, false, "Start"),
        77: ("Reg", "WR", .fast, false, false, "Start"),
        6: ("Reg", "W1", .fast, false, false, "Start"),
        185: ("Ext", "SR", .slow, false, true, "Start"),
        165: ("Ext", "S1", .slow, false, true, "Start"),
        150: ("Ext", "WR", .slow, false, true, "Start"),
        141: ("Reg", "W1", .slow, false, true, "Start"),
        188: ("Ext", "SR", .na, nil, nil, "Stop"),
        168: ("Ext", "S1", .na, nil, nil, "Stop"),
        74: ("Reg", "WR", .na, nil, nil, "Stop"),
        57: ("Reg", "W1", .na, nil, nil, "Stop"),
    ]

let stairTypes:
    [Int: (
        class: String, trigger: String, direction: String, speed: Speed, step: Int,
        ignore: Bool, monsters: Bool
    )] = [
        258: ("Ext", "SR", "Up", .slow, 8, false, false),
        7: ("Reg", "S1", "Up", .slow, 8, false, false),
        256: ("Ext", "WR", "Up", .slow, 8, false, false),
        8: ("Reg", "W1", "Up", .slow, 8, false, false),
        259: ("Ext", "SR", "Up", .fast, 16, false, false),
        127: ("Reg", "S1", "Up", .fast, 16, false, false),
        257: ("Ext", "WR", "Up", .fast, 16, false, false),
        100: ("Reg", "W1", "Up", .fast, 16, false, false),
    ]

let elevatorTypes: [Int: (class: String, trigger: String, speed: Speed, target: String)] = [
    230: ("Ext", "SR", .fast, "Next Highest Floor"),
    229: ("Ext", "S1", .fast, "Next Highest Floor"),
    228: ("Ext", "WR", .fast, "Next Highest Floor"),
    227: ("Ext", "W1", .fast, "Next Highest Floor"),
    234: ("Ext", "SR", .fast, "Next Lowest Floor"),
    233: ("Ext", "S1", .fast, "Next Lowest Floor"),
    232: ("Ext", "WR", .fast, "Next Lowest Floor"),
    231: ("Ext", "W1", .fast, "Next Lowest Floor"),
    238: ("Ext", "SR", .fast, "Current Floor"),
    237: ("Ext", "S1", .fast, "Current Floor"),
    236: ("Ext", "WR", .fast, "Current Floor"),
    235: ("Ext", "W1", .fast, "Current Floor"),
]

enum BinaryDecoderError: Error {
    case runtimeError(String)
}

private protocol BinaryDecodable {
    init(from: WAD.BinaryDecoder) throws
}

private protocol FixedWidth {
    static var byteWidth: Int { get }
}

private struct Regex {
    let pattern: String
    init(_ pattern: String) {
        self.pattern = pattern
    }
}

private func ~= (regex: Regex, string: String) -> Bool {
    return string.range(of: regex.pattern, options: .regularExpression) != nil
}

class WAD {

    fileprivate class BinaryDecoder {
        let data: Data
        var position: Int

        init(withData data: Data) {
            self.data = data
            self.position = 0
        }

        func seek(_ position: Int) {
            self.position = position
        }

        var tell: Int {
            position
        }

        func get(_ type: String.Type, count: Int = 8) throws -> String {
            let chars = try get(UInt8.self, count: count)
            let str = String(bytes: chars, encoding: .utf8)!
            return String(str.prefix(while: { $0 != "\0" })).uppercased()
            //        def tos(x):
            //            return x.decode("utf-8").rstrip("\x00").upper()
        }

        func get<T: FixedWidthInteger>(_ type: T.Type, count: Int) throws -> [T] {
            let itemByteWidth = type.bitWidth / 8
            let byteWidth = count * itemByteWidth
            if data.count < position + byteWidth {
                throw BinaryDecoderError.runtimeError("ops")
            }
            defer { position += byteWidth }
            return data[position..<position + byteWidth].withUnsafeBytes {
                $0.bindMemory(to: T.self).map { T(littleEndian: $0) }
            }
        }

        func get<T: FixedWidthInteger>(_ type: T.Type) throws -> T {
            let byteWidth = type.bitWidth / 8
            if data.count < position + byteWidth {
                throw BinaryDecoderError.runtimeError("ops")
            }
            defer { position += byteWidth }
            return data[position..<position + byteWidth].withUnsafeBytes { src in
                var value: T = 0
                _ = withUnsafeMutableBytes(of: &value) { dst in
                    src.copyBytes(to: dst)
                }
                return T(littleEndian: value)
            }
        }
    }

    struct FileLump: BinaryDecodable, FixedWidth {
        let filePos: Int32
        let size: Int32
        let name: String

        static let byteWidth = 4 + 4 + 8

        fileprivate init(from decoder: BinaryDecoder) throws {
            filePos = try decoder.get(Int32.self)
            size = try decoder.get(Int32.self)
            name = try decoder.get(String.self, count: 8)
        }

        var description: String {
            return "Lump:\(self.name) filePos:\(filePos) size:\(size)"
        }
    }

    struct PlayPal: CustomStringConvertible, BinaryDecodable, FixedWidth {
        let colors: [(UInt8, UInt8, UInt8)]

        static let byteWidth = 256 * 3

        fileprivate init(from decoder: BinaryDecoder) throws {
            colors = try (0..<PlayPal.byteWidth / 3).map { _ in
                (
                    try decoder.get(UInt8.self), try decoder.get(UInt8.self),
                    try decoder.get(UInt8.self)
                )
            }
        }

        var description: String {
            return "PlayPal(\(colors.count), ["
                + self.colors.prefix(2).map { "\($0)" }.joined(separator: ", ")
                + ((colors.count > 2) ? ", ...])" : "])")
        }
    }

    struct Flat: BinaryDecodable, FixedWidth {
        static let width = 64
        static let height = 64
        let pixels: [UInt8]

        static let byteWidth = Flat.width * Flat.height

        func exportPixels() -> [[UInt8]] {
            // Todo: need transposing?
            return (0..<Flat.height).map {
                Array(pixels[Flat.width * $0..<Flat.width * ($0 + 1)])
            }
        }

        fileprivate init(from decoder: BinaryDecoder) throws {
            pixels = try decoder.get(UInt8.self, count: Flat.byteWidth)
        }
    }

    struct Patch: BinaryDecodable {
        let width: UInt16
        let height: UInt16
        let leftOffset: Int16
        let topOffset: Int16
        let columns: [[(topDelta: UInt8, data: [UInt8])]]

        fileprivate init(from decoder: BinaryDecoder) throws {
            let pos = decoder.tell

            width = try decoder.get(UInt16.self)
            height = try decoder.get(UInt16.self)
            leftOffset = try decoder.get(Int16.self)
            topOffset = try decoder.get(Int16.self)

            let columnOfs = try decoder.get(UInt32.self, count: Int(width))

            columns = try columnOfs.map { offset in
                decoder.seek(pos + Int(offset))
                var column: [(topDelta: UInt8, data: [UInt8])] = []
                while case let topDelta = try decoder.get(UInt8.self), topDelta != 255 {
                    let length = try decoder.get(UInt8.self)
                    _ = try decoder.get(UInt8.self)
                    let data = try decoder.get(UInt8.self, count: Int(length))
                    _ = try decoder.get(UInt8.self)
                    column.append((topDelta, data))
                }
                return column
            }
        }

        func exportPixels() -> [[Int16]] {
            var pixels = Array(
                repeating: Array(repeating: Int16(-1), count: Int(height)),
                count: Int(width)
            )
            for (x, column) in columns.enumerated() {
                for (topDelta, data) in column {
                    for (y, value) in data.enumerated() {
                        pixels[x][y + Int(topDelta)] = Int16(value)
                    }
                }
            }
            return pixels
        }
    }

    struct MapPatch: BinaryDecodable, FixedWidth {
        let originX: Int16
        let originY: Int16
        let patchId: Int16
        let stepDir: Int16
        let colorMap: Int16

        static let byteWidth = 10

        fileprivate init(from decoder: BinaryDecoder) throws {
            originX = try decoder.get(Int16.self)
            originY = try decoder.get(Int16.self)
            patchId = try decoder.get(Int16.self)
            stepDir = try decoder.get(Int16.self)
            colorMap = try decoder.get(Int16.self)
        }
    }

    struct Texture: BinaryDecodable {
        let name: String
        let masked: UInt32
        let width: UInt16
        let height: UInt16
        let columnDirectory: UInt32
        let patches: [MapPatch]

        fileprivate init(from decoder: BinaryDecoder) throws {
            name = try decoder.get(String.self, count: 8)
            masked = try decoder.get(UInt32.self)
            width = try decoder.get(UInt16.self)
            height = try decoder.get(UInt16.self)
            columnDirectory = try decoder.get(UInt32.self)

            let patchCount = try decoder.get(UInt16.self)
            patches = try (0..<patchCount).map { _ in try MapPatch(from: decoder) }
        }

        func exportPixels(fromWad wad: WAD) -> [[Int16]] {
            var pixels = Array(
                repeating: Array(repeating: Int16(-1), count: Int(height)),
                count: Int(width)
            )
            for mPatch in patches {
                if wad.pNames.indices.contains(Int(mPatch.patchId)) {
                    let name = wad.pNames[Int(mPatch.patchId)]
                    if let patch = wad.patches[name] {
                        let patchPixels = patch.exportPixels()
                        for x in 0..<Int(width) {
                            for y in 0..<Int(height) {
                                let xp = x - Int(mPatch.originX)
                                let yp = y - Int(mPatch.originY)
                                if (0..<Int(patch.width)) ~= xp && (0..<Int(patch.height)) ~= yp {
                                    let value = patchPixels[xp][yp]
                                    if value >= 0 {
                                        pixels[x][y] = value
                                    }
                                }
                            }
                        }
                    }
                }
            }
            return pixels
        }
    }

    struct Vertex: BinaryDecodable, FixedWidth {
        let x: Int16
        let y: Int16

        static let byteWidth = 4

        fileprivate init(from decoder: BinaryDecoder) throws {
            x = try decoder.get(Int16.self)
            y = try decoder.get(Int16.self)
        }

        func export() -> Goom.Vector {
            return Goom.Vector(x: Float(x), y: Float(y))
        }
    }

    // Defines an area (floor and ceiling).
    final class Sector: BinaryDecodable, FixedWidth, Hashable, Equatable {
        let floorHeight: Int16
        let ceilingHeight: Int16
        let floorTextureName: String
        let ceilingTextureName: String
        let lightLevel: Int16
        let specialType: Int16
        let tagNumber: Int16

        static let byteWidth = 26

        fileprivate init(from decoder: BinaryDecoder) throws {
            floorHeight = try decoder.get(Int16.self)
            ceilingHeight = try decoder.get(Int16.self)
            floorTextureName = try decoder.get(String.self)
            ceilingTextureName = try decoder.get(String.self)
            lightLevel = try decoder.get(Int16.self)
            specialType = try decoder.get(Int16.self)
            tagNumber = try decoder.get(Int16.self)
        }

        func export(usingId id: Int, with exporter: WAD.Exporter) -> Goom.Sector {
            let mapNumber = exporter.mapName.prefix(2).suffix(1)
            let ceilingTexture = exporter.findTexture(
                named: (Regex(#".*SKY.*"#) ~= ceilingTextureName)
                    ? "SKY\(mapNumber)" : ceilingTextureName
            )

            var ceilingHeights = [Float(ceilingHeight)]
            var floorHeights = [Float(floorHeight)]
            if let alt = exporter.sectorAltHeights[self] {
                ceilingHeights.append(Float(alt.ceiling))
                floorHeights.append(Float(alt.floor))
            }

            return Goom.Sector(
                id: id,
                ceiling: Goom.Sector.Part(
                    heights: ceilingHeights,
                    texture: ceilingTexture
                ),
                floor: Goom.Sector.Part(
                    heights: floorHeights,
                    texture: exporter.findTexture(named: floorTextureName)
                )
            )
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(ObjectIdentifier(self))
        }

        static func == (lhs: Sector, rhs: Sector) -> Bool {
            return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
        }
    }

    // Defines one side of a wall.
    struct SideDef: BinaryDecodable, FixedWidth {
        let xOffset: Int16
        let yOffset: Int16
        let upperTextureName: String
        let lowerTextureName: String
        let middleTextureName: String
        let sectorId: Int16

        static let byteWidth = 30

        fileprivate init(from decoder: BinaryDecoder) throws {
            xOffset = try decoder.get(Int16.self)
            yOffset = try decoder.get(Int16.self)
            upperTextureName = try decoder.get(String.self)
            lowerTextureName = try decoder.get(String.self)
            middleTextureName = try decoder.get(String.self)
            sectorId = try decoder.get(Int16.self)
        }

        func sector(in map: Map) -> Sector {
            return map.sectors[Int(sectorId)]
        }
    }

    // Defines a wall.
    final class LineDef: BinaryDecodable, FixedWidth {

        struct Flags: OptionSet {
            let rawValue: Int16
            static let blocksPlayersMonsters = Flags(rawValue: 1 << 0)
            static let blocksMonsters = Flags(rawValue: 1 << 1)
            static let twoSided = Flags(rawValue: 1 << 2)
            static let upperUnpegged = Flags(rawValue: 1 << 3)
            static let lowerUnpegged = Flags(rawValue: 1 << 4)
            static let secret = Flags(rawValue: 1 << 5)
            static let blocksSound = Flags(rawValue: 1 << 6)
            static let automapNever = Flags(rawValue: 1 << 7)
            static let automapAlways = Flags(rawValue: 1 << 8)
        }

        let startVertexId: Int16
        let endVertexId: Int16
        let flags: Flags
        let specialType: Int16
        let sectorTag: Int16
        let frontSideDefId: UInt16
        let backSideDefId: UInt16

        static let byteWidth = 14

        fileprivate init(from decoder: BinaryDecoder) throws {
            startVertexId = try decoder.get(Int16.self)
            endVertexId = try decoder.get(Int16.self)
            flags = Flags(rawValue: try decoder.get(Int16.self))
            specialType = try decoder.get(Int16.self)
            sectorTag = try decoder.get(Int16.self)
            frontSideDefId = try decoder.get(UInt16.self)
            backSideDefId = try decoder.get(UInt16.self)
        }

        func frontSideDef(in map: Map) -> SideDef {
            return map.sideDefs[Int(frontSideDefId)]
        }

        func backSideDef(in map: Map) -> SideDef? {
            if backSideDefId >= 65535 { return nil }
            return map.sideDefs[Int(backSideDefId)]
        }

        func frontSector(in map: Map) -> Sector {
            return frontSideDef(in: map).sector(in: map)
        }

        func backSector(in map: Map) -> Sector? {
            return backSideDef(in: map)?.sector(in: map)
        }

        func export(with exporter: WAD.Exporter) -> Goom.Wall {

            var startVertex = exporter.map.vertexes[Int(startVertexId)]
            var endVertex = exporter.map.vertexes[Int(endVertexId)]
            var frontSideDef = exporter.map.sideDefs[Int(frontSideDefId)]
            var frontSector = exporter.map.sectors[Int(frontSideDef.sectorId)]
            var backSideDef =
                (backSideDefId < 65535) ? exporter.map.sideDefs[Int(backSideDefId)] : nil
            var backSector: Sector? = nil
            if backSideDef != nil {
                backSector = exporter.map.sectors[Int(backSideDef!.sectorId)]
                var lowerRise = backSector!.floorHeight - frontSector.floorHeight
                if lowerRise < 0 {
                    swap(&startVertex, &endVertex)
                    swap(&frontSideDef, &backSideDef!)
                    swap(&frontSector, &backSector!)
                    lowerRise = -lowerRise
                }
            }

            let goomStartVertex = startVertex.export()
            let goomEndVertex = endVertex.export()
            let length = (goomEndVertex - goomStartVertex).magnitude()

            let upperTextureHeight =
                Float(exporter.findTexture(named: frontSideDef.upperTextureName)?.height ?? 0)
            let middleTextureHeight =
                Float(exporter.findTexture(named: frontSideDef.middleTextureName)?.height ?? 0)
            // let lowerTextureHeight =
            //     Float(exporter.findTexture(named: frontSideDef.middleTextureName)?.height ?? 0)

            let ox = Float(frontSideDef.xOffset)
            let oy = Float(frontSideDef.yOffset)

            func getUV(usingAlt: Bool) -> (
                upperU: Space,
                upperV: Space,
                middleU: Space,
                middleV: Space,
                lowerU: Space,
                lowerV: Space,
                topTextureName: String?,
                midTextureName: String,
                bottomTextureName: String
            ) {
                // var upperUV = [[ox + length, 0], [ox, 0]]
                // var middleUV = [[ox + length, 0], [ox, 0]]
                // var lowerUV = [[ox + length, 0], [ox, 0]]

                let upperU = Space(begin: ox + length, end: ox)
                let middleU = Space(begin: ox + length, end: ox)
                let lowerU = Space(begin: ox + length, end: ox)

                var upperV = Space(begin: 0, end: 0)
                var middleV = Space(begin: 0, end: 0)
                var lowerV = Space(begin: 0, end: 0)

                let phase = Float(1)
                var topRaise = Float(0)

                var frontSectorHeight = (
                    floor: frontSector.floorHeight, ceiling: frontSector.ceilingHeight
                )
                if usingAlt, let alt = exporter.sectorAltHeights[frontSector] {
                    frontSectorHeight = alt
                }

                if backSideDef != nil {

                    var backSectorHeight = (
                        floor: backSector!.floorHeight, ceiling: backSector!.ceilingHeight
                    )
                    if usingAlt, let alt = exporter.sectorAltHeights[backSector!] {
                        backSectorHeight = alt
                    }

                    // let box = Float(backSideDef!.xOffset)
                    let boy = Float(backSideDef!.yOffset)

                    // The bottom step always goes up (faces the player on phase=0).
                    let bottomRaise =
                        Float(backSectorHeight.floor) - Float(frontSectorHeight.floor)
                    assert(bottomRaise >= -1e-6 || phase == 1)

                    // The top step can go down (faces the player) or up (does not)
                    // top_raise = sector_back.ceiling_height - sector_front.ceiling_height.
                    topRaise =
                        Float(backSectorHeight.ceiling)
                        - Float(frontSectorHeight.ceiling)

                    // midh usually is >=0 but it can also be negative for
                    let midh =
                        min(
                            Float(frontSectorHeight.ceiling),
                            Float(backSectorHeight.ceiling)
                        )
                        - max(
                            Float(frontSectorHeight.floor),
                            Float(backSectorHeight.floor)
                        )

                    if flags.contains([.lowerUnpegged]) {
                        // top of lower texture at top of upper wall part
                        let v = oy + abs(topRaise) + max(midh, 0)
                        lowerV = Space(begin: v + bottomRaise, end: v)
                    }
                    else {
                        // top of lower texture `pegged' at the top of the lower wall part
                        lowerV = Space(begin: oy + bottomRaise, end: oy)
                    }

                    if flags.contains([.upperUnpegged]) {
                        // Top of upper texture at top of the upper wall part.
                        let v = topRaise < 0 ? oy : boy
                        upperV = Space(begin: v + abs(topRaise), end: v)
                    }
                    else {
                        // Bottom of upper texture `pegged' at the bottom of the upper wall part.
                        let v = (topRaise < 0 ? oy : boy) + upperTextureHeight
                        upperV = Space(begin: v, end: v - abs(topRaise))
                    }

                    if midh >= 0 {
                        if flags.contains([.lowerUnpegged]) {
                            // Bottom of middle texture at bottom of wall.
                            let v = oy + middleTextureHeight
                            middleV = Space(begin: v, end: v - midh)
                        }
                        else {
                            // Top of middle texture `pegged' at top of wall.
                            middleV = Space(begin: oy + midh, end: oy)
                        }
                    }
                }
                else {
                    let midh =
                        Float(frontSectorHeight.ceiling) - Float(frontSectorHeight.floor)
                    // assert midh >= -1e-5
                    if flags.contains([.lowerUnpegged]) {
                        // Bottom of middle texture at bottom of wall.
                        let v = oy + middleTextureHeight
                        middleV = Space(begin: v, end: v - midh)
                    }
                    else {
                        // Top of middle texture `pegged' at top of wall.
                        middleV = Space(begin: oy + midh, end: oy)
                    }
                    topRaise = -1
                }

                var topTextureName: String? =
                    (topRaise < 0) ? frontSideDef.upperTextureName : backSideDef!.upperTextureName
                let midTextureName = frontSideDef.middleTextureName
                let bottomTextureName = frontSideDef.lowerTextureName

                // A wall between to sky flats is not drawn.
                if backSideDef != nil {
                    if Regex(#".*SKY.*"#) ~= frontSector.ceilingTextureName
                        && Regex(#".*SKY.*"#) ~= backSector!.ceilingTextureName
                    {
                        topTextureName = nil
                    }
                }

                return (
                    upperU: upperU,
                    upperV: upperV,
                    middleU: middleU,
                    middleV: middleV,
                    lowerU: lowerU,
                    lowerV: lowerV,
                    topTextureName: topTextureName,
                    midTextureName: midTextureName,
                    bottomTextureName: bottomTextureName
                )
            }

            let base = getUV(usingAlt: false)
            let alt = getUV(usingAlt: true)

            let wall = Goom.Wall(
                base: Goom.Segment(v1: goomEndVertex, v2: goomStartVertex),
                top: Goom.Wall.Part(
                    texture: base.topTextureName != nil
                        ? exporter.findTexture(named: base.topTextureName!) : nil,
                    uSpaceStates: [base.upperU, alt.upperU],
                    vSpaceStates: [base.upperV, alt.upperV]
                    // uSpace: Goom.Space(begin: upperUV[0][0], end: upperUV[1][0]),
                    // vSpace: Goom.Space(begin: upperUV[0][1], end: upperUV[1][1])
                ),
                middle: Goom.Wall.Part(
                    texture: exporter.findTexture(named: base.midTextureName),
                    uSpaceStates: [base.middleU, alt.middleU],
                    vSpaceStates: [base.middleV, alt.middleV]
                    // uSpace: Goom.Space(begin: middleUV[0][0], end: middleUV[1][0]),
                    // vSpace: Goom.Space(begin: middleUV[0][1], end: middleUV[1][1])
                ),
                bottom: Goom.Wall.Part(
                    texture: exporter.findTexture(named: base.bottomTextureName),
                    uSpaceStates: [base.lowerU, alt.lowerU],
                    vSpaceStates: [base.lowerV, alt.lowerV]
                    // uSpace: Goom.Space(begin: lowerUV[0][0], end: lowerUV[1][0]),
                    // vSpace: Goom.Space(begin: lowerUV[0][1], end: lowerUV[1][1])
                ),
                frontSector: exporter.findSector(withId: Int(frontSideDef.sectorId))!,
                backSector: backSideDef != nil
                    ? exporter.findSector(withId: Int(backSideDef!.sectorId)) : nil
            )
            return wall
        }
    }

    final class Thing: BinaryDecodable, FixedWidth {
        let x: Int16
        let y: Int16
        let angle: Int16
        let type: Int16
        let flags: Int16

        static let byteWidth = 10

        fileprivate init(from decoder: BinaryDecoder) throws {
            x = try decoder.get(Int16.self)
            y = try decoder.get(Int16.self)
            angle = try decoder.get(Int16.self)
            type = try decoder.get(Int16.self)
            flags = try decoder.get(Int16.self)
        }

        func export(with exporter: Exporter) -> Goom.Thing {
            let prefix = thingTypes[Int(type)]!.sprite
            let textures = exporter.wad.sprites.compactMap({ (name, sprite) -> Goom.Texture? in
                if name.starts(with: prefix) {
                    return exporter.findTexture(named: name)
                }
                else {
                    return nil
                }
            })
            return Goom.Thing(
                position: Vector(x: Float(x), y: Float(y)),
                angle: Float(angle) / 180.0 * Float.pi,
                textures: textures
            )
        }
    }

    class Map: CustomStringConvertible {
        var things: [Thing] = []
        var sectors: [Sector] = []
        var lineDefs: [LineDef] = []
        var sideDefs: [SideDef] = []
        var vertexes: [Vertex] = []

        var description: String {
            return
                "Map(things:\(things.count), sectors:\(sectors.count), lineDefs:\(lineDefs.count), sideDefs:\(sideDefs.count), vertexes:\(vertexes.count))"
        }

        func exportSectors(with exporter: WAD.Exporter) -> [Goom.Sector] {
            sectors.enumerated().map { (id, sector) in
                sector.export(usingId: id, with: exporter)
            }
        }

        func exportWalls(with exporter: WAD.Exporter) -> [Goom.Wall] {
            lineDefs.map {
                $0.export(with: exporter)
            }
        }

        func exportThings(with exporter: WAD.Exporter) -> [Goom.Thing] {
            things.map {
                $0.export(with: exporter)
            }
        }
    }

    var fileLumps: [FileLump]
    var playPals: [PlayPal]
    var colorMap: [[UInt8]]
    var pNames: [String]
    var flats: OrderedDictionary<String, Flat>
    var patches: OrderedDictionary<String, Patch>
    var sprites: OrderedDictionary<String, Patch>
    var textures: [Texture]
    var maps: OrderedDictionary<String, Map>

    convenience init(fromURL url: URL) throws {
        let data = try Data(contentsOf: url, options: .mappedIfSafe)
        let decoder = BinaryDecoder(withData: data)
        try self.init(from: decoder)
    }

    fileprivate init(from decoder: BinaryDecoder) throws {
        let magic = try decoder.get(UInt8.self, count: 4)
        if magic != "IWAD".utf8.map({ UInt8($0) }) {
            throw BinaryDecoderError.runtimeError("Not an IWAD.")
        }
        let numLumps = try decoder.get(Int32.self)
        let infoTableOfs = try decoder.get(Int32.self)
        fileLumps = try (0..<Int(numLumps)).map { i in
            decoder.seek(Int(infoTableOfs) + i * FileLump.byteWidth)
            return try FileLump(from: decoder)
        }

        var iter = fileLumps.makeIterator()
        playPals = []
        colorMap = []
        pNames = []
        flats = [:]
        patches = [:]
        sprites = [:]
        textures = []
        maps = [:]

        var activeMap: Map? = nil

        func decodeLumpSequence<T: BinaryDecodable>(_ type: T.Type, terminatedBy terminator: String)
            throws -> OrderedDictionary<String, T>
        {
            var dict: OrderedDictionary<String, T> = [:]
            while let lump = iter.next() {
                if lump.name == terminator { break }
                decoder.seek(Int(lump.filePos))
                dict[lump.name] = try T(from: decoder)
            }
            return dict
        }

        while let lump = iter.next() {

            func decodeArray<T: BinaryDecodable & FixedWidth>(_ type: T.Type) throws
                -> [T]
            {
                return try (0..<Int(lump.size) / T.byteWidth).map { _ in
                    try T(from: decoder)
                }
            }

            decoder.seek(Int(lump.filePos))
            switch lump.name {
            case "PLAYPAL":
                print(lump.name)
                playPals = try decodeArray(PlayPal.self)
                for playPal in playPals {
                    print("  \(playPal)")
                }

            case "COLORMAP":
                print(lump.name)
                for _ in 0..<Int(lump.size) / 256 {
                    colorMap.append(try decoder.get(UInt8.self, count: 256))
                }
                print("  \(colorMap.count) levels in the color map")

            case "PNAMES":
                print(lump.name)
                let n = try decoder.get(UInt32.self)
                for _ in 0..<n {
                    pNames.append(try decoder.get(String.self, count: 8))
                }
                print("  \(pNames)")

            case "F_START":
                print(lump.name)
                flats = try decodeLumpSequence(Flat.self, terminatedBy: "F_END")
                print("  \(flats.count) flats")

            case "P_START":
                print(lump.name)
                while let lump = iter.next(), lump.name != "P_END" {
                    switch lump.name {
                    case Regex(#"P\d_START"#):
                        let i = Int(lump.name.prefix(2).suffix(1))!
                        patches.merge(try decodeLumpSequence(Patch.self, terminatedBy: "P\(i)_END"))
                        {
                            (_, new) in new
                        }
                    default:
                        break
                    }
                }
                print("  \(patches.count) patches")

            case "S_START":
                print(lump.name)
                sprites = try decodeLumpSequence(Patch.self, terminatedBy: "S_END")
                print("  \(sprites.count) sprites")

            case Regex(#"TEXTURE\d?"#):
                let numTextures = try decoder.get(Int32.self)
                let offsets = try decoder.get(Int32.self, count: Int(numTextures))
                textures += try offsets.map { offset in
                    decoder.seek(Int(lump.filePos) + Int(offset))
                    return try Texture(from: decoder)
                }

            case Regex(#"^E\dM\d|MAP\d\d$"#):
                print("Map", lump.name)
                activeMap = Map()
                maps[lump.name] = activeMap

            case "THINGS":
                activeMap?.things = try decodeArray(Thing.self)

            case "LINEDEFS":
                activeMap?.lineDefs = try decodeArray(LineDef.self)

            case "SIDEDEFS":
                activeMap?.sideDefs = try decodeArray(SideDef.self)

            case "VERTEXES":
                activeMap?.vertexes = try decodeArray(Vertex.self)

            case "SEGS":
                break

            case "SSECTORS":
                break

            case "NODES":
                break

            case "SECTORS":
                activeMap?.sectors = try decodeArray(Sector.self)

            case "REJECT":
                break

            case "BLOCKMAP":
                break

            case Regex(#"[12]_(START|END)"#):
                print(lump.name)
                break

            default:
                print("  ", lump.name)
            }
        }
        for map in maps {
            print("\(map.key): \(map.value)")
        }
    }

    final class Exporter {
        let wad: WAD
        var map: Map! = nil
        var mapName: String = ""
        var textures: [Goom.Texture] = []
        var sectors: [Goom.Sector] = []
        var sectorAltHeights: [Sector: (floor: Int16, ceiling: Int16)] = [:]
        var walls: [Goom.Wall] = []
        var things: [Goom.Thing] = []
        var altState: Bool = false

        init(wad: WAD) {
            self.wad = wad
        }

        func findTexture(named name: String) -> Goom.Texture? {
            return textures.first(where: {
                $0.name == name
            })
        }

        func findSector(withId id: Int) -> Goom.Sector? {
            return sectors.first(where: {
                $0.id == id
            })
        }

        func findNeighbors(ofSector sector: Sector) -> [Sector] {
            var neighbors: [Sector] = []
            for lineDef in self.map.lineDefs {
                let frontSideDef = lineDef.frontSideDef(in: map)
                let backSideDef = lineDef.backSideDef(in: map)
                if backSideDef == nil {
                    continue
                }
                else if frontSideDef.sector(in: map) === sector {
                    neighbors.append(backSideDef!.sector(in: map))
                }
                else if backSideDef!.sector(in: map) === sector {
                    neighbors.append(frontSideDef.sector(in: map))
                }
            }
            return neighbors
        }

        func animate(door doorLineDef: LineDef, with exporter: Exporter) {
            let doorType = doorTypes[Int(doorLineDef.specialType)]!
            var doorSectors: [Sector] = []
            if doorType.trigger.prefix(1) == "P" {
                if let doorbackSector = doorLineDef.backSector(in: map) {
                    doorSectors.append(doorbackSector)
                }
            }
            else {
                doorSectors = map.sectors.filter { $0.tagNumber == doorLineDef.sectorTag }
            }
            for doorSector in doorSectors {
                var ceilingHeight = Int16(10_000)
                for lineDef in map.lineDefs {
                    if let backSector = lineDef.backSector(in: map) {
                        if doorSectors.contains(where: { $0 === backSector }) {
                            ceilingHeight = min(
                                lineDef.frontSector(in: map).ceilingHeight,
                                ceilingHeight
                            )
                        }
                    }
                }
                exporter.sectorAltHeights[doorSector] = (
                    floor: doorSector.floorHeight, ceiling: ceilingHeight
                )
            }
        }

        func animate(platform platformLineDef: LineDef, with exporter: Exporter) {
            let platformType = platformTypes[Int(platformLineDef.specialType)]!
            guard
                let platformSector = exporter.map.sectors.first(where: {
                    $0.tagNumber == platformLineDef.sectorTag
                })
            else { return }

            //     ef make_platform_animation(platform_linedef):
            // platform_type = platform_types[platform_linedef.special_type]
            // sectors = platform_linedef.map.sectors
            // platform_sector = next(
            //     s for s in sectors if s.tag_number == platform_linedef.sector_tag
            // )
            // ceiling_height = platform_sector.ceiling_height
            // floor_height = platform_sector.floor_height
            // neighbors = platform_sector.neighbors()

            let ceilingHeight = platformSector.ceilingHeight
            var floorHeight = platformSector.floorHeight
            let neighbors = exporter.findNeighbors(ofSector: platformSector)

            switch platformType.7 {
            case "Raise 24 Units":
                floorHeight += 24
                break

            case "Raise 32 Units":
                floorHeight += 32
                break

            case "Raise Next Floor":
                //     # This means that the "high" height is the lowest surrounding floor
                //     # higher than the platform. If no higher adjacent floor exists no
                //     # motion will occur.
                //     floor_height = min(
                //         [s.floor_height for s in neighbors if s.floor_height > floor_height]
                //     )
                floorHeight =
                    neighbors.filter({ $0.floorHeight > floorHeight }).map({ $0.floorHeight }).min()
                    ?? floorHeight

            case "Lowest and Highest Floor (perpetual)":
                // This target sets the "low" height to the lowest neighboring
                // floor, including the floor itself, and the "high" height to the
                // highest neighboring floor, including the floor itself. When this
                // target is used the floor moves perpetually between the two
                // heights. Once triggered this type of linedef runs permanently,
                // even if the motion is temporarily suspended with a Stop type. No
                // other floor action can be commanded on the sector after this type
                // is begun.
                //     floor_height = max([s.floor_height for s in neighbors + [platform_sector]])
                floorHeight = (neighbors + [platformSector]).map({ $0.floorHeight }).max()!

            case "Stop":
                floorHeight = 0  // # ??
                break

            case "Lowest Neighbor Floor (lift)":
                // This means that the platforms "low" height is the height of the
                // lowest surrounding floor, including the platform itself. The
                // "high" height is the original height of the floor.
                //     floor_height = min([s.floor_height for s in neighbors + [platform_sector]])
                floorHeight = (neighbors + [platformSector]).map({ $0.floorHeight }).min()!

            case "Ceiling (toggle)":
                // This target sets the "high" height to the ceiling of the sector
                // and the "low" height to the floor height of the sector and is
                // only used in the instant toggle type that switches the floor
                // between the ceiling and its original height on each activation.
                // This is also the ONLY instant platform type.
                //     floor_height = ceiling_height
                floorHeight = ceilingHeight

            default:
                break
            }
            exporter.sectorAltHeights[platformSector] = (floorHeight, ceilingHeight)
        }

        func animate(floor floorLineDef: LineDef, with exporter: Exporter) {
            let floorType = floorTypes[Int(floorLineDef.specialType)]!
            let floorSectors = exporter.map.sectors.filter {
                $0.tagNumber == floorLineDef.sectorTag
            }

            for floorSector in floorSectors {

                let ceilingHeight = floorSector.ceilingHeight
                var floorHeight = floorSector.floorHeight
                let neighbors = exporter.findNeighbors(ofSector: floorSector)

                switch floorType.target {
                case .lowestNeighborFloor:
                    floorHeight = (neighbors + [floorSector]).map({ $0.floorHeight }).min()!

                case .nextNeighborFloor where floorType.direction == "Dn":
                    floorHeight =
                        neighbors.filter({ $0.floorHeight < floorHeight }).map({ $0.floorHeight })
                        .max()
                        ?? floorHeight

                case .nextNeighborFloor where floorType.direction == "Up":
                    floorHeight =
                        neighbors.filter({ $0.floorHeight > floorHeight }).map({ $0.floorHeight })
                        .min()
                        ?? floorHeight

                case .lowestNeighborCeiling:
                    floorHeight = (neighbors + [floorSector]).map({ $0.ceilingHeight }).min()!

                case .lowestNeighborCeilingMinus8:
                    floorHeight = (neighbors + [floorSector]).map({ $0.ceilingHeight }).min()! - 8

                case .highestNeighborFloor:
                    floorHeight = (neighbors + [floorSector]).map({ $0.floorHeight }).max()!

                case .highestNeighborFloorPlus8:
                    floorHeight = (neighbors + [floorSector]).map({ $0.floorHeight }).max()! + 8

                case .absolute24:
                    floorHeight += (floorType.direction == "Up") ? Int16(24) : Int16(-24)

                case .absolute512:
                    floorHeight += (floorType.direction == "Up") ? Int16(512) : Int16(-512)

                default:
                    break
                }

                exporter.sectorAltHeights[floorSector] = (floorHeight, ceilingHeight)

            }
        }
    }

    func export() -> World {

        func split(_ pixels: [[Int16]]) -> ([[UInt8]], [[UInt8]]?) {
            let color = pixels.map { $0.map { UInt8(max($0, 0)) } }
            let mask = pixels.map { $0.map { UInt8($0 >= 0 ? 1 : 0) } }
            if mask.allSatisfy({ $0.allSatisfy({ $0 > 0 }) }) {
                return (color, nil)
            }
            else {
                return (color, mask)
            }
        }

        var goomTextureIds: [String: Int] = [:]
        var goomMaps: [Goom.Map] = []
        let exporter = Exporter(wad: self)

        for texture in textures {
            let id = goomTextureIds.count
            goomTextureIds[texture.name] = id
            let (pixels, mask) = split(texture.exportPixels(fromWad: self))
            exporter.textures.append(
                Goom.Texture(
                    id: id,
                    name: texture.name,
                    pixels: pixels,
                    mask: mask,
                    width: Int(texture.width),
                    height: Int(texture.height),
                    offset: Vector(x: 0, y: 0),
                    isSky: Regex(#".*SKY.*"#) ~= texture.name
                )
            )
        }

        for (flatName, flat) in flats {
            let id = goomTextureIds.count
            goomTextureIds[flatName] = id
            exporter.textures.append(
                Goom.Texture(
                    id: id,
                    name: flatName,
                    pixels: flat.exportPixels(),
                    mask: nil,
                    width: Int(Flat.width),
                    height: Int(Flat.height),
                    offset: Vector(x: 0, y: 0),
                    isSky: Regex(#".*SKY.*"#) ~= flatName
                )
            )
        }

        for (spriteName, sprite) in sprites {
            let id = goomTextureIds.count
            goomTextureIds[spriteName] = id
            let (pixels, mask) = split(sprite.exportPixels())
            exporter.textures.append(
                Goom.Texture(
                    id: id,
                    name: spriteName,
                    pixels: pixels,
                    mask: mask,
                    width: Int(sprite.width),
                    height: Int(sprite.height),
                    offset: Vector(
                        x: Float(sprite.leftOffset),
                        y: Float(sprite.height) - Float(sprite.topOffset)
                    ),
                    isSky: Regex(#".*SKY.*"#) ~= spriteName
                )
            )
        }

        for (mapName, map) in maps {
            exporter.map = map
            exporter.mapName = mapName
            exporter.altState = false
            exporter.sectorAltHeights = [:]

            // Animations: export the alternate state of the map
            exporter.sectorAltHeights.removeAll()
            for lineDef in map.lineDefs {
                let type = Int(lineDef.specialType)
                switch type {
                case _ where doorTypes[type] != nil:
                    exporter.animate(door: lineDef, with: exporter)
                case _ where floorTypes[type] != nil:
                    exporter.animate(floor: lineDef, with: exporter)
                case _ where platformTypes[type] != nil:
                    exporter.animate(platform: lineDef, with: exporter)
                default:
                    break
                }
            }

            var player = Player()
            if let playerThing = map.things.first(where: { $0.type == 1 }) {
                player = Player(
                    position: Vector(x: Float(playerThing.x), y: Float(playerThing.y)),
                    angle: Float(playerThing.angle) / 180.0 * Float.pi
                )
            }

            exporter.things = []
            exporter.sectors = []
            exporter.walls = []
            exporter.things = map.exportThings(with: exporter)
            exporter.sectors = map.exportSectors(with: exporter)
            exporter.walls = map.exportWalls(with: exporter)

            goomMaps.append(
                Goom.Map(
                    name: mapName,
                    player: player,
                    sectors: exporter.sectors,
                    walls: exporter.walls,
                    things: exporter.things
                )
            )
        }

        func pack(tuple: (r: UInt8, g: UInt8, b: UInt8)) -> UInt32 {
            return UInt32(tuple.r) << 16 | UInt32(tuple.g) << 8 | UInt32(tuple.b)
        }

        return World(
            maps: goomMaps,
            textures: exporter.textures,
            palettes: colorMap[0..<32].map { $0.map { pack(tuple: playPals[0].colors[Int($0)]) } }
        )
    }
}

func loadWad() throws -> Goom.World {
    guard let path = Bundle.main.path(forResource: "Assets/doom1", ofType: "wad") else {
        throw RuntimeError("Could not find the asset doom1.wad in the application bundle.")
    }

    let wad = try WAD(fromURL: URL(fileURLWithPath: path))
    let world = wad.export()
    return world
}
