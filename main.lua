local accels
local vels
local positions

local initialPos = 0
local initialVel = -150
local accelDirection = 1

local maxSpeed = 125
local accelCurveShaper = 2.5 -- Must be positive
local maxAccel = 40

local function sign(x)
	if x > 0 then
		return 1
	elseif x == 0 then
		return 0
	end
	return -1
end

local function recalc()
	accels = {}
	vels = {}
	positions = {}

	-- This is a piecewise function
	local function getAccelMultiplier(velocity, accelerationDirection)
		if accelerationDirection == 0 then
			return 0
		end
		local function getAccelMultiplierCore(speed, accelerationDirection)
			-- Speed can't be negative, and accelerationDirection should be negated (whether that's positive or negative) if velocity was too
			if accelerationDirection <= 0 then
				return 1
			end
			return ((maxSpeed - speed) / maxSpeed) ^ (1 / accelCurveShaper)
		end
		if velocity > -maxSpeed and velocity <= 0 then
			return getAccelMultiplierCore(-velocity, -accelerationDirection)
		elseif velocity >= 0 and velocity < maxSpeed then
			return getAccelMultiplierCore(velocity, accelerationDirection)
		elseif sign(velocity) * sign(accelerationDirection) == 1 then
			return 0
		else
			return 1
		end
	end

	positions[1] = {t = 0, v = initialPos}
	vels[1] = {t = 0, v = initialVel}
	accels[1] = {t = 0, v = maxAccel * getAccelMultiplier(initialVel, accelDirection)}

	local dt = 0.5
	for t = 0.5, 12.5, 0.5 do
		local pos = positions[#positions].v
		local vel = vels[#vels].v
		local accel = maxAccel * getAccelMultiplier(vel, accelDirection)
		accels[#accels+1] = {t = t, v = accel}
		vel = vel + accel * dt
		vels[#vels+1] = {t =t, v = vel}
		pos = pos + vel * dt
		positions[#positions+1] = {t = t, v = pos}
	end
end

function love.load()
	recalc()
end

function love.draw()
	local h = love.graphics.getHeight() / 2

	local function drawGraph(tbl)
		local lastX, lastY
		for _, v in ipairs(tbl) do
			local x, y = v.t * 64, -v.v + h
			if lastX then
				love.graphics.line(lastX, lastY, x, y)
			else
				love.graphics.points(x, y)
			end
			lastX, lastY = x, y
		end
	end

	love.graphics.setColor(0.5, 0.5, 0.5)
	love.graphics.line(0, h - maxSpeed, love.graphics.getWidth(), h - maxSpeed)
	love.graphics.line(0, h + maxSpeed, love.graphics.getWidth(), h + maxSpeed)
	love.graphics.setColor(1, 1, 1)
	love.graphics.line(0, h, love.graphics.getWidth(), h)

	love.graphics.setColor(1, 0, 0)
	drawGraph(accels)
	love.graphics.setColor(0, 1, 0)
	drawGraph(vels)
	love.graphics.setColor(0, 0, 1)
	drawGraph(positions)
end
