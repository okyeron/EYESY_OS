require("eyesy")

modeTitle = "circles"       -- name the mode

---------------------------------------------------------------------------
-- helpful global variables 
w = of.getWidth()           -- global width  
h = of.getHeight()          -- global height of screen
w2 = w / 2                  -- width half 
h2 = h / 2                  -- height half
w4 = w / 4                  -- width quarter
h4 = h / 4                  -- height quarter
w8 = w / 8                  -- width 8th
h8 = h / 8                  -- height 8th
w16 = w / 16                  -- width 16th
h16 = h / 16                  -- height 16th
c = glm.vec3( w2, h2, 0 )   -- center in glm vector

num=64

----------------------------------------------------
function setup()
    of.noFill()
	  bg = of.Color(0,0,0,0)
	  fg = of.Color()
    --mytimer = of.timer()
    startTime = of.getElapsedTimeMillis()
    bTimerReached = false
    position = 0.1
    speed = 60
    colorspeed = 120
    start = 0
    
   	knob1 = 0.0
   	knob2 = 1
   	knob4 = 0.5
   	knob5 = 0.5
    --of.setLineWidth(1)
    --------------------- define light
    myLight = of.Light()                -- define a light class
    myLight:setSpotlight(60, 1 )            -- we'll use a point light for this example
    --myLight:setSpotlightCutOff(.1)
  	myLight:setAmbientColor( of.FloatColor( 1, 1, 1 ) ) -- and make the ambient color white
  	myLight:setSpecularColor( of.FloatColor( 255, 255, 255 ) ) 
    myLight:setPosition( c + glm.vec3(-h16,-h2,h) ) -- and set the position in the center with z closer

end

----------------------------------------------------
function update()
  --colorPickHsb( knob5, bg )
  of.setBackgroundColor( bg )

    elapsed = of.getElapsedTimeMillis() - startTime;
    if (elapsed >= speed and not bTimerReached) then
        bTimerReached = true       
        startTime = of.getElapsedTimeMillis()
        position = position + 0.01;
        colorCycle( start, saturation, fg ) 
         
        if position > 1 then
          position = 0
        end
    else 
      bTimerReached = false
    end
    
--    myLight:setPosition( c + glm.vec3(-h16,-h2,h*knob4) ) -- and set the position in the center with z closer
    
end

function colorCycle(startHue, sat, name) -- startHue is 0-255
    hue = (startHue + 0.5) % 255  
    start = hue 
    name:setHsb(hue, sat, 255 )
end

----------------------------------------------------
function draw()
    -- OSD
    osd.osd_button (osd_state)
      
    amplitude = 1000 + knob3*4000   
    
    
    --of.setLineWidth(knob4 * 10+1)   

    of.noFill()
    
    of.pushMatrix()

    of.translate(w/2, h/2)

    of.rotateXDeg(knob1*180)
--    of.rotateYDeg(knob2*180)
--    of.rotateXDeg(position*2*180)
    of.rotateYDeg(position*2*180)

    of.enableLighting()             -- enable lighting globally
    of.enableDepthTest()            -- enable 3D rendering globally
    of.enableAlphaBlending()
    myLight:enable()                -- begin rendering for myLight


    ringoffset = 360/num
    offset = 256/num
    for i=1,num do
        audioR = math.abs(inR[ i * (256/num)] )
        audioL = math.abs(inL[ i * (256/num)] )
        saturation = 255 - math.abs(inL[i] * 255 )*2
--        print(saturation)
--        colorPickHsb( knob5 + elapsed/100 + position/4, fg )

        of.setColor( fg )
        of.noFill()

        x = w4 * knob2
        y = 0
        z = 0
        boxStart = 100 * knob4
        xangle = 180 * knob5
        rad = boxStart + inR[i*offset]*amplitude/10 
        of.pushMatrix()
        of.rotateXDeg(xangle-90)
        of.drawRectangle( glm.vec3( x, y, z), rad, rad) 
        fg:invert()
        of.drawRectangle( glm.vec3( -x, -y, z), -rad, -rad) 
        fg:invert()
        of.popMatrix()
--        of.rotateXDeg(30)
        of.rotateYDeg(ringoffset)
      
    end

--    for i=1,num do
--        audioR = math.abs(inR[ i * (256/num)] )
--        audioL = math.abs(inL[ i * (256/num)] )
--        colorPickHsb( knob5 + elapsed/50 + position/2, fg )
----        colorPickHsb( knob5, fg )
--        of.setColor( fg )
--        of.noFill()
----        of.setCircleResolution(100)
--        x = 0
--        y = h8
--        z = 0
--        rad = 60 + inL[i*offset]*amplitude/20 
--        of.drawRectangle( glm.vec3( x, y, z), rad, rad) 
--        of.rotateXDeg(ringoffset)
----        of.rotateYDeg(ringoffset)
--    end

    myLight:disable()               -- end rendering for myLight
    of.disableLighting()            -- disable lighting globally
    
    of.popMatrix()

end

----------------------------------------------------
function draw3DScope(a, b, amplitude, axis, vertices)
    local stepx = (b.x - a.x) / vertices--256 max vertices
    local stepy = (b.y - a.y) / vertices--256 max vertices
    local stepz = (b.z - a.z) / vertices--256 max vertices
    of.beginShape()
    for i=1,vertices do
        if axis == 1 then
            of.vertex(a.x + stepx*i + inL[i]*amplitude, a.y + stepy*i, a.z + stepz*i)
        end
        if axis == 2 then
            of.vertex(a.x + stepx*i, a.y + stepy*i + inL[i]*amplitude, a.z + stepz*i)
        end
        if axis == 3 then
            of.vertex(a.x + stepx*i, a.y + stepy*i, a.z + stepz*i + inL[i]*amplitude)
        end
    end
    of.endShape()
end

------------------------------------ Color Function
-- this is how the knobs pick color
function colorPickHsb( knob, name )
	-- middle of the knob will be bright RBG, far right white, far left black
	
	k6 = (knob * 5) + 1						-- split knob into 8ths
	hue = (k6 * 255) % 255 
	kLow = math.min( knob, 0.49 ) * 2		-- the lower half of knob is 0 - 1
	kLowPow = math.pow( kLow, 2 )
	kH = math.max( knob, 0.5 ) - 0.5	
	kHigh = 1 - (kH*2)						-- the upper half is 1 - 0
	kHighPow = math.pow( kHigh, 0.5 )
	
	bright = kLow * 255						-- brightness is 0 - 1
	sat = kHighPow * 255					-- saturation is 1 - 0
	
	name:setHsb( hue, sat, bright )			-- set the ofColor, defined above
end


----------------------------------------------------
function exit()
	print("script finished")
end