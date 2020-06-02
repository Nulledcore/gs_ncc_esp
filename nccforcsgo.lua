--[[ CREDITS
    Nulledcore - Duh
    V952 - Dev of Nullcore which I based this lua on
    nmchris - Used his get_weapon function + weapons table to get the proper weapon names
    GigsD4X - Used his HSVtoRGB function
    TTVM Discord - Feedback
    
 ]]

--[[ REQUIREMENTS ]]
local surface = require('gamesense/surface')
local nc_font = surface.create_font("Verdana", 16, 600, 0x200)
local nc_panel_header = surface.create_font("Verdana", 13, 600, 0x200)
local nc_panel_info = surface.create_font("Verdana", 12, 400, 0x200)

--[[ TABLES ]]
local menu = {"lua", "b"}
local weapons = {
    [1] = "Desert Eagle",
    [2] = "Dual Berettas",
    [3] = "Five-SeveN",
    [4] = "Glock-18",
    [7] = "AK-47",
    [8] = "AUG",
    [9] = "AWP",
    [10] = "FAMAS",
    [11] = "G3SG1",
    [13] = "Galil AR",
    [14] = "M249",
    [16] = "M4A4",
    [17] = "MAC-10",
    [19] = "P90",
    [23] = "MP5-SD",
    [24] = "UMP-45",
    [25] = "XM1014",
    [26] = "PP-Bizon",
    [27] = "MAG-7",
    [28] = "Negev",
    [29] = "Sawed-Off",
    [30] = "Tec-9",
    [31] = "Taser",
    [32] = "P2000",
    [33] = "MP7",
    [34] = "MP9",
    [35] = "Nova",
    [36] = "P250",
    [38] = "SCAR-20",
    [39] = "SG 553",
    [40] = "SSG 08",
    [41] = "Knife",
    [42] = "Knife",
    [43] = "Flashbang",
    [44] = "HE Grenade",
    [45] = "Smoke",
    [46] = "Molotov",
    [47] = "Decoy",
    [48] = "Incendiary",
    [49] = "C4",
    [59] = "Knife",
    [60] = "M4A1-S",
    [61] = "USP-S",
    [63] = "CZ75-Auto",
    [64] = "R8 Revolver",
    [500] = "Bayonet",
    [505] = "Flip Knife",
    [506] = "Gut Knife",
    [507] = "Karambit",
    [508] = "M9 Bayonet",
    [509] = "Huntsman Knife",
    [512] = "Falchion Knife",
    [514] = "Bowie Knife",
    [515] = "Butterfly Knife",
    [516] = "Shadow Daggers",
    [519] = "Ursus Knife",
    [520] = "Navaja Knife",
    [522] = "Siletto Knife",
    [523] = "Talon Knife",
}

--[[ How to add your own steam64 to the NCU/NCD list
You get the steam64 from either entity.get_steam64(player) or [U:1:?????????]

local ncds/ncus = {
    "STEAM64",
    "STEAM64"
}

]]

local ncds = {
    "288728546" -- Nulledcore
}

local ncus = {
    "157388780" -- Womble
}

--[[ UI ELEMENTS ]]
local nc_enable = ui.new_checkbox(menu[1], menu[2], "Enable NCESP")
local nc_health = ui.new_combobox(menu[1], menu[2], "Health bar", {"Off", "Flat", "Gradient"})
local nc_name = ui.new_checkbox(menu[1], menu[2], "Name label")
local nc_weapon = ui.new_checkbox(menu[1], menu[2], "Weapon label")
local nc_weapon_clr = ui.new_color_picker(menu[1], menu[2], "weaponclr", 200, 255, 190, 255)
local nc_ncu = ui.new_checkbox(menu[1], menu[2], "NCU label (W.I.P)")
local nc_ncu_clr = ui.new_color_picker(menu[1], menu[2], "ncuclr", 67, 108, 142, 255)
local nc_info = ui.new_checkbox(menu[1], menu[2], "Info panel")
local nc_team = ui.new_multiselect(menu[1], menu[2], "Team based colors", {"Glow", "Chams", "Chams XQZ", "Shadow"})

ui.new_label(menu[1], menu[2], "Team: None color")
local nc_team_none = ui.new_color_picker(menu[1], menu[2], "none_clr", 238, 182, 41, 255)
ui.new_label(menu[1], menu[2], "Team: Spec color")
local nc_team_spec = ui.new_color_picker(menu[1], menu[2], "spec_clr", 204, 204, 204, 255)
ui.new_label(menu[1], menu[2], "Team: T color")
local nc_team_t = ui.new_color_picker(menu[1], menu[2], "t_clr", 255, 61, 61, 255)
ui.new_label(menu[1], menu[2], "Team: CT color")
local nc_team_ct = ui.new_color_picker(menu[1], menu[2], "ct_clr", 154, 205, 255, 255)


