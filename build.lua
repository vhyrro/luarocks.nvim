package.path = "./lua/?.lua;" .. package.path

local build = require("luarocks.build")

if not build.is_prepared() then
    build.build()
end
