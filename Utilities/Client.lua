getgenv().client = {}
do
    local gc = getgc(true)
    for i = #gc, 1, -1 do
        local v = gc[i]
        local type = type(v)
        if type == 'function' then
            local info = debug.getinfo(v);
            if (info.name == "call" and string.find(info.short_src, "network")) then
                client.network = debug.getupvalue(v, 1);
            end      
            if info.name == "bulletcheck" then
		client.bulletcheck = v
            elseif info.name == "trajectory" then
		client.trajectory = v
	    elseif info.name == "fromaxisangle" then
		client.fromaxisangle = v
	    elseif info.name == "gunbob" then
		client.gunbob = v	
	    elseif info.name == "gunsway" then
		client.gunsway = v			
            elseif info.name == "loadgun" then
                client.loadgun = v	
            elseif info.name == "camera" then
                client.camera = v
            elseif info.name == "play" then
                client.sounds = v	
            elseif info.name == "loadplayer" then   
                client.loadplayer = v
	    end      
        end
        if type == "table" then
            if (rawget(v, "gammo")) then
                client.gamelogic = v
            elseif (rawget(v, "updateammo")) then
                client.hud = v
            elseif (rawget(v, "getbodyparts")) then
                client.replication = v
                client.replication.bodyparts = debug.getupvalue(client.replication.getbodyparts, 1)
                client.bodyparts = debug.getupvalue(v.getbodyparts, 1)
	    elseif rawget(v,"isplayeralive") then
		client.hud = v
            elseif rawget(v, "basecframe") then
                client.camera = v
            elseif rawget(v, "setbasewalkspeed") then
                client.character = v
            elseif rawget(v, "send") then
                client.network = v
            end
        end
    end
end
