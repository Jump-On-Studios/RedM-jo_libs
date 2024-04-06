function RequestControl(entity)
  while not NetworkHasControlOfEntity(entity) do
    NetworkRequestControlOfEntity(entity)
    Wait(100)
  end
end