function load()
	love.filesystem.include "Console.lua"
	love.filesystem.include "Client.lua"
	love.filesystem.include "Server.lua"

	role = "none"
	message = "nobody's here"
	remoteMessage = ""
	yourMessage = ""
	status = "not connected"
	hasExited = 'yes'
	menuItems = {}
	shifter_position = 3
	
	font = love.graphics.newFont(love.default_font, 14)
	coolfont = love.graphics.newFont('fonts/orange-kid.ttf', 18)
	menufont = love.graphics.newFont('fonts/orange-kid.ttf', 25)
	love.graphics.setFont(coolfont)
	
	battle_view_bg = love.graphics.newImage("images/battle_view_bg.png",2)
	big_logo = love.graphics.newImage("images/logo.png",2)
	metal_bg = love.graphics.newImage("images/grating-bg.png",2)
	main_menu_bg = love.graphics.newImage("images/main_menu.png",2)
	
	clicktostart = love.graphics.newAnimation( "images/clicktostart.png", 250, 50, .5, 2)
	
	shifter = love.graphics.newAnimation( "images/shifter_frames.png", 200, 236, 0, 0)
	
	background = metal_bg
	
	--love.audio.setVolume(.2)
	--menu_effect_1 = love.audio.newSound('sound/menu_effect_1.ogg')
	--menu_effect_2 = love.audio.newSound('sound/menu_effect_2.ogg')
	--menu_bg_music = love.audio.newSound('sound/COCK ATTACK.ogg')
	
	mainMenu()
	
	-- Default HUD colors
	player_head = love.graphics.newAnimation( "images/head_frames.png", 30, 30, 0, 0 )
	player_body = love.graphics.newAnimation( "images/body_frames.png", 100, 100, 0, 0 )
	player_l_arm = love.graphics.newAnimation( "images/arm_frames.png", 25, 50, 0, 0 )
	player_r_arm = love.graphics.newAnimation( "images/arm_frames.png", 25, 50, 0, 0 )
	player_l_leg = love.graphics.newAnimation( "images/leg_frames.png", 10, 25, 0, 0 )
	player_r_leg = love.graphics.newAnimation( "images/leg_frames.png", 10, 25, 0, 0 )
	playerData = {head = 0, l_arm=0, r_arm=0, body=0, l_leg=0, r_leg=0}
	
	cpu_head = love.graphics.newAnimation( "images/head_frames.png", 30, 30, 0, 0 )
	cpu_body = love.graphics.newAnimation( "images/body_frames.png", 100, 100, 0, 0 )
	cpu_l_arm = love.graphics.newAnimation( "images/arm_frames.png", 25, 50, 0, 0 )
	cpu_r_arm = love.graphics.newAnimation( "images/arm_frames.png", 25, 50, 0, 0 )
	cpu_l_leg = love.graphics.newAnimation( "images/leg_frames.png", 10, 25, 0, 0 )
	cpu_r_leg = love.graphics.newAnimation( "images/leg_frames.png", 10, 25, 0, 0 )
	cpuData = {head = 0, l_arm=0, r_arm=0, body=0, l_leg=0, r_leg=0}
	
	g_console = Console:new()
	g_console:init()
end

function draw()
	love.graphics.draw(background,400,300)
	--love.graphics.draw(hasExited, 100, 300)
	--love.graphics.draw('someone:' .. ' ' .. remoteMessage,100,350)
	--love.graphics.draw('you:' .. ' ' .. yourMessage,100,400)
	--love.graphics.draw(role .. ' : ' .. status,5,590)
	
	if screen == "main menu" then
		--love.audio.play(menu_bg_music,1)
		love.graphics.draw(big_logo,250, 70)
		
		love.graphics.setColor(255, 255, 255 )
		love.graphics.setFont(menufont)
		love.graphics.setColor(255,255,255 )
		love.graphics.draw(clicktostart, 400, 333)
		love.graphics.setFont(coolfont)
	end
	
	if screen == "cpu battle" then
		love.graphics.rectangle(1,174,14,601,401)
		love.graphics.draw(battle_view_bg,475,215)
	
		love.graphics.draw(player_body, 80, 85)
		love.graphics.draw(player_head, 80, 25)
		love.graphics.draw(player_l_arm, 30, 70)
		love.graphics.draw(player_r_arm, 130, 70)
		love.graphics.draw(player_l_leg, 65, 140)
		love.graphics.draw(player_r_leg, 90, 140)
		
		love.graphics.draw(cpu_body, 500, 200)
		love.graphics.draw(cpu_head, 500, 140)
		love.graphics.draw(cpu_l_arm, 450, 185)
		love.graphics.draw(cpu_r_arm, 550, 185)
		love.graphics.draw(cpu_l_leg, 485, 255)
		love.graphics.draw(cpu_r_leg, 510, 255)
		
		player_head:seek(playerData.head)
		player_body:seek(playerData.body)
		player_l_arm:seek(playerData.l_arm)
		player_r_arm:seek(playerData.r_arm)
		player_l_leg:seek(playerData.l_leg)
		player_r_leg:seek(playerData.r_leg)
		
		cpu_head:seek(cpuData.head)
		cpu_body:seek(cpuData.body)
		cpu_l_arm:seek(cpuData.l_arm)
		cpu_r_arm:seek(cpuData.r_arm)
		cpu_l_leg:seek(cpuData.l_leg)
		cpu_r_leg:seek(cpuData.r_leg)
		
		love.graphics.draw(shifter, 120, 460)
		shifter:seek(shifter_position)
		
	end
	
	g_console:draw()
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
	if screen == "main menu" then
		clicktostart:update(dt) 
	end

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
	
	if screen == "cpu battle" then
		if key == love.key_1 then
			playerData.head = 0
		end
		if key == love.key_2 then
			playerData.head = 1
		end
		if key == love.key_3 then
			playerData.head = 2
		end
	end
	
end

function mousereleased(mx, my, button)
	if button == love.mouse_left then 
		if screen == "main menu" then
			cpuBattleScreen()
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