function load()
	love.filesystem.include "Console.lua"
	message = "nobody's here"
	love.filesystem.include "Client.lua"
	love.filesystem.include "Server.lua"
	message = "doing nothing"
	remoteMessage = ""
	font = love.graphics.newFont(love.default_font, 12)
	love.graphics.setFont(font)
	g_console = Console:new()
	g_console:init()
end

function draw()
	love.graphics.draw(message, 100, 300)
	love.graphics.draw('someone:' .. ' ' .. remoteMessage,100,350)
	g_console:draw()
end

function update(dt)
	client:update()
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

function connectCallback()
	message = "connected"
end

function recCallback()
	message = "recieved message"
end

function disconnectCallback()
	message = "disconnected"
end

function initClient()
	client:Init(26001)
	client:setCallback(recCallback,connectCallback,disconnectCallback)
	client:setHandshake("hello")
	client:connect('72.90.113.69',26001)
	client:send("hello!")
	message = "client started"
end

function initServer()
	server:Init(26001)
	server:setCallback(recCallback,connectCallback,disconnectCallback)
	server:setHandshake("hello")
	server:send("hello!")
	message = "server started"
end