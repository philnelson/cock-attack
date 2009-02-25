
-- Console.lua
-- A fairly simple console
-- Just in case some things change, i'm giving this an arbitrary version:
-- 0.512 (0.x because then i can blame anything on it having been an "early version")
-- zeddy

Console = {}
Console_mt = {}

function Console:new(consoleHeight)
 	-- defaults to 200px height
	consoleHeight = consoleHeight or 200
	
	newConsole = { height = consoleHeight, 
					width = 0, 				-- set in Console:init
					textHeight = 0, 		-- set in Console:init
					show = false,
					toggleKey = love.key_backquote, 	-- backquote == tilde key (~)
					curY = 0,
					numHistory = 20,		-- number of lines to keep above display
					textLines = {},
					inputField = "",
					inputHistory = {},
					inputHistoryPos = 0,
					cursorPos = 0, 		-- cursor position on input line
					linePos = 1,		-- the bottom line being drawn
					animating = false,
					animDelta = 0,
					animTime = 250, 		-- time (in ms) for console animation
					repeatKey = 0, 			-- for repeating some keys (cheap method)
					repeatKeyTime = 0,
					-- set backImage to nil if you don't want one to be drawn
					backImage = love.graphics.newImage(love.default_logo_256)
				}
	
	return setmetatable(newConsole, Console_mt)
end

Console_mt.__index = Console

-- Call this after you've setup the font and window
function Console:init()
	self.textHeight = love.graphics.getFont():getHeight()+love.graphics.getFont():getLineHeight()
	self.width = love.graphics.getWidth()
	self:print("--")
end

-- Probably want to call this at the end of your draw function so that
--  the console's drawn over everything else
-- The colours and things are here if you want to edit them
function Console:draw()
	if not self.show and not self.animating then
		return
	end
	
	-- Draw the console background
	if self.backImage ~= nil then
		love.graphics.setColor(200, 200, 250, 150) -- Background image colour
		love.graphics.draw(self.backImage, self.width/2, self.curY - self.height/2)
	end
	
	love.graphics.setColor(128, 128, 240, 150) -- Console colour
	love.graphics.quad(love.draw_fill, 0, self.curY-self.height, 0, self.curY, self.width, self.curY, self.width, self.curY-self.height)
	
	love.graphics.setColor(255, 255, 255, 255) -- Text colour
	love.graphics.quad(love.draw_line, 0, self.curY-self.height, 0, self.curY-1, self.width, self.curY-1, self.width, self.curY-self.height)
		
	-- Draw the text lines
	if self.linePos > #self.textLines then self.linePos = #self.textLines end
	
	local numLines = math.floor(self.height / self.textHeight)-1
	if numLines > self.linePos then numLines = self.linePos end
	
	local lineNum = 1
	for i=self.linePos-numLines+1, self.linePos, 1 do
		love.graphics.draw(self.textLines[i], 5, self.curY - self.textHeight*numLines - self.textHeight/2+1+ (lineNum-1)*self.textHeight)
		
		lineNum = lineNum + 1
	end
	
	-- Draw the input field
	love.graphics.line(0, self.curY-self.textHeight-2, self.width, self.curY-self.textHeight-2)
	love.graphics.draw(self.inputField, 5, self.curY - self.textHeight/2+self.textHeight*0.2)
	local cursorX = love.graphics.getFont():getWidth(string.sub(self.inputField, 1, self.cursorPos))
	love.graphics.line(cursorX+5, self.curY-self.textHeight-1, cursorX+5, self.curY-2)
end

-- Called in your update() function
-- Handles animation and repeating some keys
function Console:update(dt)

	if self.show and self.curY < self.height-1 and self.animating then --and self.animDelta < self.animTime+5 then
		local move = 0.5 * (-math.cos(self.animDelta/(self.animTime/math.pi))+1)
		if move > 1 then move = 1 end
		self.curY = (move)*self.height
		self.animDelta = self.animDelta + dt*1000
	elseif not self.show and self.curY > 1 and self.animating then --self.animDelta < self.animTime+5 then
		local move = 0.5 * (math.cos(self.animDelta/(self.animTime/math.pi))+1)
		self.curY = move*self.height
		self.animDelta = self.animDelta + dt*1000
	else
		self.animDelta = 0
		self.animating = false
		if self.show then self.curY = self.height end
	end

	if self.animDelta > self.animTime +5 then 
		self.animDelta = 0 
		self.animating = false
	end
	
	self:repeatKeysUpdate(dt)
	
end

-- Called by above (Console:update) to repeat a few keys in a cheapo fashion
g_consoleRepeatKeys = { love.key_backspace, love.key_left, love.key_right,
						love.key_pageup, love.key_pagedown, love.key_delete }
