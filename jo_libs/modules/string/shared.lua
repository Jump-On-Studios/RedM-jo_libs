---@param str string
---@return string str String with first letter in uppercase
function string.firstToUpper(str)
  return (str:gsub("^%l", string.upper))
end
