local physics = require "physics"
physics.start()
physics.setGravity( 0, 100 )

local mydata = require( "mydata" )
local storyboard = require ("storyboard")
local scene = storyboard.newScene()

mydata.score = 0

function scene:createScene(event)

	local screenGroup = self.view

	local background = display.newImage("bg.png")
	screenGroup:insert(background)

    bg = display.newImageRect('bg.png',900,1425)
	bg.anchorX = 0
	bg.anchorY = 1
	bg.x = 0
	bg.y = display.contentHeight
	bg.speed = 4
	screenGroup:insert(bg)
    
    elements = display.newGroup()
	elements.anchorChildren = true
	elements.anchorX = 0
	elements.anchorY = 1
	elements.x = 0
	elements.y = 0
	screenGroup:insert(elements)

	ground = display.newImageRect('ground.png',900,162)
	ground.anchorX = 0
	ground.anchorY = 1
	ground.x = 0
	ground.y = display.contentHeight
	screenGroup:insert(ground)

	platform = display.newImageRect('platform.png',900,53)
	platform.anchorX = 0
	platform.anchorY = 1
	platform.x = 0
	platform.y = display.viewableContentHeight - 110
	physics.addBody(platform, "static", {density=.1, bounce=0.1, friction=.2})
	platform.speed = 4
	screenGroup:insert(platform)

	platform2 = display.newImageRect('platform.png',900,53)
	platform2.anchorX = 0
	platform2.anchorY = 1
	platform2.x = platform2.width
	platform2.y = display.viewableContentHeight - 110
	physics.addBody(platform2, "static", {density=.1, bounce=0.1, friction=.2})
	platform2.speed = 4
	screenGroup:insert(platform2)
	
	p_options = 
	{
		-- Required params
		width = 80,
		height = 42,
		numFrames = 2,
		-- content scaling
		sheetContentWidth = 160,
		sheetContentHeight = 42,
	}

	playerSheet = graphics.newImageSheet( "bat.png", p_options )
	player = display.newSprite( playerSheet, { name="player", start=1, count=2, time=500 } )
	player.anchorX = 0.5
	player.anchorY = 0.5
	player.x = display.contentCenterX - 150
	player.y = display.contentCenterY
	physics.addBody(player, "static", {density=.1, bounce=0.1, friction=1})
	player:applyForce(0, -300, player.x, player.y)
	player:play()
	screenGroup:insert(player)
	
	scoreText = display.newText(mydata.score,display.contentCenterX,
	150, "pixelmix", 58)
	scoreText:setFillColor(0,0,0)
	scoreText.alpha = 0
	screenGroup:insert(scoreText)
	
	instructions = display.newImageRect("instructions.png",400,328)
	instructions.anchorX = 0.5
	instructions.anchorY = 0.5
	instructions.x = display.contentCenterX
	instructions.y = display.contentCenterY
	screenGroup:insert(instructions)
	
end


function onCollision( event )
	if ( event.phase == "began" ) then
		storyboard.gotoScene( "restart" )	
	end
end

function platformScroller(self,event)
	
	if self.x < (-900 + (self.speed*2)) then
		self.x = 900
	else 
		self.x = self.x - self.speed
	end
	
end

local gameStarted = false

function flyUp(event)
   if event.phase == "began" then
		if gameStarted == false then
			 player.bodyType = "dynamic"
			 instructions.alpha = 0
			 scoreText.alpha = 1
			 addColumnTimer = timer.performWithDelay(1000, addColumns, -1)
			 moveColumnTimer = timer.performWithDelay(2, moveColumns, -1)
			 gameStarted = true
			 player:applyForce(0, -300, player.x, player.y)
		else 
       
	    player:applyForce(0, -600, player.x, player.y)

      end
	end
end



function moveColumns()
		for a = elements.numChildren,1,-1  do
			if(elements[a].x < display.contentCenterX - 170) then
				if elements[a].scoreAdded == false then

					mydata.score = mydata.score + 1
					scoreText.text = mydata.score
					elements[a].scoreAdded = true
				end
			end
			if(elements[a].x > -100) then
				elements[a].x = elements[a].x - 12
			else 
				elements:remove(elements[a])
			end	
		end
end

function addColumns()
	

	height = math.random(display.contentCenterY - 200, display.contentCenterY + 200)

	topColumn = display.newImageRect('topColumn.png',100,714)
	topColumn.anchorX = 0.5
	topColumn.anchorY = 1
	topColumn.x = display.contentWidth + 100
	topColumn.y = height - 160
	topColumn.scoreAdded = false
	physics.addBody(topColumn, "static", {density=1, bounce=0.1, friction=.2})
	elements:insert(topColumn)
	
	bottomColumn = display.newImageRect('bottomColumn.png',100,714)
	bottomColumn.anchorX = 0.5
	bottomColumn.anchorY = 0
	bottomColumn.x = display.contentWidth + 100
	bottomColumn.y = height + 160
	physics.addBody(bottomColumn, "static", {density=1, bounce=0.1, friction=.2})
	elements:insert(bottomColumn)

end	

local function checkMemory()
   collectgarbage( "collect" )
   local memUsage_str = string.format( "MEMORY = %.3f KB", collectgarbage( "count" ) )
   print( memUsage_str, "TEXTURE = "..(system.getInfo("textureMemoryUsed") / (1024 * 1024) ) )
end


function scene:enterScene(event)
	
	storyboard.removeScene("start")
	Runtime:addEventListener("touch", flyUp)

	platform.enterFrame = platformScroller
	Runtime:addEventListener("enterFrame", platform)

	platform2.enterFrame = platformScroller
	Runtime:addEventListener("enterFrame", platform2)
    
    Runtime:addEventListener("collision", onCollision)
   
   memTimer = timer.performWithDelay( 1000, checkMemory, 0 )

end

function scene:exitScene(event)

	Runtime:removeEventListener("touch", flyUp)
	Runtime:removeEventListener("enterFrame", platform)
	Runtime:removeEventListener("enterFrame", platform2)
	Runtime:removeEventListener("collision", onCollision)
	timer.cancel(addColumnTimer)
	timer.cancel(moveColumnTimer)
	timer.cancel(memTimer)
	
end

function scene:destroyScene(checkMemory)

end


scene:addEventListener("createScene", scene)
scene:addEventListener("enterScene", scene)
scene:addEventListener("exitScene", scene)
scene:addEventListener("destroyScene", scene)

return scene













