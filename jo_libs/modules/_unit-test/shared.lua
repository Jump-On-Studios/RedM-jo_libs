jo.require("file")

local context = IsDuplicityVersion() and "server" or "client"

RegisterCommand("jo_unit_test", function(source, args)
  local module = args[1]
  local testName = args[2]
  if not module then return eprint("Please enter the module you want test") end
  if not testName then return eprint("Please enter the function you want test") end
  local tests = jo.file.load(("_unit-test.%s.%s"):format(args[1], context))

  if testName == "all" then
    for _, func in pairs(tests) do
      func()
    end
  else
    if not tests[testName] then return eprint("This test doesn't exist:", testName) end
    tests[testName]()
  end
end)
