function love.load()
    lovePixels = require('library.lovepixels')
    lovePixels:load(2)

    -- Testing Stuff Below, Use for Example
    rotimage = love.graphics.newImage("images/rotationtest.png")
    movingrot = 0
    movingpar = 0
    imagescale = 1
    font = love.graphics.newImageFont('images/imagefont.png', -- using Dewgy's love2D NES font.
	" !\"#$%&\'()*+,-./" ..
	"0123456789:;<=>?" ..
	"@ABCDEFGHIJKLMNO" ..
	"PQRSTUVWXYZ[\\]^_" ..
	"`abcdefghijklmno" ..
	"pqrstuvwxyz{|}~")
  font:setLineHeight( 1.5 )
    love.graphics.setFont(font)

    local img = love.graphics.newImage('images/rotationtest.png')

    	psystem = love.graphics.newParticleSystem(img, 32)
    	psystem:setParticleLifetime(3, 7) -- Particles live at least 2s and at most 5s.
    	psystem:setEmissionRate(25)
    	psystem:setSizes(1,0.1)
    	psystem:setSizeVariation(1)
    	psystem:setLinearAcceleration(0, 0, 40, 5) -- Random movement in all directions.
    	psystem:setColors(255, 255, 255, 255, 255, 255, 255, 0) -- Fade to transparency.
end

function love.draw()
  lovePixels:drawGameArea() -- Include this before all draws, if using HUMP, include within each game state draw
  -- Testing Stuff Below, Use for Example
love.graphics.setColor({30,30,30,255})
love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth() / lovePixels.scale, love.graphics.getHeight() / lovePixels.scale)
love.graphics.setColor({255,255,255,255})
love.graphics.print("Controls: V MaxScale, B MinScale,\n          N FullScreen, M ToggleSizes, C ToggleMouse " ..
                    "\nPixelMouseX/Y: " .. lovePixels.mousex  ..
                    "/" .. lovePixels.mousey .. " Window Focused: " .. text ..
                    "\nMaxScale: " .. lovePixels.maxScale ..
                    "\nMaxWindowScale: " .. lovePixels.maxWindowScale ..
                    "\nCurrentScale: " .. lovePixels.scale, 1, 3)
love.graphics.rectangle("fill", lovePixels.mousex, lovePixels.mousey - 1, 1, 3)
love.graphics.rectangle("fill", lovePixels.mousex - 1, lovePixels.mousey, 3, 1)
love.graphics.setColor({255,255,255,255})
love.graphics.print("Rotation and scale (no blur, no AA) test:", 01, 80+00)
love.graphics.draw(rotimage, 10,110+00, 0, 1, 1, 8, 8)
love.graphics.draw(rotimage, 30,110+00, movingrot, 1, 1, 8, 8)
love.graphics.draw(rotimage, 50,110+00, movingrot*4, 1, 1, 8, 8)
love.graphics.draw(rotimage, 70,110+00, movingrot*8, 1, 1, 8, 8)
love.graphics.draw(rotimage, 90,110+00, 0, 1, 2, 8, 8)
love.graphics.draw(rotimage, 120,110+00, 0, 2, 1, 8, 8)
love.graphics.draw(rotimage, 160,110+00, 0, imagescale, imagescale, 8, 8)
love.graphics.draw(psystem, movingpar, 80+84)
love.graphics.print("Particle System Test (no blur, no AA) test:", 01, 80+64)
lovePixels:endDrawGameArea() -- Include this after all draws, if using HUMP, include within each game state draw
end



function love.keypressed(key, scancode, isrepeat)
  if key == "v" then
    lovePixels:resizeScreen(lovePixels.maxWindowScale)
  end
  if key == "b" then
    lovePixels:resizeScreen(1)
  end
  if key == "n" then
    lovePixels:fullscreenToggle()
  end
  if key == "c" then
    love.mouse.setVisible(not love.mouse.isVisible())
    love.mouse.setGrabbed(not love.mouse.isGrabbed())
  end
  if key == "m" then
		if lovePixels.scale < math.floor(lovePixels.maxWindowScale) then
			lovePixels:resizeScreen(lovePixels.scale + 1)
		else
			lovePixels:resizeScreen(1)
		end
  end
end

function love.update(dt)
  -- Include these in your core update loop
lovePixels:pixelMouse()
lovePixels:calcOffset()
-- Testing Stuff Below, Use for Example
movingrot = movingrot + 0.01
movingpar = -10
imagescale = imagescale + 0.01
if movingpar > 400 then movingpar = 0 end
if imagescale > 2 then imagescale = 0 end
psystem:update(dt)
end

function love.focus(f)
  if f then
    text = "FOCUSED"
  else
    text = "UNFOCUSED"
  end
end
