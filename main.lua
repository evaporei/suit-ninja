local push = require('push')
local anim8 = require('anim8')
local Timer = require('timer')

love.graphics.setDefaultFilter('nearest', 'nearest')

WIDTH, HEIGHT = 480, 270

local lanes = {
    [1] = HEIGHT / 3 + 8,
    [2] = HEIGHT / 3 * 2 - 2,
}

local player = { x = 6, y = HEIGHT / 3 + 8, speed = 200, width = 32, height = 32 }
local background = { x = 0, y = 0, sprite = love.graphics.newImage('T_field2.png'), speed = 50 }
local currLane = 1
local cards = {}
local projectiles = {}

local suits = { 'hearts', 'diamonds', 'spades', 'clubs' }

local function lpad(s, l, c)
    local res = string.rep(c or ' ', l - #s) .. s

    return res, res ~= s
end

function love.load()
    love.window.setTitle('suit ninja')

    math.randomseed(os.time())

    push:setupScreen(WIDTH, HEIGHT, 1280, 720, {
        vsync = true,
        fullscreen = false,
        resizable = false,
    })

    player.spritesheet = love.graphics.newImage('ninja-animated2.png')
    player.grid = anim8.newGrid(32, 32, player.spritesheet:getDimensions())
    player.animations = {
        idle = anim8.newAnimation(player.grid(1, '1-4'), 0.2),
        run = anim8.newAnimation(player.grid(2, '1-4'), 0.2),
        hurt = anim8.newAnimation(player.grid(6, '1-1'), 0.2),
    }
    player.currAnim = player.animations.run

    Timer.every(2, function ()
        local suit = suits[math.random(#suits)]
        local number = math.random(13)
        local file = 'cards/' .. suit .. '/' .. lpad(tostring(number), 2, '0') .. '.png'
        local card = { y = lanes[1] + 20, sprite = love.graphics.newImage(file), width = 27, height = 34 }
        card.x = WIDTH + card.sprite:getWidth()
        table.insert(cards, card)
    end)
end

function love.keypressed(key)
    if key == 'up' then
        currLane = 1
    end
    if key == 'down' then
        currLane = 2
    end

    if key == 'z' then
        local projectile = { active = false, speed = 400, sprite = love.graphics.newImage('cards/suits/heart.png'), width = 32, height = 32 }
        projectile.x, projectile.y = player.x + projectile.width, player.y + projectile.height
        projectile.active = true
        table.insert(projectiles, projectile)
    end

    if key == 'escape' then
        love.event.quit()
    end
end

local function collision(obj1, obj2)
    if obj1.x > obj2.x + obj2.width or obj1.x + obj1.width < obj2.x then
        return false
    end
    if obj1.y > obj2.y + obj2.height or obj1.y + obj1.height < obj2.y then
        return false
    end
    return true
end

function love.update(dt)
    if love.keyboard.isDown('left') then
        player.x = player.x - player.speed * dt
    end
    if love.keyboard.isDown('right') then
        player.x = player.x + player.speed * dt
    end
    Timer.tween(0.1, {
        [player] = { y = lanes[currLane] }
    })

    background.x = background.x + background.speed * dt
    background.x = background.x % WIDTH

    for _, card in pairs(cards) do
        if not card.dead then
            card.x = card.x - background.speed * dt

            if collision(player, card) then
                player.currAnim = player.animations.hurt
                Timer.after(0.2, function ()
                    player.currAnim = player.animations.run
                end)
                card.dead = true
            end
        end
    end

    for _, projectile in pairs(projectiles) do
        if projectile.active then
            projectile.x = projectile.x + projectile.speed * dt
            for _, card in pairs(cards) do
                if not card.dead and collision(projectile, card) then
                    card.dead = true
                    projectile.active = false
                end
            end
        end
    end

    player.currAnim:update(dt)

    Timer.update(dt)
end

function love.draw()
    push:start()

    love.graphics.draw(background.sprite, -background.x, background.y)

    for _, projectile in pairs(projectiles) do
        if projectile.active then
            love.graphics.draw(projectile.sprite, projectile.x, projectile.y, math.rad(270), nil, nil, projectile.width / 2, projectile.height / 2)
        end
    end

    for _, card in pairs(cards) do
        if not card.dead then
            love.graphics.draw(card.sprite, card.x, card.y, 0, 0.8, 0.8)
        end
    end

    local scale = 2
    player.currAnim:draw(player.spritesheet, player.x, player.y, 0, scale, scale)

    push:finish()
end
