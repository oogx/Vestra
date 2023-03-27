getgenv().Client = {}
do
    local garbage = getgc(true)
    local loaded_modules = getloadedmodules()
    for i = 1, #garbage do
        local v = garbage[i]
        if typeof(v) == "table" then
            if rawget(v, "send") then -- Networking Module
                Client.network = v
            elseif rawget(v, 'goingLoud') and rawget(v, 'isInSight') then -- Useful for Radar Hack or Auto Spot
                Client.spotting_interface = v
            elseif rawget(v, 'bulletAcceleration') then
                Client.bulletAccel = v
            elseif rawget(v, 'setMinimapStyle') and rawget(v, 'setRelHeight') then -- Useful for Radar Hack
                Client.radar_interface = v
            elseif rawget(v, "getCharacterModel") and rawget(v, 'popCharacterModel') then -- Used for Displaying other Characters
                Client.third_person_object = v
            elseif rawget(v, "getCharacterObject") then -- Used for sending LocalPlayer Character Data to Server
                Client.character_interface = v
            elseif rawget(v, "isSprinting") and rawget(v, "getArmModels") then -- Used for sending LocalPlayer Character Data to Server
                Client.character_object = v
            elseif rawget(v, "updateReplication") and rawget(v, "getThirdPersonObject") then -- This represents a "Player" separate from their character
                Client.replication_object = v
            elseif rawget(v, "setHighMs") and rawget(v, "setLowMs") then -- Same as above
                Client.replication_interface = v
            elseif rawget(v, 'setSway') and rawget(v, "_applyLookDelta") then -- You can modify camera values with this
                Client.main_camera_object = v
            elseif rawget(v, 'getActiveCamera') and rawget(v, "getCameraType") then -- You can modify camera values with this
                Client.camera_interface = v
            elseif rawget(v, 'getFirerate') and rawget(v, "getFiremode") then -- Weapon Stat Hooks
                Client.firearm_object = v
            elseif rawget(v, 'canMelee') and rawget(v, "_processMeleeStateChange") then -- Melee Stat Hooks
                Client.melee_object = v
            elseif rawget(v, 'canCancelThrow') and rawget(v, "canThrow") then -- Grenade Stat Hooks
                Client.grenade_object = v
            elseif rawget(v, "vote") then -- Useful for Auto Vote
                Client.votekick_interface = v
            elseif rawget(v, "getActiveWeapon") then -- Useful for getting current weapon
                Client.weapon_controller_object = v
            elseif rawget(v, "getController") then -- Useful for getting your current weapon
                Client.weapon_controller_interface = v
            elseif rawget(v, "updateVersion") and rawget(v, "inMenu") then -- Useful for chat spam :)
                Client.chat_interface = v
            elseif rawget(v, "trajectory") and rawget(v, "timehit") then -- Useful for ragebot (Note: This table is frozen, use setreadonly)
                Client.physics = v
            elseif rawget(v, "slerp") and rawget(v, "toanglesyx") then -- Useful for angles (Note: This table is frozen, use setreadonly)
                Client.vector = v
            elseif rawget(v, "getWeaponAttData") then -- Useful for unlock all
                Client.WeaponData = v
            end
        end
    end

    for i = 1, #loaded_modules do
        local v = loaded_modules[i]
        if v.Name == "PlayerSettingsInterface" then -- I use this for dynamic fov
            Client.player_settings = require(v)
        elseif v.Name == "PublicSettings" then -- Get world data from here
            Client.PBS = require(v)
        elseif v.Name == "particle" then -- Useful for silent aim
            Client.particle = require(v)
        elseif v.Name == "CharacterInterface" then
            Client.LocalPlayer = require(v)
        elseif v.Name == "WeaponControllerInterface" then
            Client.WCI = require(v)
        elseif v.Name == "ActiveLoadoutUtils" then
            Client.active_loadout = require(v)
        elseif v.Name == "GameClock" then
            Client.game_clock = require(v)
        elseif v.Name == "PlayerDataStoreClient" then
            Client.player_data = require(v)
        elseif v.Name == "ReplicationInterface" then
            Client.replication = require(v)
        elseif v.Name == "BulletCheck" then -- Wall Penetration for ragebot
            Client.bullet_check = require(v)
        elseif v.Name == "WeaponObject" then
            Client.WeaponObject = require(v)
        elseif v.Name == "HudStatusInterface" then
            Client.HudStatusInterface = require(v)
        end
    end
end