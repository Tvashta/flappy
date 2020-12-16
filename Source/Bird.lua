Bird = Class()

function Bird:init()
   self.image = love.graphics.newImage('bird.png')
   self.width = self.image:getWidth()
   self.height = self.image:getHeight()
   
   self.x = VIRTUAL_WIDTH/2 - (self.width/2)
   self.y = VIRTUAL_HEIGHT/2 - (self.height/2)

   self.dy = 0
end

function Bird:reset()
    self.x = VIRTUAL_WIDTH/2 - (self.width/2)
    self.y = VIRTUAL_HEIGHT/2 - (self.height/2)
    self.dy = 0
end
    

function Bird:render()
    love.graphics.draw(self.image, self.x, self.y)
end

function Bird:update(dt)
    self.dy = self.dy + GRAVITY * dt

    if love.keyboard.isPressed('space') then
        sounds['jump']:play()
        self.dy = -5
    end
    if self.y + self.dy <=VIRTUAL_HEIGHT-self.height then
        self.y =  self.y + self.dy
    else 
        self.y=VIRTUAL_HEIGHT-self.height
    end
    if self.y < 0 then
            self.y =0
    end
end

function Bird:collides(pipe)
    return self.x  + self.width - 4 >= pipe.x and self.x + 2 <= pipe.x + pipe.width and
            self.y + self.height- 4 >= pipe.y and self.y + 2 <= pipe.y + pipe.height
end

function Bird:passed(pipe)
    return self.x > pipe.width
end