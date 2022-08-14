local boids = {}
local options = require "options"
local dt = love.timer.getDelta()

function boids.new()
    local flock = {}

    function flock:add_members(num)
        for member = 1, num do
            flock[member] = {
                color = { 1, 1, 1, 1 };
                scale = 1;
                position = { x = math.random (1, love.graphics.getWidth()), y = math.random (1, love.graphics.getHeight()) };
                v = {
                [1] = { x = 0.0, y = 0.0 };
                [2] = { x = 0.0, y = 0.0 };
                [3] = { x = 0.0, y = 0.0 };
                [4] = { x = 0.0, y = 0.0 };
                [5] = { x = 0.0, y = 0.0 };
                }
            }
        end
        return flock
    end

    -- Rule 1: compete for the center of the flock
    function flock:rule1()
        local averageX = 0
        local averageY = 0
        for member = 1, #flock do
            averageX = averageX + flock[member].position.x
            averageY = averageY + flock[member].position.y
        end
        averageX = averageX / #flock
        averageY = averageY / #flock
        for member = 1, #flock do
            if flock[member].position.x > averageX then
                flock[member].v[1].x = flock[member].v[1].x - dt
            end
            if flock[member].position.x < averageX then
                flock[member].v[1].x = flock[member].v[1].x + dt
            end
            if flock[member].position.y > averageY then
                flock[member].v[1].y = flock[member].v[1].y - dt
            end
            if flock[member].position.y < averageY then
                flock[member].v[1].y = flock[member].v[1].y + dt
            end
        end
        return flock
    end

    -- Rule 2: try to match the speed of the flock
    function flock:rule2()
        local averageX = 0
        local averageY = 0
        for member = 1, #flock do
            for i, vec in pairs(flock[member].v) do
                averageX = averageX + vec.x
            end
            for i, vec in pairs(flock[member].v) do
                averageY = averageY + vec.y
            end
        end
        averageX, averageY = averageX / #flock, averageY / #flock
        for member = 1, #flock do
            flock[member].v[2].x = averageX / 5
            flock[member].v[2].y = averageY / 5
        end
    end

    -- detect if coordinates are inside circle
    local circle = function (cx, cy, radius, x, y)
        local dx = cx - x
        local dy = cy - y
        return dx * dx + dy * dy <= radius * radius
    end

    -- Rule 3: avoid collision with other boids
    function flock:rule3()
        local radius = options.collision_radius or 10
        for i = 1, #flock do
            local member = flock[i]
            for j = 1, #flock do
                local neighbor = flock[j]
                if i ~= j then j = j + 1
                    if circle(member.position.x, member.position.y, radius, neighbor.position.x, neighbor.position.y) then
                        member.v[3].x = member.v[3].x + math.sin(neighbor.position.x)
                        member.v[3].y = member.v[3].y + math.cos(neighbor.position.y)
                    end
                end
            end
        end
    end

    -- Rule 4: offscreen boids return to the screen
    local screenwidth = love.graphics.getWidth()
    local screenheight = love.graphics.getHeight()
    function flock:rule4()
        for member = 1, #flock do
            if flock[member].position.x > screenwidth then
                flock[member].v[4].x = flock[member].v[4].x - dt
            end
            if flock[member].position.x < 0 then
                flock[member].v[4].x = flock[member].v[4].x + dt
            end
            if flock[member].position.y > screenheight  then
                flock[member].v[4].y = flock[member].v[4].y - dt
            end
            if flock[member].position.y < 0 then
                flock[member].v[4].y = flock[member].v[4].y + dt
            end
        end
    end

    -- Rule 5: try to align with your neighbor
    function flock:rule5()
        local radius = options.align_radius or 50
        for i, _ in ipairs(flock) do
                local member = flock[i]
                for j = 1, #flock do
                    local neighbor = flock[j]
                    if circle(member.position.x, member.position.y, radius, neighbor.position.x, neighbor.position.y) then
                        local x, y = 0, 0
                        for _, v in pairs(member.v) do
                            x = x + v.x
                        end
                        for _, v in pairs(member.v) do
                            y = y + v.y
                        end
                        member.v[5].x = x / #member.v
                        member.v[5].y = y / #member.v
                    end
                end
            end
        end

        -- slow down if you're going over the speed limit
        local function clamp(member)
            for i, v in pairs(member.v) do
                if math.abs(v.x) > options.speed_limit then
                    v.x = v.x * 0.99
                end
                if math.abs(v.y) > options.speed_limit then
                    v.y = v.y * 0.99
                end
            end
        end

    function flock:update()
        local speed = options.speed
        flock:rule1()
        flock:rule2()
        flock:rule3()
        flock:rule4()
        flock:rule5()
        for member= 1, #flock do
            clamp(flock[member])
            local x, y = 0, 0
            for i, v in pairs(flock[member].v) do
                x = x + v.x
            end
            for i, v in pairs(flock[member].v) do
                y = y + v.y
            end
            flock[member].position.x = flock[member].position.x + x * speed
            flock[member].position.y = flock[member].position.y + y * speed
        end
        return flock
    end

    return flock
end

return boids