--[[ CREDITS
    Nulledcore - Duh
    V952 - Dev of Nullcore which I based this lua on
    nmchris - Used his get_weapon function + weapons table to get the proper weapon names
    GigsD4X - Used his HSVtoRGB function
    Aviarita - Surface library
    TTVM Discord - Feedback
    
]]

local surface = require('gamesense/surface')
local nc_font = surface.create_font("Verdana", 16, 600, 0x200)
local nc_font_old = surface.create_font("Verdana", 16, 400, 0x200)
local nc_panel_header = surface.create_font("Verdana", 13, 600, 0x200)
local nc_panel_info = surface.create_font("Verdana", 12, 400, 0x200)

local menu = {"lua", "a"}
local _, chams_color = ui.reference("Visuals", "Colored models", "Player")
local _, chams_xqz_color = ui.reference("Visuals", "Colored models", "Player behind wall")
local _, glow_color = ui.reference("Visuals", "Player esp", "Glow")

local nc_info = ui.new_checkbox(menu[1], menu[2], "Info panel")
local nc_health = ui.new_combobox(menu[1], menu[2], "Health bar", {"Off", "Flat", "Gradient"})
local nc_box = ui.new_combobox(menu[1], menu[2], "Box", {"Off", "2D", "2D Rainbow"})

local nc_font_select = ui.new_combobox(menu[1], menu[2], "Font type", {"New", "Old"})
local nc_weapon = ui.new_checkbox(menu[1], menu[2], "Weapon label")
local nc_conditions = ui.new_checkbox(menu[1], menu[2], "Conditions label")
local nc_team_colors = ui.new_checkbox(menu[1], menu[2], "Team based colors [!]")

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

local indicators = {}
local function on_indicator(i)
    table.insert(indicators, i)
end
client.set_event_callback("indicator", on_indicator)

local function lp()
    local real_lp = entity.get_local_player()
    if entity.is_alive(real_lp) then
        return real_lp
    else
        local obvserver = entity.get_prop(real_lp, "m_hObserverTarget")
        return obvserver ~= nil and obvserver <= 64 and obvserver or nil
    end
end

local function collect_players()
    local results = {}
    local lp_origin = {entity.get_origin(lp())}

    for i=1, 64 do
        if entity.is_alive(i) then
            local player_origin = {entity.get_origin(i)}
            if player_origin[1] ~= nil and lp_origin[1] ~= nil then
                table.insert(results, {i})
            end
        end
    end
    return results
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

local function func_rgb_rainbowize(frequency, rgb_split_ratio)
    local r, g, b, a = HSVToRGB(globals.realtime() * frequency, 1, 1)

    r = r * rgb_split_ratio
    g = g * rgb_split_ratio
    b = b * rgb_split_ratio

    return r, g, b
end

local function lerp(h1, s1, v1, h2, s2, v2, t)
    local h = (h2 - h1) * t + h1
    local s = (s2 - s1) * t + s1
    local v = (v2 - v1) * t + v1
    return h, s, v
end


