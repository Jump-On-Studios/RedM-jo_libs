jo.file.load("raw-keys.vk_qwerty")

vk_azerty = {
    A = vk_qwerty["Q"],
    Z = vk_qwerty["W"],
    Q = vk_qwerty["A"],
    W = vk_qwerty["Z"],
    M = vk_qwerty["OEM_1"],              -- M = ,

    OEM_PERIOD = vk_qwerty["OEM_COMMA"], -- ; = :
    [";"] = vk_qwerty["OEM_COMMA"],      -- ; = :

    OEM_2 = vk_qwerty["OEM_PERIOD"],     -- : = ;
    [":"] = vk_qwerty["OEM_PERIOD"],     -- : = ;

    OEM_COMMA = vk_qwerty["M"],
    [","] = vk_qwerty["M"],

    ["*"] = vk_qwerty["OEM_5"],
    ["!"] = vk_qwerty["OEM_2"],
    ["ù"] = vk_qwerty["OEM_7"],
    ["^"] = vk_qwerty["OEM_4"],
    ["$"] = vk_qwerty["OEM_6"],
}

vk_azerty_hexa = {
    [0x41] = vk_qwerty["Q"],          -- A
    [0x5A] = vk_qwerty["W"],          -- Z
    [0x51] = vk_qwerty["A"],          -- Q
    [0x57] = vk_qwerty["Z"],          -- W
    [0x4D] = vk_qwerty["OEM_1"],      -- M = ,

    [0xBE] = vk_qwerty["OEM_COMMA"],  -- ; = :

    [0xBF] = vk_qwerty["OEM_PERIOD"], -- : = ;

    [0xBC] = vk_qwerty["M"],

    [0x6A] = vk_qwerty["OEM_5"], -- "*" = MULTIPLY/NUMPAD_MULTIPLY
    [0xDF] = vk_qwerty["OEM_2"],
    [0xC0] = vk_qwerty["OEM_7"],
    [0xDD] = vk_qwerty["OEM_4"],
    [0xBA] = vk_qwerty["OEM_6"],
}
