//  WAD.swift
//  Goom

import Foundation
import OrderedCollections

enum Meta {

    enum ObjectClass {
        case regular
        case extended
    }

    enum Speed {
        case slow
        case fast
        case inst
        case na
    }

    enum DoorFunction {
        case openWaitThenClose
        case openStayOpen
        case closeStayClosed
        case closeWaitThenOpen
    }

    enum DoorLock {
        case none
        case blue
        case yellow
        case red
    }

    enum Trigger {
        case g1
        case gr
        case p1
        case pr
        case s1
        case sr
        case w1
        case wr
    }

    enum Direction {
        case none
        case up
        case down
    }

    // swift-format-ignore
    static let thingTypes:
        [Int: (
            version: String, radius: Int, height: Int, sprite: String, sequence: String,
            class: String, description: String
        )] = [
            1:    ("S" , 16 , 56  , "PLAY" , "+"     , ""     , "Player 1 start")                       ,
            2:    ("S" , 16 , 56  , "PLAY" , "+"     , ""     , "Player 2 start")                       ,
            3:    ("S" , 16 , 56  , "PLAY" , "+"     , ""     , "Player 3 start")                       ,
            4:    ("S" , 16 , 56  , "PLAY" , "+"     , ""     , "Player 4 start")                       ,
            5:    ("S" , 20 , 16  , "BKEY" , "AB"    , "P"    , "Blue keycard")                         ,
            6:    ("S" , 20 , 16  , "YKEY" , "AB"    , "P"    , "Yellow keycard")                       ,
            7:    ("R" , 128, 100 , "SPID" , "+"     , "MO"   , "Spider Mastermind")                    ,
            8:    ("S" , 20 , 16  , "BPAK" , "A"     , "P"    , "Backpack")                             ,
            9:    ("S" , 20 , 56  , "SPOS" , "+"     , "MO"   , "Former Human Sergeant")                ,
            10:   ("S" , 16 , 16  , "PLAY" , "W"     , ""     , "Bloody mess")                          ,
            11:   ("S" , 20 , 56  , "none" , "-"     , ""     , "Deathmatch start")                     ,
            12:   ("S" , 16 , 16  , "PLAY" , "W"     , ""     , "Bloody mess")                          ,
            13:   ("S" , 20 , 16  , "RKEY" , "AB"    , "P"    , "Red keycard")                          ,
            14:   ("S" , 20 , 16  , "none1", "-"     , ""     , "Teleport landing")                     ,
            15:   ("S" , 16 , 16  , "PLAY" , "N"     , ""     , "Dead player")                          ,
            16:   ("R" , 40 , 110 , "CYBR" , "+"     , "MO"   , "Cyberdemon")                           ,
            17:   ("R" , 20 , 16  , "CELP" , "A"     , "P2"   , "Cell charge pack")                     ,
            18:   ("S" , 20 , 16  , "POSS" , "L"     , ""     , "Dead former human")                    ,
            19:   ("S" , 20 , 16  , "SPOS" , "L"     , ""     , "Dead former sergeant")                 ,
            20:   ("S" , 20 , 16  , "TROO" , "M"     , ""     , "Dead imp")                             ,
            21:   ("S" , 30 , 16  , "SARG" , "N"     , ""     , "Dead demon")                           ,
            22:   ("R" , 31 , 16  , "HEAD" , "L"     , ""     , "Dead cacodemon")                       ,
            23:   ("R" , 16 , 16  , "SKUL" , "K"     , ""     , "Dead lost soul (invisible)" )          ,
            24:   ("S" , 16 , 16  , "POL5" , "A"     , ""     , "Pool of blood and flesh")              ,
            25:   ("R" , 16 , 16  , "POL1" , "A"     , "O"    , "Impaled human")                        ,
            26:   ("R" , 16 , 16  , "POL6" , "AB"    , "O"    , "Twitching impaled human")              ,
            27:   ("R" , 16 , 16  , "POL4" , "A"     , "O"    , "Skull on a pole")                      ,
            28:   ("R" , 16 , 16  , "POL2" , "A"     , "O"    , "Five skulls shish kebab")              ,
            29:   ("R" , 16 , 16  , "POL3" , "AB"    , "O"    , "Pile of skulls and candles")           ,
            30:   ("R" , 16 , 16  , "COL1" , "A"     , "O"    , "Tall green pillar")                    ,
            31:   ("R" , 16 , 16  , "COL2" , "A"     , "O"    , "Short green pillar")                   ,
            32:   ("R" , 16 , 16  , "COL3" , "A"     , "O"    , "Tall red pillar")                      ,
            33:   ("R" , 16 , 16  , "COL4" , "A"     , "O"    , "Short red pillar")                     ,
            34:   ("S" , 16 , 16  , "CAND" , "A"     , ""     , "Candle")                               ,
            35:   ("S" , 16 , 16  , "CBRA" , "A"     , "O"    , "Candelabra")                           ,
            36:   ("R" , 16 , 16  , "COL5" , "AB"    , "O"    , "Short green pillar with beating heart"),
            37:   ("R" , 16 , 16  , "COL6" , "A"     , "O"    , "Short red pillar with skull")          ,
            38:   ("R" , 20 , 16  , "RSKU" , "AB"    , "P"    , "Red skull key")                        ,
            39:   ("R" , 20 , 16  , "YSKU" , "AB"    , "P"    , "Yellow skull key")                     ,
            40:   ("R" , 20 , 16  , "BSKU" , "AB"    , "P"    , "Blue skull key")                       ,
            41:   ("R" , 16 , 16  , "CEYE" , "ABCB"  , "O"    , "Evil eye")                             ,
            42:   ("R" , 16 , 16  , "FSKU" , "ABC"   , "O"    , "Floating skull")                       ,
            43:   ("R" , 16 , 16  , "TRE1" , "A"     , "O"    , "Burnt tree")                           ,
            44:   ("R" , 16 , 16  , "TBLU" , "ABCD"  , "O"    , "Tall blue firestick")                  ,
            45:   ("R" , 16 , 16  , "TGRN" , "ABCD"  , "O"    , "Tall green firestick")                 ,
            46:   ("S" , 16 , 16  , "TRED" , "ABCD"  , "O"    , "Tall red firestick")                   ,
            47:   ("R" , 16 , 16  , "SMIT" , "A"     , "O"    , "Stalagmite")                           ,
            48:   ("S" , 16 , 16  , "ELEC" , "A"     , "O"    , "Tall techno pillar")                   ,
            49:   ("R" , 16 , 68  , "GOR1" , "ABCB"  , "O^"   , "Hanging victim, twitching" )           ,
            50:   ("R" , 16 , 84  , "GOR2" , "A"     , "O^"   , "Hanging victim, arms out" )            ,
            51:   ("R" , 16 , 84  , "GOR3" , "A"     , "O^"   , "Hanging victim, one-legged" )          ,
            52:   ("R" , 16 , 68  , "GOR4" , "A"     , "O^"   , "Hanging pair of legs")                 ,
            53:   ("R" , 16 , 52  , "GOR5" , "A"     , "O^"   , "Hanging leg")                          ,
            54:   ("R" , 32 , 16  , "TRE2" , "A"     , "O"    , "Large brown tree")                     ,
            55:   ("R" , 16 , 16  , "SMBT" , "ABCD"  , "O"    , "Short blue firestick")                 ,
            56:   ("R" , 16 , 16  , "SMGT" , "ABCD"  , "O"    , "Short green firestick")                ,
            57:   ("R" , 16 , 16  , "SMRT" , "ABCD"  , "O"    , "Short red firestick")                  ,
            58:   ("S" , 30 , 56  , "SARG" , "+"     , "MO"   , "Spectre")                              ,
            59:   ("R" , 16 , 84  , "GOR2" , "A"     , "^"    , "Hanging victim, arms out" )            ,
            60:   ("R" , 16 , 68  , "GOR4" , "A"     , "^"    , "Hanging pair of legs")                 ,
            61:   ("R" , 16 , 52  , "GOR3" , "A"     , "^"    , "Hanging victim, one-legged" )          ,
            62:   ("R" , 16 , 52  , "GOR5" , "A"     , "^"    , "Hanging leg")                          ,
            63:   ("R" , 16 , 68  , "GOR1" , "ABCB"  , "^"    , "Hanging victim, twitching" )           ,
            64:   ("2" , 20 , 56  , "VILE" , "+"     , "MO"   , "Arch-Vile")                            ,
            65:   ("2" , 20 , 56  , "CPOS" , "+"     , "MO"   , "Chaingunner")                          ,
            66:   ("2" , 20 , 56  , "SKEL" , "+"     , "MO"   , "Revenant")                             ,
            67:   ("2" , 48 , 64  , "FATT" , "+"     , "MO"   , "Mancubus")                             ,
            68:   ("2" , 64 , 64  , "BSPI" , "+"     , "MO"   , "Arachnotron")                          ,
            69:   ("2" , 24 , 64  , "BOS2" , "+"     , "MO"   , "Hell Knight")                          ,
            70:   ("2" , 10 , 16  , "FCAN" , "ABC"   , "O"    , "Burning barrel")                       ,
            71:   ("2" , 31 , 56  , "PAIN" , "+"     , "MO^"  , "Pain Elemental")                       ,
            72:   ("2" , 16 , 72  , "KEEN" , "A+"    , "MO^"  , "Commander Keen")                       ,
            73:   ("2" , 16 , 88  , "HDB1" , "A"     , "O^"   , "Hanging victim, guts removed")         ,
            74:   ("2" , 16 , 88  , "HDB2" , "A"     , "O^"   , "Hanging victim, guts and brain removed"),
            75:   ("2" , 16 , 64  , "HDB3" , "A"     , "O^"   , "Hanging torso, looking down")          ,
            76:   ("2" , 16 , 64  , "HDB4" , "A"     , "O^"   , "Hanging torso, open skull")            ,
            77:   ("2" , 16 , 64  , "HDB5" , "A"     , "O^"   , "Hanging torso, looking up")            ,
            78:   ("2" , 16 , 64  , "HDB6" , "A"     , "O^"   , "Hanging torso, brain removed")         ,
            79:   ("2" , 16 , 16  , "POB1" , "A"     , ""     , "Pool of blood")                        ,
            80:   ("2" , 16 , 16  , "POB2" , "A"     , ""     , "Pool of blood")                        ,
            81:   ("2" , 16 , 16  , "BRS1" , "A"     , ""     , "Pool of brains")                       ,
            82:   ("2" , 20 , 16  , "SGN2" , "A"     , "WP3"  , "Super shotgun")                        ,
            83:   ("2" , 20 , 16  , "MEGA" , "ABCD"  , "AP"   , "Megasphere")                           ,
            84:   ("2" , 20 , 56  , "SSWV" , "+"     , "MO"   , "Wolfenstein SS")                       ,
            85:   ("2" , 16 , 16  , "TLMP" , "ABCD"  , "O"    , "Tall techno floor lamp")               ,
            86:   ("2" , 16 , 16  , "TLP2" , "ABCD"  , "O"    , "Short techno floor lamp")              ,
            87:   ("2" , 20 , 32  , "none4", "-"     , ""     , "Spawn spot")                           ,
            88:   ("2" , 16 , 16  , "BBRN" , "+"     , "O5"   , "Boss Brain")                           ,
            89:   ("2" , 20 , 32  , "none6", "-"     , ""     , "Spawn shooter")                        ,
            2001: ("S" , 20 , 16  , "SHOT" , "A"     , "WP3"  , "Shotgun")                              ,
            2002: ("S" , 20 , 16  , "MGUN" , "A"     , "WP3"  , "Chaingun")                             ,
            2003: ("S" , 20 , 16  , "LAUN" , "A"     , "WP3"  , "Rocket launcher")                      ,
            2004: ("R" , 20 , 16  , "PLAS" , "A"     , "WP3"  , "Plasma rifle")                         ,
            2005: ("S" , 20 , 16  , "CSAW" , "A"     , "WP7"  , "Chainsaw")                             ,
            2006: ("R" , 20 , 16  , "BFUG" , "A"     , "WP3"  , "BFG 9000")                             ,
            2007: ("S" , 20 , 16  , "CLIP" , "A"     , "P2"   , "Ammo clip")                            ,
            2008: ("S" , 20 , 16  , "SHEL" , "A"     , "P2"   , "Shotgun shells")                       ,
            2010: ("S" , 20 , 16  , "ROCK" , "A"     , "P2"   , "Rocket")                               ,
            2011: ("S" , 20 , 16  , "STIM" , "A"     , "P8"   , "Stimpack")                             ,
            2012: ("S" , 20 , 16  , "MEDI" , "A"     , "P8"   , "Medikit")                              ,
            2013: ("S" , 20 , 16  , "SOUL" , "ABCDCB", "AP"   , "Soul sphere")                          ,
            2014: ("S" , 20 , 16  , "BON1" , "ABCDCB", "AP"   , "Health potion")                        ,
            2015: ("S" , 20 , 16  , "BON2" , "ABCDCB", "AP"   , "Spiritual armor")                      ,
            2018: ("S" , 20 , 16  , "ARM1" , "AB"    , "P9"   , "Green armor")                          ,
            2019: ("S" , 20 , 16  , "ARM2" , "AB"    , "P10"  , "Blue armor")                           ,
            2022: ("R" , 20 , 16  , "PINV" , "ABCD"  , "AP"   , "Invulnerability")                      ,
            2023: ("R" , 20 , 16  , "PSTR" , "A"     , "AP"   , "Berserk")                              ,
            2024: ("S" , 20 , 16  , "PINS" , "ABCD"  , "AP"   , "Invisibility")                         ,
            2025: ("S" , 20 , 16  , "SUIT" , "A"     , "P"    , "Radiation suit")                       ,
            2026: ("S" , 20 , 16  , "PMAP" , "ABCDCB", "AP11" , "Computer map")                         ,
            2028: ("S" , 16 , 16  , "COLU" , "A"     , "O"    , "Floor lamp")                           ,
            2035: ("S" , 10 , 42  , "BAR1" , "AB+"   , "O"    , "Barrel")                               ,
            2045: ("S" , 20 , 16  , "PVIS" , "AB"    , "AP"   , "Light amplification visor")            ,
            2046: ("S" , 20 , 16  , "BROK" , "A"     , "P2"   , "Box of rockets")                       ,
            2047: ("R" , 20 , 16  , "CELL" , "A"     , "P2"   , "Cell charge")                          ,
            2048: ("S" , 20 , 16  , "AMMO" , "A"     , "P2"   , "Box of ammo")                          ,
            2049: ("S" , 20 , 16  , "SBOX" , "A"     , "P2"   , "Box of shells")                        ,
            3001: ("S" , 20 , 56  , "TROO" , "+"     , "MO"   , "Imp")                                  ,
            3002: ("S" , 30 , 56  , "SARG" , "+"     , "MO"   , "Demon")                                ,
            3003: ("S" , 24 , 64  , "BOSS" , "+"     , "MO"   , "Baron of Hell")                        ,
            3004: ("S" , 20 , 56  , "POSS" , "+"     , "MO"   , "Former Human Trooper")                 ,
            3005: ("R" , 31 , 56  , "HEAD" , "+"     , "MO^"  , "Cacodemon")                            ,
            3006: ("R" , 16 , 56  , "SKUL" , "+"     , "M12O^", "Lost Soul")                            ,
        ]

