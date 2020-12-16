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

local bg = love.graphics.newImage('bg.png')
local bgScroll = 0
BG_SPEED = 30


local bird = Bird()
love.keyboard.keysPressed = {}

local pipes = {}
local pipeTimer = 0
local prevY = -PIPE_HEIGHT + math.random(80) +20

local isScrolling = true
score = 0
local state = 'start'

function love.load()
    love.graphics.setDefaultFilter('nearest','nearest')
    love.window.setTitle('Flappy Bird')

    smallFont = love.graphics.newFont('font.TTF', 8) 
    countFont = love.graphics.newFont('font.TTF', 32)
    scoreFont = love.graphics.newFont('font.TTF', 16)

    math.randomseed(os.time())

    sounds = {
        ['jump'] = love.audio.newSource('jump.wav', 'static'),
        ['gameover'] = love.audio.newSource('gameover.wav', 'static'),
        ['hurt'] = love.audio.newSource('hurt.wav', 'static'),
        ['score'] = love.audio.newSource('score.wav', 'static'),
        ['music'] = love.audio.newSource('soundtrack.mp3', 'static')
    }

    sounds['music']:setLooping(true)
    sounds['music']:play()

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
    if not isScrolling and state=='play' then
        sounds['music']:stop()
        sounds['hurt']:play()
        sounds['gameover']:play()
        state = 'stop'
    end
    if love.keyboard.isPressed('enter') or love.keyboard.isPressed('return') then
        if state == 'start' then
            state='play'
            isScrolling = true
            pipes={}
        elseif state == 'stop' then
            state = 'start'
            sounds['music']:setLooping(true)
            sounds['music']:play()
            isScrolling = 'true'
            score = 0
            bird:reset()
            for k, pipe in pairs(pipes) do
                table.remove(pipes, k)
            end
            local pipes = {}
            local pipeTimer = 0
        end
    end
    if isScrolling then
        bgScroll = ( bgScroll + BG_SPEED * dt )%700

        if state == 'play' then
            bird:update(dt)

            pipeTimer = pipeTimer + dt
            if pipeTimer > 2 then
                local y = math.max(-PIPE_HEIGHT+30, math.min(prevY + math.random(-20,20), VIRTUAL_HEIGHT - 90 - PIPE_HEIGHT))
                prevY = y
                table.insert(pipes, PipePair(y))
                pipeTimer = 0
            end

            for k,pipe in pairs(pipes) do
                if pipe.passed == false then
                    if pipe.x + PIPE_WIDTH <= bird.x then
                        pipe.passed = true
                        score = score +1
                        sounds['score']:play()
                    end
                end
                pipe:update(dt)
                for l, onePipe in pairs(pipe.pipes) do
                    if bird:collides(onePipe) then
                        sounds['music']:stop()
                        sounds['hurt']:play()
                        sounds['gameover']:play()
                        state = 'stop'
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
    end
    love.keyboard.keysPressed = {}

end

function love.draw()
    push:start()
    love.graphics.draw(bg, -bgScroll, 0)
    if state == 'start' then
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.setFont(countFont)
        love.graphics.printf('Flappy Bird', 0, 64, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(scoreFont)
        love.graphics.printf('Press Enter', 0, 100, VIRTUAL_WIDTH, 'center')
        love.graphics.setColor(1, 1, 1, 1)
    elseif state == 'stop' then
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.setFont(countFont)
        love.graphics.printf('Damn! Try Again!!', 0, 64, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(scoreFont)
        love.graphics.printf('Score: ' .. tostring(score), 0, 100, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to Play Again!', 0, 160, VIRTUAL_WIDTH, 'center')
        love.graphics.setColor(1, 1, 1, 1)
    elseif state == 'play' then
        for k, pipe in pairs(pipes) do
            pipe:render()
        end
        love.graphics.setColor(0,0, 0,1)
        love.graphics.setFont(smallFont)
        love.graphics.print('Score: ' .. tostring(score),8,8)
        love.graphics.setColor(1, 1, 1, 1)
        
    end
    bird:render()
    push:finish()
end

