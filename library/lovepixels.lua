--[[----------------------------------------------------------------------------
lovePixels Beta v 1.8
Updated to fix fullscreen issues.
Updated to work with the new love color format. Replace 1, with 255 if needed.
C. Hall/SystemL 2018

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

Except as contained in this notice, the name(s) of the above copyright holders
shall not be used in advertising or otherwise to promote the sale, use or
other dealings in this Software without prior written authorization.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

Useful Testing Keys
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

Useful for using web love.
if love.system.getOS() == 'Web' then
  lovePixels.scale = 4 --fixed scale on web
else
  lovePixels.scale = newScale
  love.window.setMode(pixelWidth * lovePixels.scale, pixelHeight * lovePixels.scale, {})
end
  end
----------------------------------------------------------------------------]]--
local lovePixels = {}

local pixelWidth = love.graphics.getWidth()
local pixelHeight = love.graphics.getHeight()
local pixelBlack = {0,0,0,1}
local pixelWhite = {1,1,1,1}

function lovePixels:load(defaultScale)
    love.graphics.setDefaultFilter( "nearest", "nearest", 1 )
    lovePixels.mainCanvas = love.graphics.newCanvas(pixelWidth,pixelHeight)
    lovePixels:screenSize()
    lovePixels:calcMaxScale()
    lovePixels:calcOffset()
    defaultScale = defaultScale or lovePixels.maxWindowScale
    lovePixels:resizeScreen(defaultScale)
    -- Add functions as I work here
end

-- Only supports main screen. Game -> TV is usually screen mirroring.
function lovePixels:screenSize()
    local width, height = love.window.getDesktopDimensions(1)
    lovePixels.screenWidth = width
    lovePixels.screenHeight = height
end

function lovePixels:calcMaxScale() -- This is a much better way to do this.
    lovePixels.maxWindowScale = 3
    lovePixels.maxScale = 4
    local floatHeight = (lovePixels.screenHeight) / pixelHeight
    local floatWidth = (lovePixels.screenWidth) / pixelWidth

        if floatHeight < floatWidth then
            lovePixels.maxScale = (lovePixels.screenHeight) / pixelHeight
            -- We do -1 here to keep max window size in check from bleeding off the top and bottom of the screen in Windows.
            lovePixels.maxWindowScale = math.floor((lovePixels.screenHeight - 100) / pixelHeight)
        else
             lovePixels.maxScale = (lovePixels.screenWidth) / pixelWidth
             -- We do -1 here to keep max window size in check from bleeding off the top and bottom of the screen in Windows.
             lovePixels.maxWindowScale = math.floor((lovePixels.screenWidth - 100) / pixelWidth)
        end
        print("Lovepixels Max Scale: " .. lovePixels.maxScale)
        print("Lovepixels Max Window Scale: " .. lovePixels.maxWindowScale)
end

-- This should work on all monitors now? I think??
function lovePixels:calcOffset()
    local xgamearea = pixelWidth * lovePixels.maxScale
    local width = lovePixels.screenWidth
    local xblankspace = width - xgamearea

    local ygamearea = pixelHeight * lovePixels.maxScale
    local height = lovePixels.screenHeight
    local yblankspace = height - ygamearea

    lovePixels.xoffset = math.floor(xblankspace/2)
    lovePixels.yoffset = math.floor(yblankspace/2)

    if love.window.getFullscreen() == false then -- Don't care about offset if not fullscreen.
        lovePixels.xoffset = 0
        lovePixels.yoffset = 0
    end
end

-- This creates the Canvas we draw all assets on then scale up later.
function lovePixels:drawGameArea()
    love.graphics.setCanvas(lovePixels.mainCanvas)
    -- Draw Black Background to stop bleedthrough.
        love.graphics.setColor(pixelBlack)
        love.graphics.rectangle("fill", 0, 0, pixelWidth, pixelHeight)
        love.graphics.setColor(pixelWhite)
end

-- Stop drawing the canvas so we can take it and scale it.
function lovePixels:endDrawGameArea()
    love.graphics.setCanvas()
    love.graphics.setColor(pixelWhite) -- Has to be added to fix canvas fix in love 11.1
    love.graphics.draw(lovePixels.mainCanvas, 0 + lovePixels.xoffset , 0 + lovePixels.yoffset, 0, lovePixels.scale, lovePixels.scale)
end

-- Call this function to resize the screen with a new scale.
function lovePixels:resizeScreen(newScale)
    lovePixels.scale = newScale
    love.window.setMode(pixelWidth * lovePixels.scale, pixelHeight * lovePixels.scale, {fullscreen = false, resizable = true, highdpi = false})
end

-- pixelMouse watches where we click to match it with the scaled game area.
-- include in love.update if you use mouse in your game.
function lovePixels:pixelMouse()
    lovePixels.mousey = math.floor((love.mouse.getY() - lovePixels.yoffset)/lovePixels.scale)
    lovePixels.mousex = math.floor((love.mouse.getX() - lovePixels.xoffset)/lovePixels.scale)
    -- TODO: Full Screen
end

function lovePixels:fullscreenToggle()
    if love.window.getFullscreen() == false then
        lovePixels:resizeScreen(lovePixels.maxScale)
        love.window.setFullscreen(true, "desktop")
    else
        lovePixels:resizeScreen(math.floor(lovePixels.maxWindowScale))
        love.window.setFullscreen(false)
    end
end


function love.resize(w,h)
  print(w,h)
  if h ~= lovePixels.screenHeight or w ~= lovePixels.screenWidth then -- Cheap hack to allow full screen and resize
    if lovePixels.scale < math.floor(lovePixels.maxWindowScale)  then
      lovePixels:resizeScreen(lovePixels.scale + 1)
    else
      lovePixels:resizeScreen(1)
    end
  else

  end
end

print("lovePixels - Launch")
return lovePixels