    // swift-format-ignore
    static let doorTypes:
        [Int: (
            class: ObjectClass, trigger: Trigger, lock: DoorLock, speed: Speed, wait: Int, monsters: Bool?,
            function: DoorFunction
        )] = [
            1:   (.regular , .pr, .none  , .slow, 4 , true , .openWaitThenClose),
            117: (.regular , .pr, .none  , .fast, 4 , false, .openWaitThenClose),
            63:  (.regular , .sr, .none  , .slow, 4 , false, .openWaitThenClose),
            114: (.regular , .sr, .none  , .fast, 4 , false, .openWaitThenClose),
            29:  (.regular , .s1, .none  , .slow, 4 , false, .openWaitThenClose),
            111: (.regular , .s1, .none  , .fast, 4 , false, .openWaitThenClose),
            90:  (.regular , .wr, .none  , .slow, 4 , false, .openWaitThenClose),
            105: (.regular , .wr, .none  , .fast, 4 , false, .openWaitThenClose),
            4:   (.regular , .w1, .none  , .slow, 4 , true , .openWaitThenClose),
            108: (.regular , .w1, .none  , .fast, 4 , false, .openWaitThenClose),
            31:  (.regular , .p1, .none  , .slow, -1, false, .openStayOpen)     ,
            118: (.regular , .p1, .none  , .fast, -1, false, .openStayOpen)     ,
            61:  (.regular , .sr, .none  , .slow, -1, false, .openStayOpen)     ,
            115: (.regular , .sr, .none  , .fast, -1, false, .openStayOpen)     ,
            103: (.regular , .s1, .none  , .slow, -1, false, .openStayOpen)     ,
            112: (.regular , .s1, .none  , .fast, -1, false, .openStayOpen)     ,
            86:  (.regular , .wr, .none  , .slow, -1, false, .openStayOpen)     ,
            106: (.regular , .wr, .none  , .fast, -1, false, .openStayOpen)     ,
            2:   (.regular , .w1, .none  , .slow, -1, false, .openStayOpen)     ,
            109: (.regular , .w1, .none  , .fast, -1, false, .openStayOpen)     ,
            46:  (.regular , .gr, .none  , .slow, -1, false, .openStayOpen)     ,
            42:  (.regular , .sr, .none  , .slow, -1, false, .closeStayClosed)  ,
            116: (.regular , .sr, .none  , .fast, -1, false, .closeStayClosed)  ,
            50:  (.regular , .s1, .none  , .slow, -1, false, .closeStayClosed)  ,
            113: (.regular , .s1, .none  , .fast, -1, false, .closeStayClosed)  ,
            75:  (.regular , .wr, .none  , .slow, -1, false, .closeStayClosed)  ,
            107: (.regular , .wr, .none  , .fast, -1, false, .closeStayClosed)  ,
            3:   (.regular , .w1, .none  , .slow, -1, false, .closeStayClosed)  ,
            110: (.regular , .w1, .none  , .fast, -1, false, .closeStayClosed)  ,
            196: (.extended, .sr, .none  , .slow, 30, false, .closeWaitThenOpen),
            175: (.extended, .s1, .none  , .slow, 30, false, .closeWaitThenOpen),
            76:  (.regular , .wr, .none  , .slow, 30, false, .closeWaitThenOpen),
            16:  (.regular , .w1, .none  , .slow, 30, false, .closeWaitThenOpen),
            26:  (.regular , .pr, .blue  , .slow, 4 , false, .openWaitThenClose),
            28:  (.regular , .pr, .red   , .slow, 4 , false, .openWaitThenClose),
            27:  (.regular , .pr, .yellow, .slow, 4 , false, .openWaitThenClose),
            32:  (.regular , .p1, .blue  , .slow, -1, false, .openStayOpen)     ,
            33:  (.regular , .p1, .red   , .slow, -1, false, .openStayOpen)     ,
            34:  (.regular , .p1, .yellow, .slow, -1, false, .openStayOpen)     ,
            99:  (.regular , .sr, .blue  , .fast, -1, false, .openStayOpen)     ,
            134: (.regular , .sr, .red   , .fast, -1, false, .openStayOpen)     ,
            136: (.regular , .sr, .yellow, .fast, -1, false, .openStayOpen)     ,
            133: (.regular , .s1, .blue  , .fast, -1, false, .openStayOpen)     ,
            135: (.regular , .s1, .red   , .fast, -1, false, .openStayOpen)     ,
            137: (.regular , .s1, .yellow, .fast, -1, false, .openStayOpen)     ,
        ]

