# lovePixel
lovePixel is a library that makes scaling your pixel work fast easy and painless. It uses the love.canvas function to scale
everything into a pixel perfect size to make it painless to do all work at a small scale.

# Usage
In love.load:
    lovePixels = require('library.lovepixels')
    lovePixels:load(2) -- Starting Scale

In love.update(dt)
    lovePixels:pixelMouse()
    lovePixels:calcOffset()

In love.draw() at the start:
    lovePixels:drawGameArea()


In love.draw() at the end:
    lovePixels:endDrawGameArea()

If you're using something like Hump.States library, include the DrawGameArea in all state:draws.

# Main.lua
Main.lua shows off examples of how to adjust the window size live, full screen, and how scaling will just work.

![image](https://i.imgur.com/6NSUM1V.png)
