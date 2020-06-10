# SYSL-Pixel
SYSL-Pixels is a pixel-art focused screen scaling module for Love2d.

## Important Information
SYSL-Pixel will modify the following global Love2D Settings if ```apply_global_scaling_changes``` is enabled. 
```Lua
love.graphics.setDefaultFilter("nearest", "nearest", 1)
love.graphics.setLineStyle("rough")
```
This will force all graphics added after SYSL-Pixel (Pixel) is loaded to use nearest scaling, and all shapes to use the rough line style.

## Configuration
* **allow_window_resize**
	* Default: false
	* Allows the user to resize the window from the system window manager. Disabled by default due to issues with some Linux window managers. Reccomened to test with people before using.
* **apply_global_scaling_changes**
	* Default: true
	* See the Important Information above.
* **pixel_perfect_fullscreen**
	*  Default: false
	* Forces scaling, even when in full-screen view to be interger scaled. Defaults to off to avoid black borders all around the game content instead of just to the sides or above/below.
* **m.current_cursor**
	*  Default: 1
	*  The graphical cursor to use, if you are using the operation system (OS) cursor, set it to 0.
* **m.show_system_cursor_startup**
	* Default: false 
	* Show or Hide the OS Cursor on game load.

## Cursor Table Format
Path to Image (String) | -X Offset (Int) | -Y Offset (Int)
-|-|-
Example|From|Module
'assets/cursor1.png' | 0 | 0
'assets/cursor2.png' | -8 | -8
'assets/cursor3.png' | -16 | -6

## Using the Module
**conf.lua requirements**
```lua
function love.conf(t)
--Snip
t.window.width = 320 -- Base Width that we scale up.
t.window.height = 180 -- Base Height that we scale up.
t.window.resizable = false -- Controled though allow_window_resize, set false in conf.
t.window.minwidth = 320 -- Should match Width
t.window.minheight = 180 -- Should match Height
--Snip
end
```

Loading the Module
```lua
-- Assumes you store your modules under a folder called lib, update path as required.
gscreen = require('lib.sysl.pixel')
gscreen.load(4) -- Draw at 4x Size.
```

In love.draw()
```lua
function love.draw()
  gscreen.start()
  -- EVERYTHING DRAWN BELOW IS SCALED.
  love.graphics.rectangle("fill", 1,1,1,1) -- Things drawn will scale.
  -- EVERYTHING DRAWN ABOVE IS SCALED.
  gscreen.stop()
  -- Things drawn here will *not* scale.
end
```

In love.update()
```lua
function love.update(dt)
-- Update Pixel
   gscreen.update(dt)
end
```

## Module Functions

### Screen Scaling

#### gscreen.set_game_scale(int)
Set the game scale to the window.width/window.height * your scale. Used to resize the window.

#### gscreen.toggle_fullscreen()
Toggles between full-screen and windowed mode. When returning from full-screen, it will return to the largest possible full-screen window.

### Pixel Mouse

#### gscreen.toggle_cursor()
Toggles the OS Cursor on and off.

#### gscreen.force_cursor(bool)
True/False, enable/disable the system cursor.

#### gscreen.set_cursor(int)
Set the graphical cursor to one of your cursors defined in the cursor table. 

#### gscreen.get_cursor_count()
Returns the number of cursors in the cursor table.

#### gscreen.mouse_over(int_x, int_y, int_width, int_height)
Check to see if the pixel mouse is in an area. Default mouse area is 1x1, see module if you need to make changes.

### Full Screen Shader

#### gscreen.push_shader(love_shader)
Push a shader to Pixel's shader stack to apply to the screen.

#### gscreen.pop_shader()
Remove the last shader added to the shader stack.

#### gscreen.clear_all_shader()
Clear all shaders applied to the screen.

#### gscreen.count_shader()
Count the number of shaders applied to the screen.

#### gscreen.change_draw_after_shader(function)
Do this function after shaders are applied. Useful for drawing a frame, or other information after the shader.

#### gscreen.clear_draw_after_shader()
Clear the function that was set by you in the function above.

### Screenshot Tools

#### gscreen.capture_canvas(string)
Capture the current screen, store it as a image for use later. *Does not last past the game closing*

#### gscreen.flush_capture()
Erase all captures.

#### gscreen.remove_capture(string)
Remove a capture that you took.

#### gscreen.check_capture(string)
Check if a capture exists.

#### gscreen.draw_capture(string, ...)
Draw a capture, checks to see if it exists first. Follows the format of love.graphics.draw() for arguments. 


### Bonus Notes
#### Using with HUMP-Camera
When attaching the camera, you'll have to pass along the scale information.
```camera:attach(0, 0, love.graphics.getWidth() / gscreen.scale, love.graphics.getHeight() / gscreen.scale, "noclip")```
#### Extra Scaling with gscreen.stop()
```gscreen.stop(hx, hy, hr, hsx, hsy)``` allows you to modify the canvas and adjust the scale. The arguements are as follows:
* X Postion
* Y Postion
* Rotation
* Scale X
* Scale Y

### Screenshots 
![Screenshot of Library](/screenshot/i1.png?raw=true)
![Screenshot of Library](/screenshot/i2.png?raw=true)
![Screenshot of Library](/screenshot/i3.png?raw=true)
![Screenshot of Library](/screenshot/i4.png?raw=true)
![Screenshot of Library](/screenshot/i5.png?raw=true)
![Screenshot of Library](/screenshot/i6.png?raw=true)


