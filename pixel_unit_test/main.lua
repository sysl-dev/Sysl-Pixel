gscreen = require('lib.sysl.pixel')
gscreen.load(4)

local test_font = love.graphics.newFont( 9, "mono")
love.graphics.setFont(test_font)


--[[ Scene Start ]]------------------------------------------------------------------
local scene = {
  debug = false,
}

local base = {
  width = love.graphics.getWidth()/gscreen.scale,
  height = love.graphics.getHeight()/gscreen.scale,
}

-- Scene Locals
local timer_animation = 0
local timer_wobble = 0
local drawing_mode = 1

local mode_name = {
"Module Information",
"Scaling Window",
"Scaling Image",
"Capture Screen",
"Full Screen Shader",
"Mouse Control",
}

-- Scene Local Functions
local function tri_up(x,y)
  x = x or 0
  y = y or 0
love.graphics.polygon('fill', 0+x, 0+y, 3+x, 3+y, -3+x, 3+y)
end

local function tri_down(x,y)
  x = x or 0
  y = y or 0
love.graphics.polygon('fill', 0+x, 0+y, 6+x, 0+y, 3+x, 3+y)
end

local function tri_left(x,y)
  x = x or 0
  y = y or 0
love.graphics.polygon('fill', 0+x, 0+y, 3+x, -3+y, 3+x, 2+y)
end

local function tri_right(x,y)
  x = x or 0
  y = y or 0
  love.graphics.polygon('fill', 6+x, 0+y, 3+x, -3+y, 3+x, 2+y)
end

-- Test Image 
local _test_image = love.image.newImageData(16,16)
for i = 0, 15 do
    _test_image:setPixel(i, 0, 1, .2, .2, 1) 
    _test_image:setPixel(0, i, .2, .2, 1, 1)
    _test_image:setPixel(9, i, .2, 1, .2, 1) 
    _test_image:setPixel(i, 9, 1, 1, .2, 1)
    _test_image:setPixel(i, i, 1, .2, 1, 1)
end
local _img = love.graphics.newImage(_test_image)

-- Test Particle System 
local psmog = love.graphics.newParticleSystem(_img, 32)
    	psmog:setParticleLifetime(3, 7)
    	psmog:setEmissionRate(25)
    	psmog:setSizes(1,1,2,2,0.5,0.5,1,1)
    	psmog:setSizeVariation(0)
    	psmog:setLinearAcceleration(0, 0, 500, 5)
    	psmog:setColors(1, 1, 1, 1)

-- Test Shaders

local ts1 = love.graphics.newShader([[
	extern number dt = 0.2;
	vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
	{
		vec2 pixel_position = texture_coords;
		vec2 p = vec2(floor(gl_FragCoord.x), floor(gl_FragCoord.y));
		float direction = 2 * (float(mod(p.y, 2.0) == 0.0)) + -1;
		float pixel_alt = sin(pixel_position.y * 8 + dt) * 0.04;
		pixel_position.x = pixel_position.x + (pixel_alt * direction);
		return Texel(texture, pixel_position) * color;
		}
]])

local ts2 = love.graphics.newShader[[
  vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
  {
    vec4 col = Texel(texture, texture_coords);
    col.r = 1 - col.r;
    col.g = 1 - col.g;
    col.b = 1 - col.b;
    return col * color;
  }
  ]]

  local ts3 = love.graphics.newShader[[
  vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
  {
    vec4 col = Texel(texture, texture_coords);
    float z = (col.r + col.g + col.b)/3;
    col.r = z;
    col.g = z;
    col.b = z;
    return col * color;
  }
  ]]


-- Buttons
local function draw_button(x,y,t)
  x = x or 0
  y = y or 0
  t = t or tri_up
  local button_width = love.graphics.getFont():getWidth(mode_name[drawing_mode])
  local button_height = 8
  local brighter = 0
  if gscreen.mouse_over(x,y, button_width+2, button_height+2) then 
    brighter = 0.1
    if love.mouse.isDown(1) then
      brighter = 0.2
    end
  end
  love.graphics.setColor(0.1+brighter,0.1+brighter,0.1+brighter,1)
  love.graphics.rectangle("fill", x, y, button_width+2, button_height+2)
  love.graphics.setColor(0.15+brighter,0.15+brighter,0.15+brighter,1)
  love.graphics.rectangle("fill", x, y, button_width+1, button_height+1)
  love.graphics.setColor(0.125+brighter,0.125+brighter,0.125+brighter,1)
  love.graphics.rectangle("fill", x+1, y+1, button_width, button_height)
  love.graphics.setColor(1,1,1,1)
  if t == tri_up then x = x + 3 end
  t(x + button_width/2,y+button_height/2)
