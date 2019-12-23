

RADIUS = 512
SPAWN = {x=0, y=0, z=0}


local function findspawn()
   -- high = math.random(1,14)
	for try=100000, 0, -1 do
        high = math.random(1,14)
		local pos = {x = SPAWN.x, y = high, z = SPAWN.z}
		pos.x = SPAWN.x + math.random(-RADIUS, RADIUS)
		pos.z = SPAWN.z + math.random(-RADIUS, RADIUS)
        local free = pos
		if core.forceload_block(free,true) then
			-- Find ground level (0...15)
			local ground_y = nil
			for y=high*16, (high-1)*16, -1 do
				local nn = minetest.get_node({x=pos.x, y=y, z=pos.z})
				if nn and nn.name ~= "air" and nn.name ~= "ignore" then
					ground_y = y
					break
				end
			end
			if ground_y then
				pos.y = ground_y
				if minetest.registered_nodes[minetest.get_node(pos).name].walkable == true and
					minetest.get_node({x=pos.x, y=pos.y+1, z=pos.z}).name == "air" and
					minetest.get_node({x=pos.x, y=pos.y+2, z=pos.z}).name == "air" then
					local pos_spawn = {x=pos.x, y=pos.y+1, z=pos.z}
                    return pos_spawn
				end
			end
			core.forceload_free_block(free,true)
		end
	end
end



local function spawnarea(player)
	local pos = findspawn()
	if pos then
		player:setpos(pos)
	else
		player:setpos(SPAWN)
	end
end

minetest.register_on_newplayer(function(player)
	spawnarea(player)
end)

minetest.register_on_respawnplayer(function(player)
	spawnarea(player)
	return true
end)




minetest.register_chatcommand("spawntable", {
	params = "",
	description = "calc spawnpoints",
	privs = {server = true},
	func = function(name, param)
		minetest.chat_send_player(name, dump(findspawn()))
		return true
	end
})
