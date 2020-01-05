local spawn_rnd = {}


local storage = minetest.get_mod_storage()
local intervall = 1      -- time in seconds between each search
local idx = 0
local abr = 16            -- check area around player, radius = abr
local dist_between = 50   -- distance between two spawnpoints in 2D
local max_sp = 200        -- max possible spawnpoints
local run = true


-- load spawnpoints
local function openlist()

    local iter = 1
	local pos = storage:get(iter)
    while pos do
        spawn_rnd[iter] = pos
        iter = iter +1
        pos = storage:get(iter)
    end
    if iter > max_sp then run = false end
	
end


-- save spawnpoints
local function savelist()
    --minetest.chat_send_all(dump(spawn_rnd))
    for i = 1,#spawn_rnd,1 do
        storage:set_string(i, spawn_rnd[i])
    end
end 


-- function to check min 2D distance between spawn points
local function check_distance(pos,radius)
    
    if #spawn_rnd < 1 then return true end
    for i = 1,#spawn_rnd ,1 do
        local spr = minetest.string_to_pos(spawn_rnd[i])
        local pos2 = {x=spr.x, y=pos.y, z=spr.z}
        if vector.distance(pos,pos2) < radius then return false end
    end
    return true
end


-- find a spawn point near random player
local function get_spoint(pos)
    local pos1 = {x=pos.x - abr, y=pos.y - abr, z=pos.z - abr}
    local pos2 = {x=pos.x + abr, y=pos.y + abr, z=pos.z + abr}
    local points = minetest.find_nodes_in_area_under_air(pos1, pos2, {"group:sand","group:stone","group:soil"})
    if #points < 1 then return end
    
        local i = math.random(#points)
        local a = {x=points[i].x, y=points[i].y+1, z=points[i].z}
        local b = {x=a.x, y=a.y+15, z=a.z}
        local aircheck = minetest.find_nodes_in_area(a,b,{"air"})
        
        if #aircheck > 13 then
            local possible = points[i]
            if check_distance(possible,dist_between) then
                possible.y = possible.y + 2
                spawn_rnd[#spawn_rnd+1] = minetest.pos_to_string(possible)
                storage:set_string(#spawn_rnd, spawn_rnd[#spawn_rnd])
                if #spawn_rnd > max_sp then run = false end
            end
            --minetest.chat_send_all(dump(#spawn_rnd))
        end
    
end



--- start

openlist()

minetest.register_globalstep(function(dtime)
    if not run then return end
    idx = idx + dtime
                            
    if idx > intervall then
        local plyrs = minetest.get_connected_players()
        if #plyrs  < 1 then return end
        local plyr = plyrs[math.random(#plyrs)]
        if not plyr then return end
        local pos = plyr:get_pos()
        if pos.y >0 and pos.y < 250 then
            get_spoint(pos)
        end
        
        idx = 0
        
    end
end)

-- after death chose random spawm point
minetest.register_on_respawnplayer(function(player)
    
    if not player then return end
    minetest.after(0.5, function(player) player:set_pos(minetest.string_to_pos(spawn_rnd[math.random(#spawn_rnd)])) end, player)
    return true
end)

-- new players get random spawnpoints
minetest.register_on_newplayer(function(player)
    
    if not player then return end
    minetest.after(1, function(player) player:set_pos(minetest.string_to_pos(spawn_rnd[math.random(#spawn_rnd)])) end, player)
    return false
end)

  
-- Add Chatcommand to see amount of spawnpoints
minetest.register_chatcommand("flee", {
	params = "",
	description = "flee",
	privs = {server = true},
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if not player then return false end
		local pos = player:set_pos(minetest.string_to_pos(spawn_rnd[math.random(#spawn_rnd)]))
        minetest.chat_send_player(name,"Total Spawnpoints = "..dump(#spawn_rnd))
		
		return true
	end
})
  