    enum FloorTarget {
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

    // swift-format-ignore
    static let floorTypes:
        [Int: (
            class: ObjectClass, trigger: Trigger, direction: Direction, speed: Speed, chg: String, mdl: String,
            monsters: Bool, crushing: Bool, target: FloorTarget
        )] = [
            60:  (.regular , .sr , .down, .slow, "None", "--" , false, false, .lowestNeighborFloor)         ,
            23:  (.regular , .s1 , .down, .slow, "None", "--" , false, false, .lowestNeighborFloor)         ,
            82:  (.regular , .wr , .down, .slow, "None", "--" , false, false, .lowestNeighborFloor)         ,
            38:  (.regular , .w1 , .down, .slow, "None", "--" , false, false, .lowestNeighborFloor)         ,
            177: (.extended, .sr , .down, .slow, "TxTy", "Num", false, false, .lowestNeighborFloor)         ,
            159: (.extended, .s1 , .down, .slow, "TxTy", "Num", false, false, .lowestNeighborFloor)         ,
            84:  (.regular , .wr , .down, .slow, "TxTy", "Num", false, false, .lowestNeighborFloor)         ,
            37:  (.regular , .w1 , .down, .slow, "TxTy", "Num", false, false, .lowestNeighborFloor)         ,
            69:  (.regular , .sr , .up  , .slow, "None", "--" , false, false, .nextNeighborFloor)           ,
            18:  (.regular , .s1 , .up  , .slow, "None", "--" , false, false, .nextNeighborFloor)           ,
            128: (.regular , .wr , .up  , .slow, "None", "--" , false, false, .nextNeighborFloor)           ,
            119: (.regular , .w1 , .up  , .slow, "None", "--" , false, false, .nextNeighborFloor)           ,
            132: (.regular , .sr , .up  , .fast, "None", "--" , false, false, .nextNeighborFloor)           ,
            131: (.regular , .s1 , .up  , .fast, "None", "--" , false, false, .nextNeighborFloor)           ,
            129: (.regular , .wr , .up  , .fast, "None", "--" , false, false, .nextNeighborFloor)           ,
            130: (.regular , .w1 , .up  , .fast, "None", "--" , false, false, .nextNeighborFloor)           ,
            222: (.extended, .sr , .down, .slow, "None", "--" , false, false, .nextNeighborFloor)           ,
            221: (.extended, .s1 , .down, .slow, "None", "--" , false, false, .nextNeighborFloor)           ,
            220: (.extended, .wr , .down, .slow, "None", "--" , false, false, .nextNeighborFloor)           ,
            219: (.extended, .w1 , .down, .slow, "None", "--" , false, false, .nextNeighborFloor)           ,
            64:  (.regular , .sr , .up  , .slow, "None", "--" , false, false, .lowestNeighborCeiling)       ,
            101: (.regular , .s1 , .up  , .slow, "None", "--" , false, false, .lowestNeighborCeiling)       ,
            91:  (.regular , .wr , .up  , .slow, "None", "--" , false, false, .lowestNeighborCeiling)       ,
            5:   (.regular , .w1 , .up  , .slow, "None", "--" , false, false, .lowestNeighborCeiling)       ,
            24:  (.regular , .g1, .up  , .slow, "None", "--" , false, false, .lowestNeighborCeiling)       ,
            65:  (.regular , .sr , .up  , .slow, "None", "--" , false, true , .lowestNeighborCeilingMinus8) ,
            55:  (.regular , .s1 , .up  , .slow, "None", "--" , false, true , .lowestNeighborCeilingMinus8) ,
            94:  (.regular , .wr , .up  , .slow, "None", "--" , false, true , .lowestNeighborCeilingMinus8) ,
            56:  (.regular , .w1 , .up  , .slow, "None", "--" , false, true , .lowestNeighborCeilingMinus8) ,
            45:  (.regular , .sr , .down, .slow, "None", "--" , false, false, .highestNeighborFloor)        ,
            102: (.regular , .s1 , .down, .slow, "None", "--" , false, false, .highestNeighborFloor)        ,
            83:  (.regular , .wr , .down, .slow, "None", "--" , false, false, .highestNeighborFloor)        ,
            19:  (.regular , .w1 , .down, .slow, "None", "--" , false, false, .highestNeighborFloor)        ,
            70:  (.regular , .sr , .down, .fast, "None", "--" , false, false, .highestNeighborFloorPlus8)   ,
            71:  (.regular , .s1 , .down, .fast, "None", "--" , false, false, .highestNeighborFloorPlus8)   ,
            98:  (.regular , .wr , .down, .fast, "None", "--" , false, false, .highestNeighborFloorPlus8)   ,
            36:  (.regular , .w1 , .down, .fast, "None", "--" , false, false, .highestNeighborFloorPlus8)   ,
            180: (.extended, .sr , .up  , .slow, "None", "--" , false, false, .absolute24)                  ,
            161: (.extended, .s1 , .up  , .slow, "None", "--" , false, false, .absolute24)                  ,
            92:  (.regular , .wr , .up  , .slow, "None", "--" , false, false, .absolute24)                  ,
            58:  (.regular , .w1 , .up  , .slow, "None", "--" , false, false, .absolute24)                  ,
            179: (.extended, .sr , .up  , .slow, "TxTy", "Trg", false, false, .absolute24)                  ,
            160: (.extended, .s1 , .up  , .slow, "TxTy", "Trg", false, false, .absolute24)                  ,
            93:  (.regular , .wr , .up  , .slow, "TxTy", "Trg", false, false, .absolute24)                  ,
            59:  (.regular , .w1 , .up  , .slow, "TxTy", "Trg", false, false, .absolute24)                  ,
            176: (.extended, .sr , .up  , .slow, "None", "--" , false, false, .absoluteShortestLowerTexture),
            158: (.extended, .s1 , .up  , .slow, "None", "--" , false, false, .absoluteShortestLowerTexture),
            96:  (.regular , .wr , .up  , .slow, "None", "--" , false, false, .absoluteShortestLowerTexture),
            30:  (.regular , .w1 , .up  , .slow, "None", "--" , false, false, .absoluteShortestLowerTexture),
            178: (.extended, .sr , .up  , .slow, "None", "--" , false, false, .absolute512)                 ,
            140: (.regular , .s1 , .up  , .slow, "None", "--" , false, false, .absolute512)                 ,
            147: (.extended, .wr , .up  , .slow, "None", "--" , false, false, .absolute512)                 ,
            142: (.extended, .w1 , .up  , .slow, "None", "--" , false, false, .absolute512)                 ,
            190: (.extended, .sr , .none, .na  , "TxTy", "Trg", false, false, .none)                        ,
            189: (.extended, .s1 , .none, .na  , "TxTy", "Trg", false, false, .none)                        ,
            154: (.extended, .wr , .none, .na  , "TxTy", "Trg", false, false, .none)                        ,
            153: (.extended, .w1 , .none, .na  , "TxTy", "Trg", false, false, .none)                        ,
            78:  (.extended, .sr , .none, .na  , "TxTy", "Num", false, false, .none)                        ,
            241: (.extended, .s1 , .none, .na  , "TxTy", "Num", false, false, .none)                        ,
            240: (.extended, .wr , .none, .na  , "TxTy", "Num", false, false, .none)                        ,
            239: (.extended, .w1 , .none, .na  , "TxTy", "Num", false, false, .none)                        ,
        ]

