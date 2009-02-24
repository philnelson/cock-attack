function load()
	love.filesystem.load "Client.lua"
	font = love.graphics.newFont(love.default_font, 12)
	love.graphics.setFont(font)
	message = "Yharrr, Why hello thaarrrr!"
end

function draw()
	love.graphics.draw(message, 100, 100)
end