--[[ FUNCTIONS ]]
local nc_type = ""
local function nc_user() -- function to check the ncu/ncd tables
    if not entity.get_local_player() or entity.get_local_player() == nil then return end
    local id = entity.get_steam64(entity.get_local_player())
    if id == nil then return end
    for k, v in pairs(ncus) do
        if(entity.get_local_player() ~= nil) then
            if v == entity.get_steam64(entity.get_local_player()) then
                nc_type = "NCU"
                return true
            end
        end
    end
    for k, v in pairs(ncds) do
        if(entity.get_local_player() ~= nil) then
            if v == entity.get_steam64(entity.get_local_player()) then
                nc_type = "NCD"
                return true
            end
        end
    end
    return false;
end


local function contains(table, val)
    for i=1,#table do
        if table[i] == val then 
            return true
        end
    end
    return false
end

local function get_weapon(enemy) -- s/o to nmchris
    local weapon_id = entity.get_prop(enemy, "m_hActiveWeapon")
    if entity.get_prop(weapon_id, "m_iItemDefinitionIndex") ~= nil then
       local weapon_item_index = bit.band(entity.get_prop(weapon_id, "m_iItemDefinitionIndex"), 0xFFFF)
        return weapons[weapon_item_index]
    end
    return 0
end

local function HSVToRGB(h, s, v)
    local r, g, b
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    i = i % 6
    if i == 0 then r, g, b = v, t, p
        elseif i == 1 then r, g, b = q, v, p
        elseif i == 2 then r, g, b = p, v, t
        elseif i == 3 then r, g, b = p, q, v
        elseif i == 4 then r, g, b = t, p, v
        elseif i == 5 then r, g, b = v, p, q
    end
  
    return r * 255, g * 255, b * 255
end

local function lerp(h1, s1, v1, h2, s2, v2, t)
    local h = (h2 - h1) * t + h1
    local s = (s2 - s1) * t + s1
    local v = (v2 - v1) * t + v1
    return h, s, v
end

local indicators = {}
local function on_indicator(i)
    table.insert(indicators, i)
end
client.set_event_callback("indicator", on_indicator)

--[[ DRAW ]]
local r,g,b
local name_add = 0
local ncu_add = 0
local cur_i

local _, chams_color = ui.reference("Visuals", "Colored models", "Player")
local _, chams_xqz_color = ui.reference("Visuals", "Colored models", "Player behind wall")
local _, shadow_color = ui.reference("Visuals", "Colored models", "Shadow")
local _, glow_color = ui.reference("Visuals", "Player esp", "Glow")

