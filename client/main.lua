ESX = nil

local state = {
    ["0"] = "~g~Rentré~s~",
    ["1"] = "~r~Sorti~s~"
}

Citizen.CreateThread(function()
    DecorRegister("owner", 3)
    DecorRegister("vehicleID", 3)
    GaragePublic = {
        Base = { Header = {"shopui_title_carmod2", "shopui_title_carmod2"}, Color = {color_black}},
        Data = { currentMenu = "Vos véhicules" },
        Events = {
            onSelected = function(self, _, btn, PMenu, menuData, currentButton, currentBtn, currentSlt, result, slide)
                local result = GetOnscreenKeyboardResult()
                    if btn.name then
                        CloseMenu(true)
                        spawnCar(btn.model, btn.plate, btn.id, btn.properties)
                        ShowAboveRadarMessage("~g~Vous avez sorti "..btn.vehname..".")
                        TriggerServerEvent("garage:updatestate", 1, btn.id)
                    end
                end
        },

        Menu = {
            ["Vos véhicules"] = {useFilter = true, b = {}}
        }
    }

    while ESX == nil do
        Citizen.Wait(350)
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    end
    
    while true do
        local Time = 350
        local pos = GetEntityCoords(PlayerPedId())
        local distance = GetDistanceBetweenCoords(pos, Config.GaragePersoPos, true)
        local distance2 = GetDistanceBetweenCoords(pos, Config.GaragePersoPosEnter, true)

        if distance2 < 1.5 then
            DrawTopNotification("Appuyer ~INPUT_TALK~ pour ~r~rentrer votre véhicule")
            if IsControlJustPressed(1, 51) then
                if IsPedInAnyVehicle(PlayerPedId(), false) then
                    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
                    if not DecorExistOn(veh, "owner") or not DecorExistOn(veh, "vehicleID") then
                        ShowAboveRadarMessage("Le véhicule n'est pas à vous")
                    else
                        if DecorGetInt(veh, "owner") == GetPlayerServerId(PlayerId()) then
                            NetworkRequestControlOfEntity(veh)
                            while not NetworkHasControlOfEntity(veh) do Wait(1) end
                            TriggerServerEvent("garage:updatestate", 0, DecorGetInt(veh, "vehicleID"))
                            TriggerServerEvent("garage:updateprops", DecorGetInt(veh, "vehicleID"), json.encode(ESX.Game.GetVehicleProperties(veh)))
                            DeleteEntity(veh)
                        end
                    end
                else
                    ShowAboveRadarMessage("Vous n'êtes pas dans un véhicule")
                end
            end
        end
        if distance < 20 then
            Time = 1
            DrawMarker(6, Config.GaragePersoPos, 0.0, 0.0, 180.0, 0.0, 0.0, 0.0, 1.2, 1.2, 1.2, 93, 173, 226, 120, false, false, false, false)
        end
        
        if distance2 < 20 then
            DrawMarker(6, Config.GaragePersoPosEnter, 0.0, 0.0, 180.0, 0.0, 0.0, 0.0, 1.2, 1.2, 1.2, 255, 0, 0, 120, false, false, false, false)
        end


        if distance < 1.5 and not IsPedInAnyVehicle(PlayerPedId(), false) then
            DrawTopNotification("Appuyer ~INPUT_TALK~ pour ~g~ouvrir le garage.")
            if IsControlJustPressed(1, 51) then
                GaragePublic.Menu["Vos véhicules"].b = {}
                ESX.TriggerServerCallback("garage:getvehs", function(veh)
                    for i=1, #veh, 1 do
                        if veh[i].stored == "0" then
                            table.insert(GaragePublic.Menu["Vos véhicules"].b, {name = '> '..veh[i].name.." ["..state[veh[i].stored].."]", askX = true, model = veh[i].vehicle, plate = veh[i].plate, vehname = veh[i].name, id = veh[i].id, properties = veh[i].properties})
                        else 
                            table.insert(GaragePublic.Menu["Vos véhicules"].b, {name = '> '..veh[i].name.." ["..state[veh[i].stored].."]", askX = true, role = true, sorti = true})
                        end
                    end
                    Wait(100)
                    CreateMenu(GaragePublic)
                end)
            end
        end
		Citizen.Wait(Time)
	end
end)

function spawnCar(car, plate, code, properties)
    local car = GetHashKey(car)
    RequestModel(car)
    while not HasModelLoaded(car) do
        RequestModel(car)
        Citizen.Wait(50)
    end

    local vehicle = CreateVehicle(car, Config.GaragePersoPosOut, Config.GaragePersoHeading, true, false)
   
    SetPedIntoVehicle(PlayerPedId(), vehicle, -1)
    SetVehicleNumberPlateText(vehicle, plate)

    SetEntityAsNoLongerNeeded(vehicle)
    SetModelAsNoLongerNeeded(vehicle)
    DecorSetInt(vehicle, "vehicleID", code)
    DecorSetInt(vehicle, "owner", GetPlayerServerId(PlayerId()))
    ESX.Game.SetVehicleProperties(vehicle, json.decode(properties))
end
