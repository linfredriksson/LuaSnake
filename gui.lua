--[[
]]--
function drawMenu()
  for i = 1, #buttons do
    if buttons[i].pushed then
      love.graphics.setColor(100, 100, 100)
    elseif buttons[i].hover then
      love.graphics.setColor(200, 200, 200)
    else
      love.graphics.setColor(255, 255, 255)
    end
    
    love.graphics.rectangle("fill", buttons[i].pos.x, offset + buttons[i].pos.y, buttons[i].size.x, buttons[i].size.y)
    
    love.graphics.setColor(wallColor)
    love.graphics.print(buttons[i].title, buttons[i].pos.x + 3, offset + buttons[i].pos.y)-- + 6)
  end
end

--[[
]]--
function drawHighscore()
  for i = 1, 10 do
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("fill", 178, offset + 14 + (i - 1) * 26, 408, 22)
    love.graphics.setColor(wallColor)
    love.graphics.print("#"..i, 182, offset + 14 + 26 * (i - 1))
  end
  for i = 1, #highscore do
    love.graphics.setColor(wallColor)
    love.graphics.print(": " .. highscore[i].score, 230, offset + 14 + 26 * (i - 1))
    love.graphics.print(": " ..  string.upper(highscore[i].name), 300, offset + 14 + 26 * (i - 1))
  end
end

--[[
]]--
function drawControls()
  local k = {"UP", "DOWN", "LEFT", "RIGHT", "", "EXIT"}
  
  -- render backgrounds
  love.graphics.setColor(255, 255, 255)
  for i = 1, 6 do
    love.graphics.rectangle("fill", 178, offset + 14 + (i - 1) * 26, 408, 22)
  end
  
  -- render control text
  love.graphics.setColor(wallColor)
  for i = 1, #k do
    love.graphics.print(k[i], 182, offset + 14 + 26 * (i - 1))
    love.graphics.print("-", 240, offset + 14 + 26 * (i - 1))
  end
  
  -- render general buttons
  love.graphics.print("ESCAPE", 260, offset + 14 + 130)
  
  -- render snake control buttons
  for i = 1, 4 do
    love.graphics.setColor(snake[i].color)
    love.graphics.print(string.upper(snake[i].keys[1]), 210 + 50 * i, offset + 14)
    love.graphics.print(string.upper(snake[i].keys[2]), 210 + 50 * i, offset + 14 + 26)
    love.graphics.print(string.upper(snake[i].keys[3]), 210 + 50 * i, offset + 14 + 52)
    love.graphics.print(string.upper(snake[i].keys[4]), 210 + 50 * i, offset + 14 + 78)
  end
end

--[[
]]--
function drawEndGame()
  -- three cases, either single player game then display score
  -- or multiplayer where the result was a tie
  -- or multiplayer where one player was the winner
  local offsetY = 0
  
  if activeSnakes == 1 then
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("fill", 178, offset + 14, 408, 22)
    love.graphics.setColor(wallColor)
    love.graphics.print("FINAL SCORE: " .. snake[1].score, 182, offset + 14)
    offsetY = 1
  elseif result == 0 then
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("fill", 178, offset + 14, 408, 22)
    love.graphics.setColor(wallColor)
    love.graphics.print("THE GAME WAS A DRAW", 182, offset + 14)
  else
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("fill", 178, offset + 14, 408, 22)
    love.graphics.rectangle("fill", 178, offset + 14 + 26, 408, 22)
    love.graphics.setColor(wallColor)
    love.graphics.print("PLAYER " .. result .. " IS THE WINNER" , 182, offset + 14)
    love.graphics.print("FINAL SCORE: " .. snake[result].score, 182, offset + 14 + 26)
    offsetY = 2
  end
  
  if enterText then drawInputText(offsetY * 26) end
end

--[[
]]--
function drawInputText(offsetY)
  love.graphics.setColor(255, 255, 255)
  love.graphics.rectangle("fill", 178, offset + 14 + offsetY, 408, 22)
  love.graphics.rectangle("fill", 178, offset + 14 + 26 + offsetY, 408, 22)
  love.graphics.rectangle("fill", 178, offset + 14 + 52 + offsetY, 408, 22)
  love.graphics.rectangle("fill", 178, offset + 14 + 78 + offsetY, 408, 22)
  love.graphics.setColor(wallColor)
  love.graphics.print("TYPE A NAME AND PRESS ENTER TO ENTER", 182, offset + 14 + 26 + offsetY)
  love.graphics.print("THE SCORE INTO THE HIGHSCORE LIST", 182, offset + 14 + 52 + offsetY)
  love.graphics.print("NAME: " .. inputText, 182, offset + 14 + 78 + offsetY)
end