    enum CeilingTarget {
        case floor
        case highestNeighborCeiling
        case eightAboveFloor
        case lowestNeighborFloor
        case highestNeighborFloor
        case lowestNeighborCeiling
        case none
    }

    // swift-format-ignore
    static let ceilingTypes:
        [Int: (
            class: ObjectClass, trigger: Trigger, direction: Direction, speed: Speed, chg: String, mdl: String,
            monsters: Bool, crushnig: Bool, target: CeilingTarget
        )] =
            [
                43:  (.regular , .sr, .down, .fast, "None", "--", false, false, .floor)                 ,
                41:  (.regular , .s1, .down, .fast, "None", "--", false, false, .floor)                 ,
                152: (.extended, .wr, .down, .fast, "None", "--", false, false, .floor)                 ,
                145: (.extended, .w1, .down, .fast, "None", "--", false, false, .floor)                 ,
                186: (.extended, .sr, .up  , .slow, "None", "--", false, false, .highestNeighborCeiling),
                166: (.extended, .s1, .up  , .slow, "None", "--", false, false, .highestNeighborCeiling),
                151: (.extended, .wr, .up  , .slow, "None", "--", false, false, .highestNeighborCeiling),
                40:  (.regular , .w1, .up  , .slow, "None", "--", false, false, .highestNeighborCeiling),
                187: (.extended, .sr, .down, .slow, "None", "--", false, false, .eightAboveFloor)       ,
                167: (.extended, .s1, .down, .slow, "None", "--", false, false, .eightAboveFloor)       ,
                72:  (.regular , .wr, .down, .slow, "None", "--", false, false, .eightAboveFloor)       ,
                44:  (.regular , .w1, .down, .slow, "None", "--", false, false, .eightAboveFloor)       ,
                205: (.extended, .sr, .down, .slow, "None", "--", false, false, .lowestNeighborCeiling) ,
                203: (.extended, .s1, .down, .slow, "None", "--", false, false, .lowestNeighborCeiling) ,
                201: (.extended, .wr, .down, .slow, "None", "--", false, false, .lowestNeighborCeiling) ,
                199: (.extended, .w1, .down, .slow, "None", "--", false, false, .lowestNeighborCeiling) ,
                206: (.extended, .sr, .down, .slow, "None", "--", false, false, .highestNeighborFloor)  ,
                204: (.extended, .s1, .down, .slow, "None", "--", false, false, .highestNeighborFloor)  ,
                202: (.extended, .wr, .down, .slow, "None", "--", false, false, .highestNeighborFloor)  ,
                200: (.extended, .w1, .down, .slow, "None", "--", false, false, .highestNeighborFloor)  ,
            ]