end

local function draw_button_scale(text,x,y,w,h)
  x = x or 0
  y = y or 0
  w = w or 15
  h = h or 15
  local button_width = w
  if type(w) == "string" then 
    button_width = love.graphics.getFont():getWidth(text) + 1
  end
  local button_height = h
  local brighter = 0
  if gscreen.mouse_over(x,y, button_width+2, button_height+2, nil, nil, 1, 1) then 
    brighter = 0.1
    if love.mouse.isDown(1) then
      brighter = 0.2
    end
  end
  love.graphics.setColor(0.1+brighter,0.1+brighter,0.1+brighter,1)
  love.graphics.rectangle("fill", x, y, button_width+2, button_height+2)
  love.graphics.setColor(0.15+brighter,0.15+brighter,0.15+brighter,1)
  love.graphics.rectangle("fill", x, y, button_width+1, button_height+1)
  love.graphics.setColor(0.125+brighter,0.125+brighter,0.125+brighter,1)
  love.graphics.rectangle("fill", x+1, y+1, button_width, button_height)
  love.graphics.setColor(1,1,1,1)
  love.graphics.printf(text, x + 2, y+2, button_width, "center")
end

local function change_mode(updown)
  if updown == 1 then 
    if drawing_mode < #mode_name then 
      drawing_mode = drawing_mode + 1 
    else 
      drawing_mode = 1 
    end
  else 
    if drawing_mode > 1 then 
      drawing_mode = drawing_mode - 1 
    else 
      drawing_mode = #mode_name 
    end
  end

end

local scene_buttons = {}
local function update_buttons()
  scene_buttons = {
    --x,y,function 
    {base.width - love.graphics.getFont():getWidth(mode_name[drawing_mode])-3, base.height-11, tri_down, function() change_mode(false) update_buttons() end},
    {base.width - love.graphics.getFont():getWidth(mode_name[drawing_mode])-3, base.height-35, tri_up, function() change_mode(1) update_buttons() end},
    }
end update_buttons()

