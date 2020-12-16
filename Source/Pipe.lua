Pipe = Class()
local PIPE_IMG = love.graphics.newImage('pipe.png')
PIPE_HEIGHT = PIPE_IMG:getHeight()
PIPE_WIDTH = PIPE_IMG:getWidth()
PIPE_SPEED = 60

function Pipe:init(dir, y)
    self.x = VIRTUAL_WIDTH
    self.y = y
    self.width = PIPE_WIDTH
    self.height = PIPE_HEIGHT
    self.orientation = dir
end

function Pipe:update(dt)
   
end

function Pipe:render()
    love.graphics.draw(PIPE_IMG, self.x, 
    (self.orientation == 'top' and self.y + PIPE_HEIGHT or self.y), 
    0, 1, self.orientation == 'top' and -1 or 1)
end