    enum PlatformTarget {
        case raise24Units
        case raise32Units
        case raiseNextFloor
        case lowestHighestFloorPeprpetual
        case stop
        case lowestNeighborFloor
        case ceilingToggle
    }

    // swift-format-ignore
    static let platformTypes:
        [Int: (
            class: ObjectClass, trigger: Trigger, delay: Int, speed: Speed, chg: String, mdl: String,
            monsters: Bool?, target: PlatformTarget
        )] = [
            66:  (.regular  , .sr, -1, .slow, "Tx"  , "Trg", false, .raise24Units)                 ,
            15:  (.regular  , .s1, -1, .slow, "Tx"  , "Trg", false, .raise24Units)                 ,
            148: (.extended , .wr, -1, .slow, "Tx"  , "Trg", false, .raise24Units)                 ,
            143: (.extended , .w1, -1, .slow, "Tx"  , "Trg", false, .raise24Units)                 ,
            67:  (.regular  , .sr, -1, .slow, "Tx0" , "Trg", false, .raise32Units)                 ,
            14:  (.regular  , .s1, -1, .slow, "Tx0" , "Trg", false, .raise32Units)                 ,
            149: (.extended , .wr, -1, .slow, "Tx0" , "Trg", false, .raise32Units)                 ,
            144: (.extended , .w1, -1, .slow, "Tx0" , "Trg", false, .raise32Units)                 ,
            68:  (.regular  , .sr, -1, .slow, "Tx0" , "Trg", false, .raiseNextFloor)               ,
            20:  (.regular  , .s1, -1, .slow, "Tx0" , "Trg", false, .raiseNextFloor)               ,
            95:  (.regular  , .wr, -1, .slow, "Tx0" , "Trg", false, .raiseNextFloor)               ,
            22:  (.regular  , .w1, -1, .slow, "Tx0" , "Trg", false, .raiseNextFloor)               ,
            47:  (.regular  , .g1, -1, .slow, "Tx0" , "Trg", false, .raiseNextFloor)               ,
            181: ( .extended, .sr, 3 , .slow, "None", "--" , false, .lowestHighestFloorPeprpetual) ,
            162: ( .extended, .s1, 3 , .slow, "None", "--" , false, .lowestHighestFloorPeprpetual) ,
            87:  (.regular  , .wr, 3 , .slow, "None", "--" , false, .lowestHighestFloorPeprpetual) ,
            53:  (.regular  , .w1, 3 , .slow, "None", "--" , false, .lowestHighestFloorPeprpetual) ,
            163: (.extended , .s1, -1, .na  , "----", "--" , nil  , .stop)                         ,
            182: (.extended , .sr, -1, .na  , "----", "--" , nil  , .stop)                         ,
            89:  (.regular  , .wr, -1, .na  , "----", "--" , nil  , .stop)                         ,
            54:  (.regular  , .w1, -1, .na  , "----", "--" , nil  , .stop)                         ,
            62:  (.regular  , .sr, 3 , .slow, "None", "--" , false, .lowestNeighborFloor)          ,
            21:  (.regular  , .s1, 3 , .slow, "None", "--" , false, .lowestNeighborFloor)          ,
            88:  (.regular  , .wr, 3 , .slow, "None", "--" , false, .lowestNeighborFloor)          ,
            10:  (.regular  , .w1, 3 , .slow, "None", "--" , false, .lowestNeighborFloor)          ,
            123: (.regular  , .sr, 3 , .fast, "None", "--" , false, .lowestNeighborFloor)          ,
            122: (.regular  , .s1, 3 , .fast, "None", "--" , false, .lowestNeighborFloor)          ,
            120: (.regular  , .wr, 3 , .fast, "None", "--" , false, .lowestNeighborFloor)          ,
            121: (.regular  , .w1, 3 , .fast, "None", "--" , false, .lowestNeighborFloor)          ,
            212: (.extended , .wr, -1, .inst, "None", "--" , false, .ceilingToggle)                ,
            211: (.extended , .sr, -1, .inst, "None", "--" , false, .ceilingToggle)                ,
        ]