function Console:repeatKeysUpdate(dt)
	if self.show then
		for i=1, #g_consoleRepeatKeys do
			if love.keyboard.isDown(g_consoleRepeatKeys[i]) then
				self.repeatKeyTime = self.repeatKeyTime + dt*1000
				if self.repeatKeyTime > 150 then
					self:keypressed(g_consoleRepeatKeys[i])
					self.repeatKeyTime = 0
				end
				return
			end
		end
		
		self.repeatKeyTime = 0
	end
end

-- Stick a call to this in your keypressed callback, and you may want to check to 
--  see if it eats the key message - it returns true when the console has eaten a key (mm..)
function Console:keypressed(key)
	if not self.show then
		return false
	end
	
	if key == self.toggleKey then
		return false
	end
	
	local isKeypadKey = key >= love.key_kp0 and key <= love.key_kp_equals and key ~= love.key_kp_enter
	
	-- if the key is one of the printable characters
	if (key >= love.key_space and key <= love.key_z) or isKeypadKey then
	
		if isKeypadKey then
			key = self:checkKeypadKeys(key)
		else
			key = string.char(key)
		end
			
		-- if shift is down
		if love.keyboard.isDown(love.key_rshift) or love.keyboard.isDown(love.key_lshift) then
			-- check if it's a symbol key (and convert)
			key = self:checkSymbolKeys(key)
			-- convert to upper (for any letters)
			key = string.upper(key)
		end
	
		-- insert the key into the field wherever the cursor is
		if self.cursorPos ~= string.len(self.inputField) then
			self.inputField = string.sub(self.inputField, 1, self.cursorPos) .. key .. string.sub(self.inputField, self.cursorPos+1)
		else -- cursor is at the end
			self.inputField = self.inputField .. key
		end

		self.cursorPos = self.cursorPos + 1
		
	elseif key == love.key_backspace then
		if self.cursorPos > 0 then
			self.inputField = string.sub(self.inputField, 1, self.cursorPos-1) .. string.sub(self.inputField, self.cursorPos+1)
			self.cursorPos = self.cursorPos - 1
		end
		
	elseif key == love.key_delete then
		if self.cursorPos < #self.inputField then
			if cursorPos == 0 then
				self.inputField = string.subg(self.inputField, 2)
			else
				self.inputField = string.sub(self.inputField, 1, self.cursorPos) .. string.sub(self.inputField, self.cursorPos+2)
			end
		end
		
	elseif key == love.key_return or key == love.key_kp_enter then
		self:executeInput()
		
	elseif key == love.key_left then
		-- move cursor to the left
		if self.cursorPos > 0 then
			self.cursorPos = self.cursorPos - 1
		end
		
	elseif key == love.key_right then
		-- move cursor to the right
		if self.cursorPos < string.len(self.inputField) then
			self.cursorPos = self.cursorPos + 1
		end
		
	elseif key == love.key_up then
		-- recall the input history
		if #self.inputHistory > 0 then
			if #self.inputHistory > self.inputHistoryPos then self.inputHistoryPos = self.inputHistoryPos + 1 end
			self.inputField = self.inputHistory[self.inputHistoryPos]
			self.cursorPos = #self.inputField
		end
	elseif key == love.key_down then
		if self.inputHistoryPos > 1 then
			self.inputHistoryPos = self.inputHistoryPos - 1
			self.inputField = self.inputHistory[self.inputHistoryPos]
			self.cursorPos = #self.inputField
		else
			self:clearInput()
			self.inputHistoryPos = 0
		end
	elseif key == love.key_end then
		-- set cursor to the end of the text
		self.cursorPos = string.len(self.inputField)
		
	elseif key == love.key_home then
		-- set cursor to the start of the text
		self.cursorPos = 0

	elseif key == love.key_pageup then -- scroll up a bit
		if self.linePos > 5 then
			self.linePos = self.linePos - 5
		end
	elseif key == love.key_pagedown then -- scroll down a bit
		if self.linePos < #self.textLines - 4 then
			self.linePos = self.linePos + 5
		else
			self.linePos = #self.textLines
		end
	else
		return false
	end
	return true
end

-- This function is called internally by Console:keypressed when shift is pressed, to check
--  for the symbol keys (#,$,%..) since LOVE won't give us symbols by themselves
-- You might want to add some symbols here if i haven't got em (it'll probably vary
--  from locality to locality)
g_consoleSymbols = { "!", "@", "#", "$", "%", "^", "&", 
					"*", "(", ")", "_", "+", "{", "}", "?", "|", ":", "\"", "<", ">" }
g_consoleSymKeys = { "1", "2", "3", "4", "5", "6", "7", 
					"8", "9", "0", "-", "=", "[", "]", "/", "\\", ";", "\'", ",", "." }					

