push = require 'push'
Class = require 'class'
require 'Bird'
require 'Pipe'
require 'PipePair'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

GRAVITY = 20

local bg = love.graphics.newImage('background.png')
local bgScroll = 0
BG_SPEED = 30

local gd = love.graphics.newImage('ground.png')
local gdScroll = 0
GD_SPEED = 60

local bird = Bird()
love.keyboard.keysPressed = {}

local pipes = {}
local pipeTimer = 0
local prevY = -PIPE_HEIGHT + math.random(80) +20

local isScrolling = true

function love.load()
    love.graphics.setDefaultFilter('nearest','nearest')
    love.window.setTitle('Flappy Bird')
    math.randomseed(os.time())
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync= true,
        fullscreen=false,
        resizable=true
    })
end

function love.resize(w,h)
    push:resize(w,h)
end

function love.keypressed(key)
    love.keyboard.keysPressed [key] = true
    if key == 'escape' then
        love.event.quit()
    end
end

function love.keyboard.isPressed(key)
    return love.keyboard.keysPressed[key]
end

function love.update(dt)
    isScrolling = bird.y >0 and bird.y<VIRTUAL_HEIGHT-bird.height - 5 and isScrolling
    if isScrolling then
        bgScroll = ( bgScroll + BG_SPEED * dt )%413
        gdScroll = ( gdScroll + GD_SPEED * dt )%VIRTUAL_WIDTH
        
        bird:update(dt)
        

        pipeTimer = pipeTimer + dt
        if pipeTimer > 2 then
            local y = math.max(-PIPE_HEIGHT+10, math.min(prevY + math.random(-20,20), VIRTUAL_HEIGHT - 90 - PIPE_HEIGHT))
            prevY = y
            table.insert(pipes, PipePair(y))
            pipeTimer = 0
        end

        for k,pipe in pairs(pipes) do
            pipe:update(dt)
            for l, onePipe in pairs(pipe.pipes) do
                if bird:collides(onePipe) then
                    isScrolling =false
                end
            end 
        end

        for k, pipe in pairs(pipes) do
            if pipe.remove then
                table.remove(pipes, k)
            end
        end
    end
    love.keyboard.keysPressed = {}

end

function love.draw()
    push:start()
    love.graphics.draw(bg, -bgScroll, 0)
    for k, pipe in pairs(pipes) do
        pipe:render()
    end
    love.graphics.draw(gd, -gdScroll, VIRTUAL_HEIGHT-16)
    bird:render()
    push:finish()
end