    // swift-format-ignore
    static let crusherTypes:
        [Int: (
            class: ObjectClass, trigger: Trigger, speed: Speed, monsters: Bool?, sillent: Bool?,
            action: String
        )] = [
            184: (.extended, .sr, .slow, false, false, "Start"),
            49:  (.regular , .s1, .slow, false, false, "Start"),
            73:  (.regular , .wr, .slow, false, false, "Start"),
            25:  (.regular , .w1, .slow, false, false, "Start"),
            183: (.extended, .sr, .fast, false, false, "Start"),
            164: (.extended, .s1, .fast, false, false, "Start"),
            77:  (.regular , .wr, .fast, false, false, "Start"),
            6:   (.regular , .w1, .fast, false, false, "Start"),
            185: (.extended, .sr, .slow, false, true , "Start"),
            165: (.extended, .s1, .slow, false, true , "Start"),
            150: (.extended, .wr, .slow, false, true , "Start"),
            141: (.regular , .w1, .slow, false, true , "Start"),
            188: (.extended, .sr, .na  , nil  , nil  , "Stop") ,
            168: (.extended, .s1, .na  , nil  , nil  , "Stop") ,
            74:  (.regular , .wr, .na  , nil  , nil  , "Stop") ,
            57:  (.regular , .w1, .na  , nil  , nil  , "Stop") ,
        ]

    // swift-format-ignore
    static let stairTypes:
        [Int: (
            class: ObjectClass, trigger: Trigger, direction: Direction, speed: Speed, step: Int,
            ignore: Bool, monsters: Bool
        )] = [
            258: (.extended, .sr, .up, .slow, 8 , false, false),
            7:   (.regular , .s1, .up, .slow, 8 , false, false),
            256: (.extended, .wr, .up, .slow, 8 , false, false),
            8:   (.regular , .w1, .up, .slow, 8 , false, false),
            259: (.extended, .sr, .up, .fast, 16, false, false),
            127: (.regular , .s1, .up, .fast, 16, false, false),
            257: (.extended, .wr, .up, .fast, 16, false, false),
            100: (.regular , .w1, .up, .fast, 16, false, false),
        ]

    enum ElevatorTarget {
        case nextHighestFloor
        case nextLowestFloor
        case currentFloor
    }

