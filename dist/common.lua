local common = {
    beautiful = require("beautiful")
}

function script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
 end
 
 print(script_path())
common.beautiful.init(script_path() .. "/themes/default/theme.lua")

return common