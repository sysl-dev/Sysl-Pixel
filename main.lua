function love.load()
    lovePixels = require('library.lovepixels')
    lovePixels:load(2, true)
end

function love.draw()
  lovePixels:drawGameArea()
love.graphics.setColor({60,60,60,255})
love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
love.graphics.setColor({255,0,0,255})
love.graphics.rectangle("fill", 3, 23, 8, 16)
love.graphics.print(lovePixels.mousex .. " " .. lovePixels.mousey .. " " .. lovePixels.maxScale .. " " .. lovePixels.maxWindowScale, 1, 3)
love.graphics.rectangle("fill", lovePixels.mousex, lovePixels.mousey - 1, 1, 3)
love.graphics.rectangle("fill", lovePixels.mousex - 1, lovePixels.mousey, 3, 1)
love.graphics.setColor({255,255,255,255})
lovePixels:endDrawGameArea()
end

function love.update()
lovePixels:pixelMouse()
lovePixels:calcOffset()
end

function love.keypressed(key, scancode, isrepeat)
  if key == "m" then
    lovePixels:resizeScreen(lovePixels.maxWindowScale)
  end
  if key == "f" then
    lovePixels:fullscreenToggle()
  end
end
