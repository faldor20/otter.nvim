local M = {}

M.contains = function(list, x)
  for _, v in pairs(list) do
    if v == x then return true end
  end
  return false
end


M.lines = function(str)
  local result = {}
  for line in str:gmatch '([^\n]*)\n?' do
    table.insert(result, line)
  end
  result[#result] = nil
  return result
end

M.spaces = function(n)
  local s = {}
  for i = 1, n do
    s[i] = ' '
  end
  return s
end

M.if_nil = function(val, default)
  if val == nil then return default end
  return val
end


M.path_to_otterpath = function(path, lang)
  return path .. '-tmp' .. lang
end

--- @param path string a path
--- @return string
M.otterpath_to_path = function(path)
  local s,_ = path:gsub('-tmp%..+', '')
  return s
end

--- @param path string
M.is_otterpath = function(path)
  return path:find('.+-tmp%..+') ~= nil
end

return M