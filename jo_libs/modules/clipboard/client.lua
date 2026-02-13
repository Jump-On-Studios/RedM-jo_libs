jo.createModule("clipboard")


--- Copy a string to the user clipboard
---@param value string (The string to copy)
jo.clipboard.copy = function(value)
    return exports.jo_libs:clipboard_copy(value)
end