local function draw_infobar()
    local x,y = client.screen_size()
    if ui.get(nc_info) then
        if not entity.is_alive(entity.get_local_player()) then return end
        local vx, vy, vz = entity.get_prop(entity.get_local_player(), "m_vecVelocity")
        local velocity = math.sqrt(vx * vx + vy * vy)
        if velocity < 2 then velocity = 0 end
        for i = 1, #indicators do 
            cur_i = indicators[i]
            
            if cur_i.text == "DT" then cur_i.text = "Double Tap"
            elseif cur_i.text == "LC" then cur_i.text = "Lag Compensation"
            elseif cur_i.text == "DUCK" then cur_i.text = "Fake Duck"
            end
            surface.draw_filled_outlined_rect(x/y, (y/2+2)+32/2*6+(i * 16), 220, 32/2, 53, 66, 69, 100, 15, 150, 150, 255)
            surface.draw_text(x/y+2, (y/2+3)+32/2*6+(i * 16), cur_i.r, cur_i.g, cur_i.b, cur_i.a, nc_panel_info, string.format("%s", cur_i.text))
        end

        surface.draw_filled_outlined_rect(x/y, (y/2+2), 220, 32/2, 53, 66, 69, 100, 15, 150, 150, 255)
        surface.draw_text(x/y+(220/2-30), (y/2+2)+1, 255, 255, 255, 255, nc_panel_header, "Info Panel")

        surface.draw_filled_outlined_rect(x/y, (y/2+2)+32/2, 220, 32/2, 53, 66, 69, 100, 15, 150, 150, 255)
        surface.draw_text(x/y+2, (y/2+3)+32/2, 255, 255, 255, 255, nc_panel_info, string.format("Speed: %s", math.floor(velocity)))

        surface.draw_filled_outlined_rect(x/y, (y/2+2)+32/2*2, 220, 32/2, 53, 66, 69, 100, 15, 150, 150, 255)

        surface.draw_text(x/y+2, (y/2+3)+32/2*2, 255, 255, 255, 255, nc_panel_info, string.format("Aim Bot: %s", ui.get(ui.reference("rage", "aimbot", "enabled")) and "Active" or "Inactive" or ui.get(ui.reference("legit", "aimbot", "enabled")) and "Active" or "Inactive"))
        
        surface.draw_filled_outlined_rect(x/y, (y/2+2)+32/2*3, 220, 32/2, 53, 66, 69, 100, 15, 150, 150, 255)

        surface.draw_text(x/y+2, (y/2+3)+32/2*3, 255, 255, 255, 255, nc_panel_info, string.format("Trigger Bot: %s", ui.get(ui.reference("legit", "triggerbot", "enabled")) and "Active" or "Inactive"))

        surface.draw_filled_outlined_rect(x/y, (y/2+2)+32/2*4, 220, 32/2, 53, 66, 69, 100, 15, 150, 150, 255)

        surface.draw_text(x/y+2, (y/2+3)+32/2*4, 255, 255, 255, 255, nc_panel_info, string.format("Fake Lag: %s", ui.get(ui.reference("aa", "fake lag", "enabled")) and "Active" or "Disabled"))

        surface.draw_filled_outlined_rect(x/y, (y/2+2)+32/2*5, 220, 32/2, 53, 66, 69, 100, 15, 150, 150, 255)
        local antiaim = ui.get(ui.reference("aa", "anti-aimbot angles", "enabled"))
        local pitch = ui.get(ui.reference("aa", "anti-aimbot angles", "pitch"))
        local bodyyaw = ui.get(ui.reference("aa", "anti-aimbot angles", "body yaw"))

        if pitch == "Off" then pitch = "Disabled" end
        if bodyyaw == "Off" then bodyyaw = "Disabled" end

        if antiaim then antiaim = pitch.."/"..bodyyaw else antiaim = "Disabled" end
        surface.draw_text(x/y+2, (y/2+3)+32/2*5, 255, 255, 255, 255, nc_panel_info, string.format("Anti Aim: %s", antiaim))

        surface.draw_filled_outlined_rect(x/y, (y/2+2)+32/2*6, 220, 32/2, 53, 66, 69, 100, 15, 150, 150, 255)

        surface.draw_text(x/y+2, (y/2+3)+32/2*6, 255, 255, 255, 255, nc_panel_info, string.format("Fake Peek: %s", ui.get(ui.reference("aa", "other", "fake peek")) and "Active" or "Inactive"))

        indicators = {}
    end
end


local function getteam(index)
    local get_team = entity.get_prop(index, "m_iTeamNum")
    if get_team == 0 then
        return {238, 182, 41, 255}
    elseif get_team == 1 then
        return {204, 204, 204, 255}
    elseif get_team == 2 then
        return {255, 223, 147, 255}
    elseif get_team == 3 then
        return {163, 198, 255, 255}
    end
end

