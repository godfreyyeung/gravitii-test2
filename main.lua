-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here

-- start physics
local physics = require("physics")
physics.start()
physics.setGravity( 0, 0 ) -- set Gravity to none for both x and y
physics.setScale( 80 ) --  want a value greater or equal to 60 for large objects. play with this value. 
physics.setDrawMode( "hybrid")

tapped = false


--set up collision filters
local screenFilter = { categoryBits=2, maskBits=1 }
local objFilter = { categoryBits=1, maskBits=14 }
local fieldFilter = { categoryBits=4, maskBits=1 }
local magnetFilter = { categoryBits=8, maskBits=1 }

--set initial magnet pull

local function calculatePull (objAdensity, objAx, objAy, objBdensity, objBx, objBy, objBradius)
	local intermediate_x = objAx-objBx
	local intermediate_y = objAy-objBy
	local intermediate_distance = math.sqrt(math.pow( intermediate_x, 2 ) + math.pow( intermediate_y, 2 ))
	print(intermediate_distance)
	local force = (1 - (intermediate_distance/objBradius)) -- (1 - (intermediate_distance /100)) * 1.5 -- made up equation to simulate stronger pull nearer to planet lol
	-- local force = 1/(((objAdensity * objBdensity) / intermediate_distance)) -- actual newton's equation for force
	print(force)
	return force
end

-- calculatePull (100, 76, 20, 500, 75, 20)

-- handles collisions. takes in self?? event??
local function objectCollide( self, event )

	local otherName = event.other.name -- gets name of other object collided
	local otherobj = event.other
	
	local function onDelay( event )
		local action = ""
		if ( event.source ) then  -- if there is a timer
			action = event.source.action ; -- set the action string to the source's action
			timer.cancel( event.source ) -- cancel timer
		end
		
		-- local magnetPull = 0.20
		local magnetPull = calculatePull(100, self.x, self.y, 100, otherobj.x, otherobj.y, otherobj.radius+20) -- densities don't actually matter
		-- create a new joint if action set to "makeJoint"
		-- print(magnetPull)
		if ( action == "makeJoint" ) then
			self.hasJoint = true
			self.touchJoint = physics.newJoint( "touch", self, self.x, self.y )
			self.touchJoint.frequency = magnetPull -- frequency of joint becomes the "pull"
			self.touchJoint.dampingRatio = 0.0
			self.touchJoint:setTarget( otherobj.x, otherobj.y ) -- utb 512, 384.. strange.. it was statically set. I had to make magnet a global to access magnet.x / magnet.y I should just make global x and y vars for magnet, then set magnet x and y to those. 
		-- remove joint if action set to "leftField"
		elseif ( action == "leftField" ) then
			self.hasJoint = false ; self.touchJoint:removeSelf() ; self.touchJoint = nil
		-- otherwise, remove joints and respawn (when ball hits the edge of screen)
		else
			if ( self.hasJoint == true ) then self.hasJoint = false ; 
			self.touchJoint:removeSelf() ; self.touchJoint = nil 
			end
			-- newPositionVelocity( self ) -- this is being invoked when ball is leaving field...?
		end
	end

	-- if object has collided with screen bounds and collision has ENDED, then set action to leftScreen.
	if ( event.phase == "ended" and otherName == "screenBounds" ) then
		local tr = timer.performWithDelay( 10, onDelay ) ; 
		tr.action = "leftScreen"
	-- if object has just began colliding with the magnet (inside dark ball)
	elseif ( event.phase == "began" and otherName == "magnet" ) then
		-- transition.to( self, { time=400, alpha=0, onComplete=onDelay } ) -- fade out obj
	-- if object has just began colliding with the field and does not have a joint
	elseif ( event.phase == "began" and otherName == "field" and self.hasJoint == false ) then
		local tr = timer.performWithDelay( 10, onDelay ) ;  -- invoke onDelay after certain time
		tr.action = "makeJoint" -- set action to makeJoint, so onDelay will make a Joint
	-- if object has left the field and has a joint
	elseif ( event.phase == "ended" and otherName == "field" and self.hasJoint == true ) then
		local tr = timer.performWithDelay( 10, onDelay ) ; 
		tr.action = "leftField" -- onDelay will remove joint
	end

end



local background = display.newImageRect("background.jpg", display.contentWidth, display.contentHeight)
background.anchorX = 0 --odd.... image doesnt' scale without anchors.. why?
background.anchorY = 0

local planetGroup = display.newGroup( )

local planet1 = display.newImageRect(planetGroup, "g3_blueplanet.png", 75, 75)
planet1.x = 120
planet1.y = 150
planet1.name = "magnet"

local planet1field = display.newCircle( planet1.x, planet1.y, 80 ) -- newImageRect("field.png", 80, 80 )
planet1field.alpha = 0.0
planet1field.name = "field"
planet1field.radius = 200

local planet2 = display.newImageRect(planetGroup, "g3_redplanet.png", 75, 75)
planet2.x = 350
planet2.y = 305
planet1.name = "magnet"
planet2:rotate(-90)


local astronaut = display.newImageRect("astronaut_man.png", 15, 15)
astronaut.x = 260
astronaut.y = 460

physics.addBody(planet1, "static", 
	{radius=40, density=500, friction=.7, bounce=-100, filter=magnetFilter} )
physics.addBody( planet1field, "static", {isSensor=true, radius=planet1field.radius, filter=fieldFilter} )

physics.addBody( planet2, "static", 
	{radius=40, density=100, friction=.7, bounce=-100, filter=magnetFilter} )

physics.addBody( astronaut, "dynamic", {density=2, friction=.4, bounce=-100,filter=objFilter  } )
astronaut.hasJoint = false -- makes balls have no joint
astronaut.collision = objectCollide ; -- set collision property to be handled by objectCollide
astronaut:addEventListener( "collision", astronaut )  -- if object detects collision, invoke obj itself??

function screenTap()
	if tapped == false then
		astronaut:applyLinearImpulse( 0, -.05, astronaut.x, astronaut.y )
		tapped = true
	end
end

display.currentStage:addEventListener( "tap", screenTap )