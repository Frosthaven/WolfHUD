-- CONFIG **********************************************************************
local config = {}

config.icons = {}

config.icons.civilian_alerted = "guis/textures/WolfhudEE/civilian_alerted"
config.icons.civilian_curious = "guis/textures/WolfhudEE/civilian_curious"
config.icons.civilian_subdued = "guis/textures/WolfhudEE/civilian_subdued"

config.icons.guard_alerted = "guis/textures/WolfhudEE/guard_alerted"
config.icons.guard_curious = "guis/textures/WolfhudEE/guard_curious"

config.icons.camera_alerted = "guis/textures/WolfhudEE/camera_alerted"
config.icons.camera_curious = "guis/textures/WolfhudEE/camera_curious"

config.colors = {}
config.colors.called  = Color(1,0,0)
config.colors.calling = Color(1,0,0)
config.colors.subdued = Color('008000')
config.colors.alerted = Color(1,0.2,0)
config.colors.curious = Color(0,0.65,1)

-- OVERRIDES *******************************************************************
local _upd_criminal_suspicion_progress_orig = GroupAIStateBase._upd_criminal_suspicion_progress
function GroupAIStateBase:_upd_criminal_suspicion_progress(...)
	if self._ai_enabled then
		for obs_key, obs_susp_data in pairs(self._suspicion_hud_data or {}) do
			local waypoint = managers.hud._hud.waypoints["susp1" .. tostring(obs_key)]

			if waypoint then
				local waypoint_data = buildWaypointData(obs_susp_data)
				setWaypointIcon(waypoint, decideWaypointIcon(waypoint_data))
				setWaypointColor(waypoint, decideWaypointColor(waypoint_data))
			end
		end
	end

	return _upd_criminal_suspicion_progress_orig(self, ...)
end

-- FUNCTION LIB ****************************************************************
function buildWaypointData(obs_susp_data)
	local unit = obs_susp_data.u_observer
	local data = {}

	--type
	if managers.enemy:is_civilian(unit) then
		data.type = "civilian"
	elseif unit:character_damage() then
		data.type = "guard"
	else
		data.type = "camera"
	end

	--state
	if (type(obs_susp_data.status) == 'string' and obs_susp_data.status == 'called') then
		data.state = "called"
	elseif (type(obs_susp_data.status) == 'string' and obs_susp_data.status == 'calling') then
		data.state = "calling"
	elseif (unit:anim_data() and unit:anim_data().drop) then
		data.state = "subdued"
	elseif (obs_susp_data.alerted) then
		data.state = "alerted"
	else
		data.state = "curious"
	end

	return data
end

function decideWaypointIcon(waypoint_data)
	local icon

	if waypoint_data.type == "camera" then
		if waypoint_data.state == "alerted" then
			icon = config.icons.camera_alerted
		else
			icon = config.icons.camera_curious
		end
	elseif waypoint_data.type == "civilian" then
		if waypoint_data.state == "subdued" then
			icon = config.icons.civilian_subdued
		elseif waypoint_data.state == "alerted" then
			icon = config.icons.civilian_alerted
		else
			icon = config.icons.civilian_curious
		end
	elseif waypoint_data.type == "guard" then
		if waypoint_data.state == "alerted" then
			icon = config.icons.guard_alerted
		else
			icon = config.icons.guard_curious
		end
	end

	--disable icon change for calling/called status (use built-in icons)
	if waypoint_data.state == "calling" or waypoint_data.state == "called" then
		icon = false
	end

	return icon
end

function decideWaypointColor(waypoint_data)
	local color

	if waypoint_data.state == "called" then
		color = config.colors.called
	elseif waypoint_data.state == "calling" then
		color = config.colors.calling
	elseif waypoint_data.state == "subdued" then
		color = config.colors.subdued
	elseif waypoint_data.state == "alerted" then
		color = config.colors.alerted
	elseif waypoint_data.state == "curious" then
		color = config.colors.curious
	end

	return color
end

function setWaypointIcon(waypoint, icon)
	if icon then
		waypoint.bitmap:set_image(icon)
	end
end

function setWaypointColor(waypoint, color)
	if color then
		waypoint.bitmap:set_color(color)
		waypoint.arrow:set_color(color:with_alpha(0.75))
	end
end