local function draw_esp()
    local x,y = client.screen_size()
    local enemies = collect_players()
    for i=1, #enemies do
        local enemy = enemies[i]
        local index = unpack(enemy)
        if entity.is_enemy(index) then

            if ui.get(nc_team_colors) then
                local team_color = getteam(index)
                ui.set(chams_color, team_color[1], team_color[2], team_color[3], team_color[4])
                ui.set(chams_xqz_color, team_color[1], team_color[2], team_color[3], team_color[4])
                ui.set(glow_color, team_color[1], team_color[2], team_color[3], 125)
            end

            local bbox = {entity.get_bounding_box(index)}
            if bbox[1] ~= nil or bbox[2] ~= nil or bbox[3] ~= nil or bbox[4] ~= nil or bbox[5] ~= 0 then
                local height, width = bbox[4]-bbox[2], bbox[3]-bbox[1]

                local health = entity.get_prop(index, "m_iHealth")
                local h, s, v = lerp(0, 1, 1, 120, 1, 1, health*0.01)
                local hr, hg, hb = HSVToRGB(h/360, s, v)
        
                if ui.get(nc_health) == "Flat" then
                    local color = entity.is_dormant(index) and {100, 100, 100, 255} or {hr, hg, hb, 255}
                    renderer.rectangle(bbox[1]-6, bbox[2]-1, 4, height+4, 17, 17, 17, 255)
                    renderer.rectangle(bbox[1]-5, bbox[4]+2, 2, (-height*health/100)-2, color[1],color[2],color[3], 255)
                elseif ui.get(nc_health) == "Gradient" then
                    local bcolor = entity.is_dormant(index) and {100, 100, 100, 255} or {hr, hg, hb, 255}
                    local acolor = entity.is_dormant(index) and {100, 100, 100, 255} or {255, 45, 0, 255}
                    renderer.rectangle(bbox[1]-6, bbox[2]-1, 4, height+4, 17, 17, 17, 255)
                    renderer.gradient(bbox[1]-5, bbox[4]+2, 2, (-height*health/100)-2, acolor[1],acolor[2],acolor[3], 255, bcolor[1],bcolor[2],bcolor[3], 255, false)
                else
                end

                local color = entity.is_dormant(index) and {100, 100, 100, 255} or getteam(index)

                if ui.get(nc_box) == "2D" then
                    surface.draw_outlined_rect(bbox[1], bbox[2], width, height+2, color[1],color[2],color[3],color[4])
                elseif ui.get(nc_box) == "2D Rainbow" then
                    local color = entity.is_dormant(index) and {100, 100, 100, 255} or {func_rgb_rainbowize(0.15, 1)}
        
                    renderer.gradient(bbox[1], bbox[2], 1, height+2, color[1],color[2],color[3], 255, color[2],color[3],color[1], 255, false)
                    renderer.gradient(bbox[3], bbox[2], 1, height+2, color[1],color[2],color[3], 255, color[2],color[3],color[1], 255, false)
        
                    renderer.gradient(bbox[1], bbox[2], width, 1, color[1],color[2],color[3], 255, color[2],color[3],color[1], 255, false)
                    renderer.gradient(bbox[1], bbox[4]+2, width+1, 1, color[1],color[2],color[3], 255, color[2],color[3],color[1], 255, false)
                end

                local name = entity.get_player_name(index)
                if name == nil then return end
                if name:len() > 15 then 
                    name = name:sub(0, 15)
                end
                surface.draw_text(bbox[1], bbox[2]-(ui.get(nc_weapon) and 35 or 20), color[1], color[2], color[3], 255, ui.get(nc_font_select) == "Old" and nc_font_old or nc_font, name)

                if ui.get(nc_weapon) then
                    local color = entity.is_dormant(index) and {100, 100, 100, 255} or {200, 255, 190, 255}
                    local weapon_id = entity.get_prop(index, "m_hActiveWeapon")
                    if entity.get_prop(weapon_id, "m_iItemDefinitionIndex") ~= nil then
                        weapon_item_index = bit.band(entity.get_prop(weapon_id, "m_iItemDefinitionIndex"), 0xFFFF)
                    end

                    local weapon_name = weapons[weapon_item_index]
                    if weapon_name == nil then return end

                    if weapon_name:len() > 15 then 
                        weapon_name = weapon_name:sub(0, 15)
                    end
                    surface.draw_text(bbox[1], bbox[2]-20, color[1], color[2], color[3], color[4], ui.get(nc_font_select) == "Old" and nc_font_old or nc_font, weapon_name)
                end
                if ui.get(nc_conditions) then
                    local color = entity.is_dormant(index) and {100, 100, 100, 255} or {3, 252, 223, 255}
                    if entity.get_prop(index, "m_bIsScoped") ~= 0 then
                        surface.draw_text(bbox[1], bbox[2]-(ui.get(nc_weapon) and 50 or 35), color[1], color[2], color[3], color[4], ui.get(nc_font_select) == "Old" and nc_font_old or nc_font, "*ZOOMING*")
                    end
                end
            end
        end
    end
end


local function main()
    draw_infobar()
    draw_esp()
end

client.set_event_callback("paint", main)
