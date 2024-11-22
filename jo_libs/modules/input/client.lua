jo.input = {}

---@param label string The Text above the typing field in the black square
---@param placeholder string An Example Text, what it should say in the typing field
---@param maxStringLenght? integer (optional) Maximum String Lenght
---@return string
function jo.input.native(label, placeholder, maxStringLenght)
    AddTextEntry('FMMC_KEY_TIP1', label)
    DisplayOnscreenKeyboard(0, "FMMC_KEY_TIP1", "", placeholder, "", "", "", maxStringLenght or 60)

    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
      Wait(0)
    end
        
    if UpdateOnscreenKeyboard() ~= 2 then
      local result = GetOnscreenKeyboardResult() --Gets the result of the typing
      Wait(100)
      return result or ''
    else
      Wait(100)
      return ''
    end
end