function Console:checkSymbolKeys(key)
	for id, symkey in ipairs(g_consoleSymKeys) do
		if key == symkey then
			return g_consoleSymbols[id]
		end
	end
	return key
end

-- This function's also called by Console:keypressed when a keypad key is hit, since
--  string.char() doesn't recognise the keypad constants
g_consoleKeypad = { love.key_kp0, love.key_kp1, love.key_kp2, love.key_kp3,
					love.key_kp4, love.key_kp5, love.key_kp6, love.key_kp7, love.key_kp8,
					love.key_kp9, love.key_kp_period, love.key_kp_divide, love.key_kp_multiply,
					love.key_kp_minus, love.key_kp_plus, love.key_kp_equals }
g_consoleKeypadChars = { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
						".", "/", "*", "-", "+", "=" }
						
function Console:checkKeypadKeys(key)
	for id, keypadKey in pairs(g_consoleKeypad) do
		if keypadKey == key then
			return g_consoleKeypadChars[id]
		end
	end
	return key -- not a keypad key?
end

-- Called when enter has been hit
function Console:executeInput()
	local functionOut = ""
	
	self:print("> " .. self.inputField)
	
	local inputFunction = loadstring(self.inputField)
	if inputFunction ~= nil then 
		functionOut = inputFunction() 
	end
	
	if functionOut ~= nil then
		self:print(tostring(functionOut))
	end
	
	table.insert(self.inputHistory, 1, self.inputField)
	-- Remove an element from input history if the history is full
	-- (the input history size constant is here)
	if #self.inputHistory > 15 then table.remove(self.inputHistory, #self.inputHistory) end
	self.inputHistoryPos = 0
	self:clearInput()
end

-- Called internally, clears the input field 
function Console:clearInput() 
	self.inputField = ""
	self.cursorPos = 0
end

-- Be sure to call toggle or display instead of setting 'show' directly
function Console:toggle()
	self:display(not self.show)
end
function Console:display(show)
	if not self.animating then
		self.animating = true
		self.show = show
	end
end
function Console:clear()
	self.linePos = 1
	self.textLines = {}
end

-- Dumps the console text to a file
-- Both parameters are optional, filename defaults to console_dump.txt
-- 'append' is a boolean, defaults to false
function Console:dump(filename, append)
	local file = { }
	if filename == nil then filename = "console_dump.txt" end
	if append == nil then append = false end
	
	local lineEnd = "\n"
	local platform = love.system.getPlatform()
	if platform == "Linux" then
		lineEnd = "\n"
	elseif platform == "Windows" then
		lineEnd = "\r\n"
	elseif platform == "Macintosh" then -- ?
		lineEnd = "\r"
	end

	if love.filesystem.exists(filename) and append then
		file = love.filesystem.newFile(filename, love.file_append)
	else
		file = love.filesystem.newFile(filename, love.file_write)
	end
	
	love.filesystem.open(file)
	love.filesystem.write(file, " -- console output -- " .. lineEnd)
	for i, line in ipairs(self.textLines) do
		love.filesystem.write(file, line .. lineEnd)
	end
	love.filesystem.close(file)
end

function Console:setHeight(newHeight)
	if self.show then
		self:display(false)
	end
	self.height = newHeight
end

-- A helper function to save you typing a for-loop into the console, printv loops
--  over a table's values and prints them to the console
function Console:printv(inTable)
	for var, value in pairs(inTable) do
		self:print(tostring(var) .. " = " .. tostring(value))
	end
end

-- The print function, if the line is too long it'll split it in half and
--  add each half separately. If you find that you're printing long lines a lot
--  you may want to improve this to split lines into multiple parts
function Console:print(...)
	local text = ""
	for i,v in ipairs(arg) do
		text = text .. tostring(v) .. "  "
	end
	
	-- split the line if it's too big (only in half)
	if love.graphics.getFont():getWidth(text) > self.width then
		text = string.sub(text, 1, string.len(text)/2) .. "\n / " .. string.sub(text, string.len(text)/2+1)
	end
	
	local numLines = 0
	-- separate the text into multiple lines if there are newline chars
	for line in string.gmatch(text, "[^\n]+") do
		numLines = numLines + 1
		table.insert(self.textLines, line)
	end
	-- if the console is scrolled to the bottom, auto scroll it
	if self.linePos == #self.textLines-numLines then
		self.linePos = #self.textLines
	end

	-- Remove lines that aren't visible anymore (when the output history is full)
	if (#self.textLines + 1) > (self.height / self.textHeight + self.numHistory) then
		table.remove(self.textLines, 1)
	end		

end
