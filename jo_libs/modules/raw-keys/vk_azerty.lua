jo.file.load("raw-keys.vk_qwerty")

vk_azerty = {
    A = vk_qwerty["Q"], 
    Z = vk_qwerty["W"],  
    Q = vk_qwerty["A"], 
    W = vk_qwerty["Z"], 
    M = vk_qwerty["OEM_1"], -- M = ,

    OEM_PERIOD = vk_qwerty["OEM_COMMA"], -- ; = :
    [";"] = vk_qwerty["OEM_COMMA"], -- ; = :

    OEM_2 = vk_qwerty["OEM_PERIOD"], -- : = ;
    [":"] = vk_qwerty["OEM_PERIOD"], -- : = ;
    
    OEM_COMMA = vk_qwerty["M"],
    [","] = vk_qwerty["M"],

    ["*"] = vk_qwerty["OEM_5"],
    ["!"] = vk_qwerty["OEM_2"],
    ["ù"] =  vk_qwerty["OEM_7"],
    ["^"] =  vk_qwerty["OEM_4"],
    ["$"] =  vk_qwerty["OEM_6"],
}