local function draw_nce()
    local x,y = client.screen_size()
    if ui.get(nc_info) then
        local vx, vy, vz = entity.get_prop(entity.get_local_player(), "m_vecVelocity")
        local velocity = math.sqrt(vx * vx + vy * vy)
        if velocity < 2 then velocity = 0 end -- I know this makes it inaccurate, but I care more about aesthetics than anything.
        local rect_add = 32/2
        for i = 1, #indicators do 
            cur_i = indicators[i]
            if cur_i.text == "DT" then cur_i.text = "Double Tap"
            elseif cur_i.text == "LC" then cur_i.text = "Lag Compensation"
            elseif cur_i.text == "DUCK" then cur_i.text = "Fake Duck"
            end
            surface.draw_filled_outlined_rect(x/y, (y/2+2)+rect_add*5+(i * 16), 220, rect_add, 53, 66, 69, 200, 15, 150, 150, 255)
            surface.draw_text(x/y+2, (y/2+3)+rect_add*5+(i * 16), cur_i.r, cur_i.g, cur_i.b, cur_i.a, nc_panel_info, string.format("%s", cur_i.text))
        end

        surface.draw_filled_outlined_rect(x/y, (y/2+2), 220, rect_add, 53, 66, 69, 200, 15, 150, 150, 255)
        surface.draw_text(x/y+(220/2-30), (y/2+2), 255, 255, 255, 255, nc_panel_header, "Info Panel")

        surface.draw_filled_outlined_rect(x/y, (y/2+2)+rect_add, 220, rect_add, 53, 66, 69, 200, 15, 150, 150, 255)
        surface.draw_text(x/y+2, (y/2+3)+rect_add, 255, 255, 255, 255, nc_panel_info, string.format("Speed: %s", math.floor(velocity)))

        surface.draw_filled_outlined_rect(x/y, (y/2+2)+rect_add*2, 220, rect_add, 53, 66, 69, 200, 15, 150, 150, 255)
        local aimbot = ui.get(ui.reference("rage", "aimbot", "enabled"))
        if aimbot then aimbot = "Active" else aimbot = "Inactive" end
        surface.draw_text(x/y+2, (y/2+3)+rect_add*2, 255, 255, 255, 255, nc_panel_info, string.format("Aim Bot: %s", aimbot))
        
        surface.draw_filled_outlined_rect(x/y, (y/2+2)+rect_add*3, 220, rect_add, 53, 66, 69, 200, 15, 150, 150, 255)
        local triggerbot = ui.get(ui.reference("legit", "triggerbot", "enabled"))
        if triggerbot then triggerbot = "Active" else triggerbot = "Inactive" end
        surface.draw_text(x/y+2, (y/2+3)+rect_add*3, 255, 255, 255, 255, nc_panel_info, string.format("Trigger Bot: %s", triggerbot))

        surface.draw_filled_outlined_rect(x/y, (y/2+2)+rect_add*4, 220, rect_add, 53, 66, 69, 200, 15, 150, 150, 255)
        local fakelag = ui.get(ui.reference("aa", "fake lag", "limit"))
        if not ui.get(ui.reference("aa", "fake lag", "enabled")) then
            fakelag = "Disabled"
        end
        surface.draw_text(x/y+2, (y/2+3)+rect_add*4, 255, 255, 255, 255, nc_panel_info, string.format("Fake Lag: %s", fakelag))

        -- antiaim stuff (ik it's messy, but I like my aesthetics)
        surface.draw_filled_outlined_rect(x/y, (y/2+2)+rect_add*5, 220, rect_add, 53, 66, 69, 200, 15, 150, 150, 255)
        local antiaim = ui.get(ui.reference("aa", "anti-aimbot angles", "enabled"))
        local pitch = ui.get(ui.reference("aa", "anti-aimbot angles", "pitch"))
        local bodyyaw = ui.get(ui.reference("aa", "anti-aimbot angles", "body yaw"))

        if pitch == "Off" then pitch = "Disabled" end
        if bodyyaw == "Off" then bodyyaw = "Disabled" end

        if antiaim then antiaim = pitch.."/"..bodyyaw else antiaim = "Disabled" end
        surface.draw_text(x/y+2, (y/2+3)+rect_add*5, 255, 255, 255, 255, nc_panel_info, string.format("Aim Aim: %s", antiaim))


        indicators = {}
    end

    if not ui.get(nc_enable) then return end
    local enemies = entity.get_players(not enemies_only)
    for i=1, #enemies do
        local enemy = enemies[i]
        local bbox = {entity.get_bounding_box(enemy)}
        if bbox[1] == nil and bbox[2] == nil then return end
        local height = bbox[4]-bbox[2]

        --[[ HEALTH ]]
        local health = entity.get_prop(enemy, "m_iHealth")
        local h, s, v = lerp(0, 1, 1, 120, 1, 1, health*0.01)
        local hr, hg, hb = HSVToRGB(h/360, s, v)

        if ui.get(nc_health) == "Flat" then
            renderer.rectangle(bbox[1]-6, bbox[2]-1, 4, height+4.5, 17, 17, 17, 255)
            renderer.rectangle(bbox[1]-5, bbox[4]+2, 2, (-height*health/100)-2, hr, hg, hb, 255)
        elseif ui.get(nc_health) == "Gradient" then
            renderer.rectangle(bbox[1]-6, bbox[2]-1, 4, height+4.5, 17, 17, 17, 255)
            renderer.gradient(bbox[1]-5, bbox[4]+2, 2, (-height*health/100)-2, 255, 100, 0, 255, hr, hg, hb, 255, false)
        else
        end
        --[[ END_HEALTH ]]

        --[[ TEAM_COLOR ]]
        local get_team = entity.get_prop(enemy, "m_iTeamNum")
        if get_team == 0 then
            r,g,b,a = ui.get(nc_team_none)
        elseif get_team == 1 then
            r,g,b,a = ui.get(nc_team_spec)
        elseif get_team == 2 then
            r,g,b,a = ui.get(nc_team_t)
        elseif get_team == 3 then
            r,g,b,a = ui.get(nc_team_ct)
        end

        if contains(ui.get(nc_team), "Glow") then
            ui.set(glow_color, r,g,b,155)
        end
        if contains(ui.get(nc_team), "Chams") then
            ui.set(chams_color, r,g,b,a)
        end
        if contains(ui.get(nc_team), "Chams XQZ") then
            ui.set(chams_xqz_color, r,g,b,a)
        end
        if contains(ui.get(nc_team), "Shadow") then
            ui.set(shadow_color, r,g,b,175)
        end
        --[[ END_TEAM_COLOR ]]

        --[[ STRINGS ]]
        if ui.get(nc_name) then
            surface.draw_text(bbox[1]+3, bbox[2]-name_add, r, g, b, a, nc_font, entity.get_player_name(enemy))
        end
        if ui.get(nc_weapon) then
            local grab_weapon_string = get_weapon(enemy)
            name_add = 35
            ncu_add = 35
            local wr, wg, wb, wa = ui.get(nc_weapon_clr)
            surface.draw_text(bbox[1]+3, bbox[2]-20, wr, wg, wb, wa, nc_font, grab_weapon_string)
        else
            ncu_add = 23
            name_add = 20
        end

        if ui.get(nc_ncu) then
            if nc_user() then -- as of now, the ncu is based on steam64 as I don't have a host to send data to.
                local cr, cg, cb, ca = ui.get(nc_ncu_clr)
                surface.draw_text(bbox[1]+3, bbox[2]-ncu_add-ncu_add/3-2, cr, cg, cb, ca, nc_font, string.format("%s: %s", nc_type, entity.get_player_name(enemy)))
            end
        end
        --[[ END_STRINGS ]]
    end
end

--[[ CALLBACKS ]]
client.set_event_callback("paint", draw_nce)