local size_buttons = {
  -- text, x, y, width, function
{"Fullscreen", 10, 10, base.width-20, function() gscreen.toggle_fullscreen() end},
}
for i=1, gscreen.maxWindowScale do 
  local astring = i .. "x - " .. (gscreen.base_width() * i) .. "x" .. (gscreen.base_height() * i)
  size_buttons[#size_buttons+1] = {astring, 10, 10+i*17, base.width-20, function() gscreen.set_game_scale(i) end}
end

local canvas_buttons = {
  -- text, x, y, width, function
{"Screenshot", 10, 10, base.width-20, function() gscreen.capture_canvas()  end},
{"Erase Screenshot", 10, 10+1*17, base.width-20, function() gscreen.remove_capture()  end},
}

local shader_buttons = {
  -- text, x, y, width, function
{"Push Split-Wave", 10, 10, base.width-20, function()  gscreen.push_shader(ts1) end},
{"Push Invert", 10, 10+1*17, base.width-20, function() gscreen.push_shader(ts2)  end},
{"Push Greyscale", 10, 10+2*17, base.width-20, function() gscreen.push_shader(ts3)  end},
{"Pop Last Shader", 10, 10+3*17, base.width-20, function() gscreen.pop_shader()  end},
{"Remove All Shaders", 10, 10+4*17, base.width-20, function() gscreen.clear_all_shader()  end},
{"Draw Frame After Shaders Are Applied", 10, 10+5*17, base.width-20, function() gscreen.change_draw_after_shader(function() love.graphics.rectangle("line", 1,1,base.width-1,base.height-1) end) end},
{"Clear After Shader Drawing", 10, 10+6*17, base.width-20, function() gscreen.clear_draw_after_shader()  end},
}

local function rot_cursor()
  if gscreen.current_cursor < gscreen.get_cursor_count() then 
    gscreen.set_cursor(gscreen.current_cursor + 1)
  else 
    gscreen.set_cursor(1)
  end
end

local m_buttons = {
  -- text, x, y, width, function
{"Change Cursor", 10, 10, base.width-20, function() rot_cursor() end},
{"Toggle System Cursor", 10, 10+1*17, base.width-20, function() 
  gscreen.toggle_cursor()  
  if love.mouse.isVisible() then 
    gscreen.set_cursor(0)
  else 
    gscreen.set_cursor(1)
  end
end},
}

--[[ Draw Every Frame ]]--------------------------------------------------------------
function love.draw()
  gscreen.start()
  -- EVERYTHING DRAWN BELOW IS SCALED.

  -- Draw Grey Box so you can see possible borders around the full-screen game.
  love.graphics.setColor(0.2,0.2,0.2,1)
  love.graphics.rectangle("fill", 0, 0, base.width, base.height)
  love.graphics.setColor(1,1,1,1)

  if drawing_mode == 1 then 
    -- Scale Infographic
    love.graphics.rectangle("fill", 0, 10, base.width, 1)
    love.graphics.rectangle("fill", 10, 0, 1, base.height)
    tri_up(11,0)
    tri_down(8,base.height-3)
    tri_left(0,11)
    tri_right(base.width-6,11)
    tri_right(base.width-6,10)
    love.graphics.print(base.width, base.width-32, 10)
    love.graphics.print(base.height, 12, base.height-32)

    -- Mouse Position Information
    love.graphics.print("Pixel Mouse Position: " .. gscreen.mouse.x .. "X / " .. gscreen.mouse.y .. "Y", 12, 10 + 12 * 0)
    love.graphics.print("Real Mouse Position: " .. love.mouse.getX() .. "X / " .. love.mouse.getY() .. "Y", 12, 10 + 12 * 1)

    --Scale Information
    love.graphics.print("Scaling From: " .. gscreen.base_width() .. "x" .. gscreen.base_height(), 12, 10+12*2)
    love.graphics.print("Current Scale: " .. (gscreen.base_width() * gscreen.scale) .. "x" .. (gscreen.base_height() * gscreen.scale), 12, 10+12*3)
    love.graphics.print("Max Possble Scale: " .. gscreen.maxScale, 12, 10+12*4)
    love.graphics.print("Max Window Scale: " .. gscreen.maxWindowScale, 12, 10+12*5)
    love.graphics.print("Right Click to Shake Screen", 12, 10+12*6)
  end

  if drawing_mode == 2 then 
    for i=1, #size_buttons do 
      draw_button_scale(size_buttons[i][1], size_buttons[i][2], size_buttons[i][3], size_buttons[i][4])
    end
  end

  if drawing_mode == 3 then 
    love.graphics.print("Rotation and Scale Test:", 10, 10)
    love.graphics.draw(_img, 10,50+00, 0, 1, 1, 8, 8)
    love.graphics.draw(_img, 30,50+00, math.sin(timer_animation), 1, 1, 8, 8)
    love.graphics.draw(_img, 50,50+00, math.sin(timer_animation)*4, 1, 1, 8, 8)
    love.graphics.draw(_img, 70,50+00, math.sin(timer_animation)*8, 1, 1, 8, 8)
    love.graphics.draw(_img, 90,50+00, 0, 1, 2, 8, 8)
    love.graphics.draw(_img, 120,50+00, 0, 2, 1, 8, 8)
    love.graphics.draw(_img, 160,50+00, 0, math.sin(timer_animation*5), math.sin(timer_animation*5), 8, 8)
    love.graphics.print("Particle System Test:", 10, 80)
    love.graphics.draw(psmog, 10, 120)
  end

  if drawing_mode == 4 then 
    for i=1, #canvas_buttons do 
      draw_button_scale(canvas_buttons[i][1], canvas_buttons[i][2], canvas_buttons[i][3], canvas_buttons[i][4])
    end
    love.graphics.printf("Scaled Image (Hover to see full size)", 0, 50, 320, "center")
    love.graphics.rectangle("line", 80, 70, base.width/2+1, base.height/2+1)
    if gscreen.mouse.y >= 70 then 
      gscreen.draw_capture(nil, 0, 0, 0, 1, 1)
    else 
      gscreen.draw_capture(nil, 80, 70, 0, 0.5, 0.5)
    end
  end
  if drawing_mode == 5 then 
    love.graphics.print("Shader Count: " .. gscreen.count_shader(), 10, 149)
    love.graphics.setColor(1,0,0,1)
    love.graphics.rectangle("fill", 0, 160, base.width, 4)
    love.graphics.setColor(0,1,0,1)
    love.graphics.rectangle("fill", 0, 164, base.width, 4)
    love.graphics.setColor(0,0,1,1)
    love.graphics.rectangle("fill", 0, 168, base.width, 4)
    love.graphics.setColor(1,1,1,1)
    for i=1, #shader_buttons do 
      draw_button_scale(shader_buttons[i][1], shader_buttons[i][2], shader_buttons[i][3], shader_buttons[i][4])
    end
  end

  if drawing_mode == 6 then 
    for i=1, #m_buttons do 
      draw_button_scale(m_buttons[i][1], m_buttons[i][2], m_buttons[i][3], m_buttons[i][4])
    end
  end

  -- UI Controls
  for i=1, #scene_buttons do 
    draw_button(scene_buttons[i][1], scene_buttons[i][2], scene_buttons[i][3])
  end

  -- Scene Title
  love.graphics.printf(mode_name[drawing_mode],0,base.height-24,base.width-2,"right")


  -- EVERYTHING DRAWN ABOVE IS SCALED.
  gscreen.stop(math.sin(timer_wobble)*2,-math.sin(timer_wobble)*2,math.sin(timer_wobble), math.sin(timer_wobble*5), math.sin(timer_wobble*10))
end

--[[ Update Every Frame ]]------------------------------------------------------------
local input_pause = false
local pause_timer = 0.1
function love.update(dt)
  -- Update Pixels 
    gscreen.update(dt)

  -- Love2D sometimes causes mouse to be stuck 'down' when changing screen size 
  -- this *tries* to stop it from going wild.
  if input_pause then 
    if pause_timer >= 0 then 
      pause_timer = pause_timer - dt
    else 
      input_pause = false
    end
  end 

  -- Particle System Update 
  psmog:update(dt)

  -- Update Animation Timer 
  timer_animation = timer_animation + dt

  -- Update Shake Timer 
  timer_wobble = timer_wobble - dt 
  if timer_wobble <= 0 then 
    timer_wobble = 0
  end

end

--[[ Run on a Key Pressed ]]-----------------------------------------------------------
function  scene:keypressed(key, scancode, isrepeat)

end

--[[ Run on a Key Released ]]----------------------------------------------------------
function  scene:keyreleased(key, scancode)

end

--[[ Run on a Mouse Pressed ]]---------------------------------------------------------
function  love.mousepressed(x, y, button, istouch, presses)
  for i=1, #scene_buttons do 
    if gscreen.mouse_over(scene_buttons[i][1], scene_buttons[i][2],love.graphics.getFont():getWidth(mode_name[drawing_mode])+2, 8+2) then
    scene_buttons[i][4]()
    end
  end

  if drawing_mode == 1 then 
    if button == 2 then 
      timer_wobble = 1
    end
  end

  if drawing_mode == 2 then 
    for i=1, #size_buttons do 
      if gscreen.mouse_over(size_buttons[i][2], size_buttons[i][3], base.width-20, 15+2) then
        -- Love2D sometimes causes mouse to be stuck 'down' when changing screen size 
        -- this *tries* to stop it from going wild.
        if not input_pause then
          size_buttons[i][5]()
          input_pause = true 
          pause_timer = 0.1
          gscreen.mouse.x = -10
          gscreen.mouse.y = -10
          break
        end
      end
    end      
  end

  if drawing_mode == 4 then 
    for i=1, #canvas_buttons do 
      if gscreen.mouse_over(canvas_buttons[i][2], canvas_buttons[i][3], base.width-20, 15+2) then
        -- Love2D sometimes causes mouse to be stuck 'down' when changing screen size 
        -- this *tries* to stop it from going wild.
        if not input_pause then
          canvas_buttons[i][5]()
          input_pause = true 
          pause_timer = 0.1
          gscreen.mouse.x = -10
          gscreen.mouse.y = -10
          break
        end
      end
    end      
  end

  if drawing_mode == 5 then 
    for i=1, #shader_buttons do 
      if gscreen.mouse_over(shader_buttons[i][2], shader_buttons[i][3], base.width-20, 15+2) then
        -- Love2D sometimes causes mouse to be stuck 'down' when changing screen size 
        -- this *tries* to stop it from going wild.
        if not input_pause then
          shader_buttons[i][5]()
          input_pause = true 
          pause_timer = 0.1
          gscreen.mouse.x = -10
          gscreen.mouse.y = -10
          break
        end
      end
    end      
  end

  if drawing_mode == 6 then 
    for i=1, #m_buttons do 
      if gscreen.mouse_over(m_buttons[i][2], m_buttons[i][3], base.width-20, 15+2) then
        -- Love2D sometimes causes mouse to be stuck 'down' when changing screen size 
        -- this *tries* to stop it from going wild.
        if not input_pause then
          m_buttons[i][5]()
          input_pause = true 
          pause_timer = 0.1
          gscreen.mouse.x = -10
          gscreen.mouse.y = -10
          break
        end
      end
    end      
  end

end


--[[ Return Scene ]]--------------------------------------------------------------------
return scene
