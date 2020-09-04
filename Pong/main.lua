WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

-- https://github.com/vrld/hump.git
Class = require 'class'
push = require 'push'
require 'Paddle'
require 'Ball'

-- This thing is sorta like an initializer
--[[function love.load()
    love.window.setMode(WINDOW_WIDTH,WINDOW_HEIGHT, {
        fullscreen=false,
        vsync=true, --When screen refreshes, refresh!
        resizable= false
    })
end]]

function love.load()
    math.randomseed(os.time())

    love.graphics.setDefaultFilter('nearest', 'nearest') --[[Love generally applies a filter (Just like it clouds your judgement) and 
    makes the resizing sorta blurry. This function tells you to take the nearest pixel and fill it.]]

    love.window.setTitle('Pong!')

    smallFont = love.graphics.newFont('font.TTF', 8) -- Creates a font object
    scoreFont = love.graphics.newFont('font.TTF', 32)
    winFont = love.graphics.newFont('font.TTF', 16)

    player1 = 0
    player2 = 0
    winner=0
    AIflag=0
    guessProb=1
    turn = math.random(2) == 1 and 1 or 2

    paddle1 = Paddle(5, 20, 5, 20)
    paddle2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 40, 5, 20)
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 5, 5)

    if turn == 1 then
        ball.dx = 100
    elseif turn == 2 then
        ball.dx = -100
    end


    sounds={
        ['paddle']=love.audio.newSource('paddleHit.wav','static'),
        ['wall']=love.audio.newSource('wall.wav','static'),
        ['score']=love.audio.newSource('score.wav','static')
    }


    gameState = 'menu'

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT,
                     {fullscreen = false, vsync = true, resizable = true})
end

function love.resize(w,t)
    push:resize(w,t)
end

function love.update(dt)
    if gameState == 'play' then

        if ball.x < 0 then
            player2 = player2 + 1
            sounds['score']:play()
            ball:reset()
            ball.dx = 100
            turn = 1
            gameState = 'serve'
            if player2>=3 then
                winner=2
                gameState='victory'
            end
        elseif ball.x > VIRTUAL_WIDTH - 4 then
            player1 = player1 + 1
            sounds['score']:play()
            ball:reset()
            ball.dx = -100
            turn = 2
            gameState = 'serve'
            if player1>=3 then
                winner=1
                gameState='victory'
            end
        end

        if ball:collides(paddle1) then
            sounds['paddle']:play()
            ball.dx = -ball.dx
        elseif ball:collides(paddle2) then
            sounds['paddle']:play()
            ball.dx = -ball.dx
        end

        if ball.y <= 0 then
            ball.dy = -ball.dy
            ball.y = 0
            sounds['wall']:play()
        end

        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.dy = -ball.dy
            ball.y = VIRTUAL_HEIGHT - 4
            sounds['wall']:play()

        end

        if AIflag ==1 then
            randomNo=math.random()
            if randomNo < guessProb then
                if paddle1.y > ball.y+ball.height/2 then
                    paddle1.dy= -PADDLE_SPEED
                elseif paddle1.y + paddle1.height < ball.y + ball.height/2 then
                    paddle1.dy= PADDLE_SPEED
                else
                    paddle1.dy=0
                end
            else
                paddle1.dy=0
            end 
        else
            if love.keyboard.isDown('w') then
                paddle1.dy = -PADDLE_SPEED -- player1Y = math.max(player1Y - PADDLE_SPEED * dt, 0)
            elseif love.keyboard.isDown('s') then
                paddle1.dy = PADDLE_SPEED -- player1Y = math.min(player1Y + PADDLE_SPEED * dt, VIRTUAL_HEIGHT - 20)
            else
                paddle1.dy = 0
            end
        end
        if love.keyboard.isDown('up') then
            paddle2.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('down') then
            paddle2.dy = PADDLE_SPEED
        else
            paddle2.dy = 0
        end
    end
    if gameState == 'play' then ball:update(dt) end
    paddle1:update(dt)
    paddle2:update(dt)

end

function love.keypressed(key)
    if key == 'escape' then
        if gameState == 'menu' then
            love.event.quit()
        else
            player1=0
            player2=0
            ball:reset()
            gameState ='menu'
        end
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState=='victory' then
            gameState='start'
            player1=0
            player2=0
        elseif gameState == 'serve' then
            gameState = 'play'
        end
    elseif key == '1' then
        if gameState == 'menu' then
            AIflag=1
            gameState = 'AI'
        elseif gameState == 'AI' then 
            gameState= 'start'
            guessProb=0.2
        end
    elseif key == '2' then
        if gameState == 'menu' then
            gameState ='start'
            AIflag=0
        elseif gameState == 'AI' then
            guessProb=0.8
            gameState = 'start'
        end
    elseif key == '3' then
        if gameState == 'AI' then
            gameState ='start'
        end
    end

end

function displayFPS()
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.setFont(smallFont)
    love.graphics.print("FPS " .. tostring(love.timer.getFPS()), 35, 10)
    love.graphics.setColor(1, 1, 1, 1)
end

function love.draw()
    push:apply('start')

    love.graphics.clear(45 / 255, 44 / 255, 52 / 255, 1) -- Sorta BG Color

    love.graphics.setFont(scoreFont)
    love.graphics.print(player1, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(player2, VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)

    ball:render()
    paddle1:render()
    paddle2:render()

    love.graphics.setFont(smallFont)
    if gameState == 'menu' then
        love.graphics.printf("Enter your choice", 0, 20, VIRTUAL_WIDTH,
                             "center")
        love.graphics.printf("1. AI", 0, 30, VIRTUAL_WIDTH,
                             "center")
        love.graphics.printf("2. Multiplayer", 0, 40, VIRTUAL_WIDTH,
                             "center")
    elseif gameState == 'AI' then
        love.graphics.printf("1. Easy", 0, 20, VIRTUAL_WIDTH,
                             "center")
        love.graphics.printf("2. Hard", 0, 30, VIRTUAL_WIDTH,
                             "center")
        love.graphics.printf("3. Impossible [Literally]", 0, 40, VIRTUAL_WIDTH,
                             "center")
    elseif gameState == 'start' then
        love.graphics.printf("Press Enter to start", 0, 20, VIRTUAL_WIDTH,
                             "center")
    elseif gameState == 'serve' then
        love.graphics.printf("Player " .. tostring(turn) .. "'s Turn to Serve",
                             0, 20, VIRTUAL_WIDTH, "center")
        love.graphics.printf("Press Enter to start", 0, 30, VIRTUAL_WIDTH,
                             "center")
    elseif gameState == 'victory' then
        love.graphics.setFont(winFont)
        love.graphics.printf("Player " .. tostring(winner) .. " wins!!", 0, 10, VIRTUAL_WIDTH,
                             "center")
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press Enter to start", 0, 40, VIRTUAL_WIDTH,
                             "center")

    end

    displayFPS()

    push:apply('end')
end
