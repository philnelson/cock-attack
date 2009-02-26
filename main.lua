function load()
	role = "none"
	message = "nobody's here"
	remoteMessage = ""
	yourMessage = ""
	status = "not connected"
	
	love.filesystem.include "Console.lua"
	love.filesystem.include "Client.lua"
	love.filesystem.include "Server.lua"
	font = love.graphics.newFont(love.default_font, 12)
	love.graphics.setFont(font)
	g_console = Console:new()
	g_console:init()
end

function draw()
	love.graphics.draw(message, 100, 300)
	love.graphics.draw('someone:' .. ' ' .. remoteMessage,100,350)
	love.graphics.draw('you:' .. ' ' .. yourMessage,100,400)
	love.graphics.draw(role .. ' : ' .. status,5,590)
	g_console:draw()
end

function update(dt)
	if role == "server" then server:update();
	elseif role == "client" then client:update();
	end
	g_console:update(dt)
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

function connectCallback(data)
	status = "connected"
end

function recCallback(data)
	message = "recieved message"
	
end

function disconnectCallback(data)
	status = "disconnected"
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
	client:setCallback(recCallback(data))
	client:setHandshake("hello")
	client:connect(ip,26001)
	client:send("hello!")
	message = "client started"
	role = "client"
end

function initServer()
	server:Init(26001)
	server:setCallback(recCallback(data),connectCallback(data),disconnectCallback(data))
	server:setHandshake("hello")
	server:send("hello!")
	message = "server started"
	role = "server"
end