local push = require('push')
local anim8 = require('anim8')

love.graphics.setDefaultFilter('nearest', 'nearest')

WIDTH, HEIGHT = 480, 270

local player = { x = 6, y = HEIGHT / 3, speed = 200 }
local background = { x = 0, y = 0, sprite = love.graphics.newImage('T_field2.png'), speed = 50 }

function love.load()
    love.window.setTitle('suit ninja')

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
    }
    player.currAnim = player.animations.run
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
end

function love.update(dt)
    if love.keyboard.isDown('up') then
        player.y = player.y - player.speed * dt
    end
    if love.keyboard.isDown('down') then
        player.y = player.y + player.speed * dt
    end
    if love.keyboard.isDown('left') then
        player.x = player.x - player.speed * dt
    end
    if love.keyboard.isDown('right') then
        player.x = player.x + player.speed * dt
    end
    player.currAnim:update(dt)

    background.x = background.x + background.speed * dt
    background.x = background.x % WIDTH
end

function love.draw()
    push:start()

    love.graphics.draw(background.sprite, -background.x, background.y)

    local scale = 2
    player.currAnim:draw(player.spritesheet, player.x, player.y, 0, scale, scale)

    push:finish()
end
