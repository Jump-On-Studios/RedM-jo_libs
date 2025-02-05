jo.debug = {}

jo.debug.perfomance = function(title, cb)
  local starTime = os.microtime()
  local result = table.pack(cb())
  local endTime = os.microtime()
  print(("%d, Performance: %s -> %d μs"):format(os.time(), title, endTime - starTime))
  return table.unpack(result)
end
