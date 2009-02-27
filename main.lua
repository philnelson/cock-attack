function load()
	role = "none"
	message = "nobody's here"
	remoteMessage = ""
	yourMessage = ""
	status = "not connected"
	hasExited = 'yes'
	menuItems = {}
	love.filesystem.include "Console.lua"
	love.filesystem.include "Client.lua"
	love.filesystem.include "Server.lua"
	font = love.graphics.newFont(love.default_font, 14)
	coolfont = love.graphics.newFont('fonts/orange-kid.ttf', 18)
	menufont = love.graphics.newFont('fonts/orange-kid.ttf', 25)
	logofont = love.graphics.newFont('fonts/dirty bakers dozen.ttf', 50)
	love.graphics.setFont(coolfont)
	metal_bg = love.graphics.newImage("images/grating-bg.png")
	main_menu_bg = love.graphics.newImage("images/main_menu.png")
	background = metal_bg
	
	love.audio.setVolume(.2)
	menu_effect_1 = love.audio.newSound('sound/menu_effect_1.ogg')
	menu_effect_2 = love.audio.newSound('sound/menu_effect_2.ogg')
	menu_bg_music = love.audio.newSound('sound/COCK ATTACK.ogg')
	
	mainMenu()
	
	g_console = Console:new()
	g_console:init()
end

function draw()
	love.graphics.draw(background,400,300)
	--love.graphics.draw(hasExited, 100, 300)
	--love.graphics.draw('someone:' .. ' ' .. remoteMessage,100,350)
	--love.graphics.draw('you:' .. ' ' .. yourMessage,100,400)
	love.graphics.draw(role .. ' : ' .. status,5,590)
	
	if screen == "main menu" then
		--love.audio.play(menu_bg_music,1)
		love.graphics.setColor(0, 0, 0 )
		love.graphics.setFont(logofont)
		love.graphics.draw("C.O.C.K. ATTACK",25, 100)
		
		love.graphics.setColor(255, 255, 255 )
		love.graphics.setFont(menufont)
		love.graphics.setColor(74, 130, 230 )
		love.graphics.rectangle( 0, 400, 300, 300, 50 )
		love.graphics.setColor(255,255,255 )
		love.graphics.draw("Start Match .vs. CPU", 445, 333)
		
		love.graphics.setColor(74, 130, 230 )
		love.graphics.rectangle( 0, 400, 360, 300, 50 )
		love.graphics.setColor(255,255,255 )
		love.graphics.draw("Host A Game", 445, 393)
		
		love.graphics.setColor(74, 130, 230 )
		love.graphics.rectangle( 0, 400, 420, 300, 50 )
		love.graphics.setColor(255,255,255 )
		love.graphics.draw("Connect To Game", 445, 453)
		
		love.graphics.setFont(coolfont)
		menuTrigger(400, 300, 300, 50,menu_effect_1,cpuBattleScreen)
		menuTrigger(400, 360, 300, 50,menu_effect_2,startHostScreen)
		menuTrigger(400, 420, 300, 50,menu_effect_1,startClientScreen)
	end
	
	if screen == "cpu battle" then
		love.graphics.setColor(0,255,0)
		love.graphics.rectangle(1, 65, 20, 30, 30)
		love.graphics.rectangle(1, 30, 40, 100, 100)
		love.graphics.rectangle(1, 20, 60, 25, 50)
		love.graphics.rectangle(1, 115, 60, 25, 50)
		love.graphics.setColor(255,255,255 )
	end
	
	g_console:draw()
end

function menuTrigger(startx, starty, width, height, sound, callBack)
	menuItems[starty] = {x1=startx, y1=starty, x2=startx+width, y2=starty+height,callBack=callBack}
	if mousex >= startx then
		if mousex <= startx + width then
			if mousey >= starty then
				if mousey <= starty + height then
					love.graphics.rectangle(1, startx, starty, width, height)
					love.graphics.rectangle(1, startx-1, starty-1, width+1, height+1)
					if(hasExited == 'yes') then
					--	love.audio.play(sound,1)
						hasExited = 'no'
					end
					hasExited = 'no'
				else
					hasExited = 'yes'
				end
			else
				hasExited = 'yes'
			end
		else
			hasExited = 'yes'
		end
	else
		hasExited = 'yes'
	end
end

function mainMenu()
	screen = "main menu"
	background = main_menu_bg
end

function cpuBattleScreen()
	screen = "cpu battle"
	background = metal_bg
end

function update(dt)
	if role == "server" then server:update();
	elseif role == "client" then client:update();
	end
	g_console:update(dt)
	mousex, mousey = love.mouse.getPosition()
end

function keypressed(key)
	
	-- If you don't want the keys to get processed by your game when the console's down
	--  (at least in keypressed(), not so much love.keyboard.isDown()..) then you can 
	--  check if Console:keypressed() returns true (it returns false when the console
	--  is hidden)
	if g_console:keypressed(key) then
		return
	end
	
	-- Using key #96 (the tilde (~) key) as an example
	-- If you use something else, best to set Console.toggleKey to the new key code so
	--  that Console:keypressed() won't process it
	if key == love.key_backquote then
		g_console:toggle() -- Or if you'd like, g_console:display(true/false)
	end
end

function mousereleased(mx, my, button)
	if button == love.mouse_left then 
		if screen == "main menu" then
			for k,v in pairs(menuItems) do 
				cpuBattleScreen()
			end
		end
	end
end

function initBattle()
	
end

function connectCallback(ip, port)
	status = ip .. " is connected"
end

function recCallback(data,ip,port)
	message = "recieved message"
	remoteMessage = data
end

function disconnectCallback(ip, port)
	status = ip .. " disconnected"
end

function sendMessage(string)
	if role == "server" then server:send(string); yourMessage = string
	elseif role == "client" then client:send(string); yourMessage = string
	elseif role == "none" then message = "can't send message, you are not connected to anything"
	end
end

function stopNetworking()
	if role == "server" then message = "server stopped";
		elseif role == "client" then client:disconnect(); message = "client stopped";
		elseif role == "none" then message = "can't disconnect, you are not connected to anything";
	end
end

function initClient(ip)
	client:Init()
	client:setCallback(recCallback)
	client:setHandshake("hello")
	client:connect(ip,26001)
	client:send("hello!")
	message = "client started"
	role = "client"
end

function initServer()
	server:Init(26001)
	server:setCallback(recCallback,connectCallback,disconnectCallback)
	server:setHandshake("hello")
	server:send("hello!")
	message = "server started"
	role = "server"
end