--[[
  Function draws the games main menu containing options to
  display highscore, controls, start new games or quit the game
]]--
function drawMenu()
  for i = 1, #buttons do
    love.graphics.setColor(gameColor1)
    
    -- give buttons different color if it is pressed or
    -- if the user hovers over it with the mouse pointer
    if buttons[i].pushed then
      love.graphics.setColor(100, 100, 100)
    elseif buttons[i].hover then
      love.graphics.setColor(200, 200, 200)
    end
    
    -- button background
    love.graphics.rectangle("fill", buttons[i].pos.x, offset + buttons[i].pos.y, buttons[i].size.x, buttons[i].size.y)
    
    -- button text
    love.graphics.setColor(gameColor2)
    love.graphics.print(buttons[i].title, buttons[i].pos.x + 3, offset + buttons[i].pos.y)
  end
end

--[[
  Function draws the highscore table containing the top 10 results
]]--
function drawHighscore()
  -- draw backgrounds and numbering for 10 entries
  for i = 1, 10 do
    love.graphics.setColor(gameColor1)
    love.graphics.rectangle("fill", 178, offset + 14 + (i - 1) * 26, 408, 22)
    love.graphics.setColor(gameColor2)
    love.graphics.print("#"..i, 182, offset + 14 + 26 * (i - 1))
  end
  
  -- draw the entries currently in the highscore table
  for i = 1, #highscore do
    love.graphics.setColor(gameColor2)
    love.graphics.print(": " .. highscore[i].score, 230, offset + 14 + 26 * (i - 1))
    love.graphics.print(": " ..  string.upper(highscore[i].name), 300, offset + 14 + 26 * (i - 1))
  end
end

--[[
  Function displays the controls in the game, the controls to steer
  the snakes and to quit the game
]]--
function drawControls()
  local k = {"UP", "DOWN", "LEFT", "RIGHT", "", "EXIT"}
  
  -- render backgrounds
  love.graphics.setColor(gameColor1)
  for i = 1, 6 do
    love.graphics.rectangle("fill", 178, offset + 14 + (i - 1) * 26, 408, 22)
  end
  
  -- render control text
  love.graphics.setColor(gameColor2)
  for i = 1, #k do
    love.graphics.print(k[i], 182, offset + 14 + 26 * (i - 1))
    love.graphics.print("-", 240, offset + 14 + 26 * (i - 1))
  end
  
  -- render general buttons
  love.graphics.print("ESCAPE", 260, offset + 14 + 130)
  
  -- render snake control button text
  for i = 1, 4 do
    love.graphics.setColor(snake[i].color)
    for j = 1, 4 do
      love.graphics.print(string.upper(snake[i].keys[j]), 210 + 50 * i, offset + 14 + 26 * (j - 1))
    end
  end
end

--[[
  The function displays the result of a game, the function is used
  for all results for both single player game and multiplayer games
  
  There are three cases for a end game
  - Single player
  - Multiplayer with a tie game
  - Multiplayer with a winner
]]--
function drawEndGame()
  local offsetY = 0
  
  -- single player
  if activeSnakes == 1 then
    love.graphics.setColor(snake[result].color)
    love.graphics.rectangle("fill", 178, offset + 14, 408, 22)
    love.graphics.setColor(gameColor2)
    love.graphics.print("FINAL SCORE: " .. snake[1].score, 182, offset + 14)
    offsetY = 1
  -- multiplayer tie
  elseif result == 0 then
    love.graphics.setColor(gameColor1)
    love.graphics.rectangle("fill", 178, offset + 14, 408, 22)
    love.graphics.setColor(gameColor2)
    love.graphics.print("THE GAME WAS A DRAW", 182, offset + 14)
  -- multiplayer with a winner
  else
    love.graphics.setColor(snake[result].color)
    love.graphics.rectangle("fill", 178, offset + 14, 408, 22)
    love.graphics.setColor(gameColor1)
    love.graphics.rectangle("fill", 178, offset + 14 + 26, 408, 22)
    love.graphics.setColor(gameColor2)
    love.graphics.print("PLAYER " .. result .. " IS THE WINNER" , 182, offset + 14)
    love.graphics.print("FINAL SCORE: " .. snake[result].score, 182, offset + 14 + 26)
    offsetY = 2
  end
  
  -- if score was enough to insert into highscore table also display
  -- box and instructions for user to input a name and press enter
  if enterText then drawInputText(offsetY * 26) end
end

--[[
  Function displays the means for a user to insert a name to enter the
  highscore table if the winners score was higher than atleas one other
  entry in the highscore table
]]--
function drawInputText(offsetY)
  -- draw backgrounds
  love.graphics.setColor(gameColor1)
  love.graphics.rectangle("fill", 178, offset + 14 + offsetY, 408, 22)
  love.graphics.rectangle("fill", 178, offset + 14 + 26 + offsetY, 408, 22)
  love.graphics.rectangle("fill", 178, offset + 14 + 52 + offsetY, 408, 22)
  love.graphics.rectangle("fill", 178, offset + 14 + 78 + offsetY, 408, 22)
  
  -- draw instruction text and the user input
  love.graphics.setColor(gameColor2)
  love.graphics.print("INPUT A NAME AND PRESS ENTER TO INSERT", 182, offset + 14 + 26 + offsetY)
  love.graphics.print("THE WINNERS SCORE INTO THE HIGHSCORE LIST", 182, offset + 14 + 52 + offsetY)
  love.graphics.print("NAME: " .. inputText, 182, offset + 14 + 78 + offsetY)
end