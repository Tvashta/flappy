push = require 'push'
Class = require 'class'
require 'Bird'

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

function love.load()
    love.graphics.setDefaultFilter('nearest','nearest')
    love.window.setTitle('Flappy Bird')
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
    bgScroll = ( bgScroll + BG_SPEED * dt )%413
    gdScroll = ( gdScroll + GD_SPEED * dt )%VIRTUAL_WIDTH
    bird:update(dt)
    love.keyboard.keysPressed = {}
end

function love.draw()
    push:start()
    love.graphics.draw(bg, -bgScroll, 0)
    love.graphics.draw(gd, -gdScroll, VIRTUAL_HEIGHT-16)
    bird:render()
    push:finish()
end

