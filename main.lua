local boids = require "boids"
local options = require "options"

local simulation_running = false
local flock = nil

local flock_count = options.flock_count or 100

function love.keypressed(key)
    if key == 'space' then
        if not simulation_running then
            flock = boids:new()
            flock:add_members(flock_count)
            simulation_running = true
        else
            if simulation_running then
                flock = nil
                simulation_running = false
            end
        end
    end
end

function love.update()
    if simulation_running then
        FPS = love.timer.getFPS()
        flock:update()
    end
end

local text = "Press spacebar to begin."
local center_x = love.graphics.getWidth() / 2
local center_y = love.graphics.getHeight() / 2
local font = love.graphics.newFont(24)
love.graphics.setFont(font)
local offsetw = font:getWidth(text) / 2
local offseth = font:getHeight() / 2

function love.draw()
    if simulation_running then
    love.graphics.print(FPS)
        for i,v in ipairs(flock) do
            love.graphics.setColor(flock[i].color)
            love.graphics.circle("fill", v.position.x, v.position.y, 5)
        end
    else
        love.graphics.print("Press spacebar to begin.", center_x - offsetw, center_y - offseth)
    end
end