local props = {}
props = file.Find("map_props/*.lua", "LUA")

for _, plugin in ipairs(props) do
	include("map_props/" .. plugin)
end