    // swift-format-ignore
    static let elevatorTypes:
        [Int: (class: ObjectClass, trigger: Trigger, speed: Speed, target: ElevatorTarget
        )] = [
            230: (.extended, .sr, .fast,.nextHighestFloor),
            229: (.extended, .s1, .fast,.nextHighestFloor),
            228: (.extended, .wr, .fast,.nextHighestFloor),
            227: (.extended, .w1, .fast,.nextHighestFloor),
            234: (.extended, .sr, .fast, .nextLowestFloor),
            233: (.extended, .s1, .fast, .nextLowestFloor),
            232: (.extended, .wr, .fast, .nextLowestFloor),
            231: (.extended, .w1, .fast, .nextLowestFloor),
            238: (.extended, .sr, .fast, .currentFloor)   ,
            237: (.extended, .s1, .fast, .currentFloor)   ,
            236: (.extended, .wr, .fast, .currentFloor)   ,
            235: (.extended, .w1, .fast, .currentFloor)   ,
        ]
}

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

        func decode(_ type: String.Type, count: Int = 8) throws -> String {
            let chars = try decode(UInt8.self, count: count)
            let str = String(bytes: chars, encoding: .utf8)!
            return String(str.prefix(while: { $0 != "\0" })).uppercased()
        }

        func decode<T: FixedWidthInteger>(_ type: T.Type, count: Int) throws -> [T] {
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

        func decode<T: FixedWidthInteger>(_ type: T.Type) throws -> T {
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
            filePos = try decoder.decode(Int32.self)
            size = try decoder.decode(Int32.self)
            name = try decoder.decode(String.self, count: 8)
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
                    try decoder.decode(UInt8.self), try decoder.decode(UInt8.self),
                    try decoder.decode(UInt8.self)
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
            pixels = try decoder.decode(UInt8.self, count: Flat.byteWidth)
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

            width = try decoder.decode(UInt16.self)
            height = try decoder.decode(UInt16.self)
            leftOffset = try decoder.decode(Int16.self)
            topOffset = try decoder.decode(Int16.self)

            let columnOfs = try decoder.decode(UInt32.self, count: Int(width))

            columns = try columnOfs.map { offset in
                decoder.seek(pos + Int(offset))
                var column: [(topDelta: UInt8, data: [UInt8])] = []
                while case let topDelta = try decoder.decode(UInt8.self), topDelta != 255 {
                    let length = try decoder.decode(UInt8.self)
                    _ = try decoder.decode(UInt8.self)
                    let data = try decoder.decode(UInt8.self, count: Int(length))
                    _ = try decoder.decode(UInt8.self)
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
            originX = try decoder.decode(Int16.self)
            originY = try decoder.decode(Int16.self)
            patchId = try decoder.decode(Int16.self)
            stepDir = try decoder.decode(Int16.self)
            colorMap = try decoder.decode(Int16.self)
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
            name = try decoder.decode(String.self, count: 8)
            masked = try decoder.decode(UInt32.self)
            width = try decoder.decode(UInt16.self)
            height = try decoder.decode(UInt16.self)
            columnDirectory = try decoder.decode(UInt32.self)

            let patchCount = try decoder.decode(UInt16.self)
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
            x = try decoder.decode(Int16.self)
            y = try decoder.decode(Int16.self)
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
            floorHeight = try decoder.decode(Int16.self)
            ceilingHeight = try decoder.decode(Int16.self)
            floorTextureName = try decoder.decode(String.self)
            ceilingTextureName = try decoder.decode(String.self)
            lightLevel = try decoder.decode(Int16.self)
            specialType = try decoder.decode(Int16.self)
            tagNumber = try decoder.decode(Int16.self)
        }

        func export(with exporter: WAD.Exporter) -> Goom.Sector {
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
            xOffset = try decoder.decode(Int16.self)
            yOffset = try decoder.decode(Int16.self)
            upperTextureName = try decoder.decode(String.self)
            lowerTextureName = try decoder.decode(String.self)
            middleTextureName = try decoder.decode(String.self)
            sectorId = try decoder.decode(Int16.self)
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
            startVertexId = try decoder.decode(Int16.self)
            endVertexId = try decoder.decode(Int16.self)
            flags = Flags(rawValue: try decoder.decode(Int16.self))
            specialType = try decoder.decode(Int16.self)
            sectorTag = try decoder.decode(Int16.self)
            frontSideDefId = try decoder.decode(UInt16.self)
            backSideDefId = try decoder.decode(UInt16.self)
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
                let upperU = Space(begin: ox, end: ox + length)
                let middleU = Space(begin: ox, end: ox + length)
                let lowerU = Space(begin: ox, end: ox + length)

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
                base: Goom.Segment(v1: goomStartVertex, v2: goomEndVertex),
                top: Goom.Wall.Part(
                    texture: base.topTextureName != nil
                        ? exporter.findTexture(named: base.topTextureName!) : nil,
                    uSpaceStates: [base.upperU, alt.upperU],
                    vSpaceStates: [base.upperV, alt.upperV]
                ),
                middle: Goom.Wall.Part(
                    texture: exporter.findTexture(named: base.midTextureName),
                    uSpaceStates: [base.middleU, alt.middleU],
                    vSpaceStates: [base.middleV, alt.middleV]
                ),
                bottom: Goom.Wall.Part(
                    texture: exporter.findTexture(named: base.bottomTextureName),
                    uSpaceStates: [base.lowerU, alt.lowerU],
                    vSpaceStates: [base.lowerV, alt.lowerV]
                ),
                frontSector: exporter.sectors[Int(frontSideDef.sectorId)],
                backSector: backSideDef != nil
                    ? exporter.sectors[Int(backSideDef!.sectorId)] : nil
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
            x = try decoder.decode(Int16.self)
            y = try decoder.decode(Int16.self)
            angle = try decoder.decode(Int16.self)
            type = try decoder.decode(Int16.self)
            flags = try decoder.decode(Int16.self)
        }

        func export(with exporter: Exporter) -> Goom.Thing {
            let prefix = Meta.thingTypes[Int(type)]!.sprite
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
            sectors.map {
                $0.export(with: exporter)
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
        let magic = try decoder.decode(UInt8.self, count: 4)
        if magic != "IWAD".utf8.map({ UInt8($0) }) {
            throw BinaryDecoderError.runtimeError("Not an IWAD.")
        }
        let numLumps = try decoder.decode(Int32.self)
        let infoTableOfs = try decoder.decode(Int32.self)
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
                    colorMap.append(try decoder.decode(UInt8.self, count: 256))
                }
                print("  \(colorMap.count) levels in the color map")

            case "PNAMES":
                print(lump.name)
                let n = try decoder.decode(UInt32.self)
                for _ in 0..<n {
                    pNames.append(try decoder.decode(String.self, count: 8))
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
                let numTextures = try decoder.decode(Int32.self)
                let offsets = try decoder.decode(Int32.self, count: Int(numTextures))
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
        var textures: OrderedDictionary<String, Goom.Texture> = [:]
        var sectors: [Goom.Sector] = []
        var sectorAltHeights: [Sector: (floor: Int16, ceiling: Int16)] = [:]
        var walls: [Goom.Wall] = []
        var things: [Goom.Thing] = []
        var altState: Bool = false

        init(wad: WAD) {
            self.wad = wad
        }

        func findTexture(named name: String) -> Goom.Texture? {
            return textures[name]
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
            let doorType = Meta.doorTypes[Int(doorLineDef.specialType)]!
            var doorSectors: [Sector] = []
            if doorType.trigger == .p1 || doorType.trigger == .pr {
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
            let platformType = Meta.platformTypes[Int(platformLineDef.specialType)]!
            guard
                let platformSector = exporter.map.sectors.first(where: {
                    $0.tagNumber == platformLineDef.sectorTag
                })
            else { return }

            let ceilingHeight = platformSector.ceilingHeight
            var floorHeight = platformSector.floorHeight
            let neighbors = exporter.findNeighbors(ofSector: platformSector)

            switch platformType.target {
            case .raise24Units:
                floorHeight += 24

            case .raise32Units:
                floorHeight += 32

            case .raiseNextFloor:
                // This means that the "high" height is the lowest surrounding floor
                // higher than the platform. If no higher adjacent floor exists no
                // motion will occur.
                floorHeight =
                    neighbors.filter({ $0.floorHeight > floorHeight }).map({ $0.floorHeight }).min()
                    ?? floorHeight

            case .lowestHighestFloorPeprpetual:
                // This target sets the "low" height to the lowest neighboring
                // floor, including the floor itself, and the "high" height to the
                // highest neighboring floor, including the floor itself. When this
                // target is used the floor moves perpetually between the two
                // heights. Once triggered this type of linedef runs permanently,
                // even if the motion is temporarily suspended with a Stop type. No
                // other floor action can be commanded on the sector after this type
                // is begun.
                floorHeight = (neighbors + [platformSector]).map({ $0.floorHeight }).max()!

            case .stop:
                floorHeight = 0  // # ??

            case .lowestNeighborFloor:
                // This means that the platforms "low" height is the height of the
                // lowest surrounding floor, including the platform itself. The
                // "high" height is the original height of the floor.
                floorHeight = (neighbors + [platformSector]).map({ $0.floorHeight }).min()!

            case .ceilingToggle:
                // This target sets the "high" height to the ceiling of the sector
                // and the "low" height to the floor height of the sector and is
                // only used in the instant toggle type that switches the floor
                // between the ceiling and its original height on each activation.
                // This is also the ONLY instant platform type.
                floorHeight = ceilingHeight
            }
            exporter.sectorAltHeights[platformSector] = (floorHeight, ceilingHeight)
        }

        func animate(floor floorLineDef: LineDef, with exporter: Exporter) {
            let floorType = Meta.floorTypes[Int(floorLineDef.specialType)]!
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

                case .nextNeighborFloor where floorType.direction == .down:
                    floorHeight =
                        neighbors.filter({ $0.floorHeight < floorHeight }).map({ $0.floorHeight })
                        .max()
                        ?? floorHeight

                case .nextNeighborFloor where floorType.direction == .up:
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
                    floorHeight += (floorType.direction == .up) ? Int16(24) : Int16(-24)

                case .absolute512:
                    floorHeight += (floorType.direction == .up) ? Int16(512) : Int16(-512)

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

        var goomMaps: [Goom.Map] = []
        let exporter = Exporter(wad: self)

        for texture in textures {
            let (pixels, mask) = split(texture.exportPixels(fromWad: self))
            exporter.textures[texture.name] =
                Goom.Texture(
                    name: texture.name,
                    pixels: pixels,
                    mask: mask,
                    width: Int(texture.width),
                    height: Int(texture.height),
                    offset: Vector(x: 0, y: 0),
                    isSky: Regex(#".*SKY.*"#) ~= texture.name
                )
        }

        for (flatName, flat) in flats {
            exporter.textures[flatName] =
                Goom.Texture(
                    name: flatName,
                    pixels: flat.exportPixels(),
                    mask: nil,
                    width: Int(Flat.width),
                    height: Int(Flat.height),
                    offset: Vector(x: 0, y: 0),
                    isSky: Regex(#".*SKY.*"#) ~= flatName
                )
        }

        for (spriteName, sprite) in sprites {
            let (pixels, mask) = split(sprite.exportPixels())
            exporter.textures[spriteName] =
                Goom.Texture(
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
                case _ where Meta.doorTypes[type] != nil:
                    exporter.animate(door: lineDef, with: exporter)
                case _ where Meta.floorTypes[type] != nil:
                    exporter.animate(floor: lineDef, with: exporter)
                case _ where Meta.platformTypes[type] != nil:
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
            textures: Array(exporter.textures.values),
            palettes: colorMap[0..<32].map { $0.map { pack(tuple: playPals[0].colors[Int($0)]) } }
        )
    }
}

func loadWAD(fromURL url: URL) throws -> Goom.World {
    let wad = try WAD(fromURL: url)
    return wad.export()
}
