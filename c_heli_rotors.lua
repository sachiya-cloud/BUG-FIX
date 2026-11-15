--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

local heli = nil

function updateRotor()
	if isElement(heli) then
		if not getVehicleEngineState( heli ) and getVehicleRotorSpeed( heli ) > 0 then
			local new = getVehicleRotorSpeed( heli ) - 0.0012
			setVehicleRotorSpeed( heli, math.max( 0, new ) )
		end
	else
		disableRotorUpdate()
	end
end

function disableRotorUpdate()
	if heli then
		heli = nil
		removeEventHandler( "onClientPlayerVehicleExit", getLocalPlayer(), disableRotorUpdate )
		removeEventHandler( "onClientPreRender", getRootElement(), updateRotor ) -- Pre
	end
end

function enableRotorUpdate( theVehicle )
	if getVehicleType( theVehicle ) == "Helicopter" then
		heli = theVehicle
		
		addEventHandler( "onClientPlayerVehicleExit", getLocalPlayer(), disableRotorUpdate )
		addEventHandler( "onClientPreRender", getRootElement(), updateRotor ) -- Pre
	end
end
addEventHandler( "onClientPlayerVehicleEnter", getLocalPlayer(), enableRotorUpdate )
