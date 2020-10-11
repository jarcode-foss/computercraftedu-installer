
local function main()
  print(__LUA_PATH)
  print(package.path)
end

function split(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
         table.insert(t, cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

function remove_empty(list)
  local collected = {}
  for i = 1, #list do
    local v = list[i]
    if v ~= "" then
      collected[#collected + 1] = v
    end
  end
end

local __builtin_require = require
require = function(mod)
  if package.loaded[mod] == nil then
    local modp = table.concat(split(mod, "%."), "/")
    local resolved
    if __BUILTIN_INDEX[modp .. ".lua"] ~= nil then
      resolved = __BUILTIN_INDEX[modp]
      return
    elseif __BUILTIN_INDEX[modp .. "/init.lua"] ~= nil then
      resolved = __BUILTIN_INDEX[modp .. "/init.lua"]
    else
      return __builtin_require(mod)
    end
    local s = split(resolved, "/")
    s[#s] = split(s[#s], ".")[1]
    local ret = __builtin_require(table.concat(s, "."))
    package.loaded[mod] = ret
    return ret
  end
  return __builtin_require(mod)
end
if not string.find(package.path, __LUA_PATH, 1, true) then
  -- TODO: test cwd on windows
  package.path = __LUA_PATH .. "/?.lua;" .. __LUA_PATH .. "/?/init.lua;" .. package.path
end

local status, err = pcall(main)
if not status then
  print("Unexpected error:\n" .. err)
  print(debug.traceback())
end
