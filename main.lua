--[[
]]--
function love.load()
  -- setup world colors
  wallColor = {30, 30, 30}
  backgroundColor = {255, 255, 255}
  love.graphics.setBackgroundColor(backgroundColor)
  love.graphics.setFont(love.graphics.newFont("Square One.ttf", 14))
  love.graphics.setFont(love.graphics.newFont("asd.otf", 20))
  love.graphics.setFont(love.graphics.newFont("pxlxxl.ttf", 36))
  
  -- set random seed to prevent apples from always
  -- starting at the same positions
  math.randomseed(os.time())
  
  -- global variables
  showHighscore = false
  showControls = false
  result = -1
  gameIsRunning = false
  timer = 0
  enterText = false
  inputText = ""
  defaultLength = 5
  worldHeight = 28
  worldWidth = 58
  offset = 40
  activeSnakes = 0
  
  -- setup high score table
  highscore = {}
  loadHighscore()
  
  -- initiate apples
  apples = {}
  
  -- initiate snakes
  snake = {
    {color = {255, 10, 10}, start = {x = 20, y = 18}, startDirection = {x = 1, y = 0}, keys = {"w", "s", "a", "d"}, score = 0, body = {}, direction = {}, tmpDirection={}, alive = true},
    {color = {10, 255, 10}, start = {x = 38, y = 10}, startDirection = {x =-1, y = 0}, keys = {"i", "k", "j", "l"}, score = 0, body = {}, direction = {}, tmpDirection={}, alive = true},
    {color = {10, 10, 255}, start = {x = 38, y = 18}, startDirection = {x =-1, y = 0}, keys = {"t", "g", "f", "h"}, score = 0, body = {}, direction = {}, tmpDirection={}, alive = true},
    {color = {255, 155, 100}, start = {x = 20, y = 10}, startDirection = {x =1, y = 0}, keys = {"up", "down", "left", "right"}, score = 0, body = {}, direction = {}, tmpDirection={}, alive = true}
  }
  
  -- initiate menu buttons
  buttons = {
    {title = "HIGHSCORE", pos = {x = 14, y = 14 + 26 * 0}, size = {x = 160, y = 22}, hover = false, pushed = false},
    {title = "CONTROLLS", pos = {x = 14, y = 14 + 26 * 1}, size = {x = 160, y = 22}, hover = false, pushed = false},
    {title = "1 PLAYER", pos = {x = 14, y = 14 + 26 * 2}, size = {x = 160, y = 22}, hover = false, pushed = false},
    {title = "2 PLAYER", pos = {x = 14, y = 14 + 26 * 3}, size = {x = 160, y = 22}, hover = false, pushed = false},
    {title = "3 PLAYER", pos = {x = 14, y = 14 + 26 * 4}, size = {x = 160, y = 22}, hover = false, pushed = false},
    {title = "4 PLAYER", pos = {x = 14, y = 14 + 26 * 5}, size = {x = 160, y = 22}, hover = false, pushed = false},
    {title = "QUIT", pos = {x = 14, y = 14 + 26 * 6}, size = {x = 160, y = 22}, hover = false, pushed = false}
  }
  --[[buttons = {
    {title = "highscore", pos = {x = 14, y = 14 + 26 * 0}, size = {x = 160, y = 22}, hover = false, pushed = false},
    {title = "controls", pos = {x = 14, y = 14 + 26 * 1}, size = {x = 160, y = 22}, hover = false, pushed = false},
    {title = "1  player", pos = {x = 14, y = 14 + 26 * 2}, size = {x = 160, y = 22}, hover = false, pushed = false},
    {title = "2 player", pos = {x = 14, y = 14 + 26 * 3}, size = {x = 160, y = 22}, hover = false, pushed = false},
    {title = "3 player", pos = {x = 14, y = 14 + 26 * 4}, size = {x = 160, y = 22}, hover = false, pushed = false},
    {title = "4 player", pos = {x = 14, y = 14 + 26 * 5}, size = {x = 160, y = 22}, hover = false, pushed = false},
    {title = "quit", pos = {x = 14, y = 14 + 26 * 6}, size = {x = 160, y = 22}, hover = false, pushed = false}
  }--]]
end

--[[
  Initiate snakes and apples before starting a new game
]]--
function initiateWorld()
  for i = 1, activeSnakes do
    setupSnake(snake[i], defaultLength)
  end

  apples = {}
  generateApples(5)
end

--[[
  Save highscore list to file
]]--
function love.quit()
  local s = "local highscore = {\n"
  
  for i = 1, #highscore do
    s = s.."\t{name = \""..highscore[i].name.."\", score = "..highscore[i].score.."}"
    if i ~= #highscore then s = s .. ",\n" end
  end
  
  s = s .. "\n}\nreturn highscore"

  love.filesystem.write( "highscore.lua", s)
end

--[[
]]--
function generateApples(n)
  local occupied = false
  local pos = {x = 0, y = 0}
  local i = 0
  
  -- REVISIT!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  for i = 1, n do
    -- give it 20 tries to find a empty spot before
    -- taking whatever position is current
    while i < 20 do
      i = i + 1
      pos = {
        x = math.random(worldWidth),
        y = math.random(worldHeight)
      }
      
      for j = 1, activeSnakes do
        for k = 1, #snake[j].body do
          if equal(pos, snake[j].body[k]) then occupied = true end
          if occupied then break end
        end
        if occupied then break end
      end
      
      if not occupied then break end
    end
    
    table.insert(apples, pos)
  end
end

--[[
  Helper function used to compare two positions
]]--
function equal(a, b)
  return a.x == b.x and a.y == b.y
end

--[[
  Helper function used when sorting the high score table
]]--
function compare(a, b)
  return a.score > b.score
end

--[[
  Initiate a snake by creating its body
]]--
function setupSnake(snake, l)
  snake.body = {}
  if l == nil or l == 0 then l = 1 end  
  
  snake.alive = true
  snake.direction = snake.startDirection  
  -- tmpDirection prevents turning to fast creating a 180 degree
  -- turn where the snake can go back inside itself
  snake.tmpDirection = snake.startDirection
  
  for i = 1, l do
    table.insert(snake.body, {
      x = snake.start.x - i * snake.direction.x,
      y = snake.start.y - i * snake.direction.y})
  end
end

--[[
  Save highs core to file
]]--
function saveHighscore()
  -- insert the new highscore and sort the list
  table.insert(highscore, {name = inputText, score = math.random(100)})
  table.sort(highscore, compare)
  
  -- only keep a maximum of 10 entries in the highscore table
  while #highscore > 10 do table.remove(highscore) end
end

--[[
  Load highs core table from file
]]--
function loadHighscore()
  --if love.filesystem.exists("highscorea.lua") then -- check if this actually works
  highscore = love.filesystem.load("highscore.lua")()
  --end
end

--[[
  Reads user input
]]--
function love.textinput(t)
  if enterText then inputText = inputText .. t end
end

--[[
  Handles pressed keys
]]--
function love.keypressed(key)
  if key == "escape" then love.event.quit() end
  if key == "backspace" then inputText = string.sub(inputText, 1, -2) end

  -- pause game
  if key == "p" then
    gameIsRunning = not gameIsRunning
    timer = 0
  end

  --if key == "t" then enterText =  not enterText end
  --if not enterText and key == "g" then saveHighscore() end

  -- user input for controlling the snake
  if not enterText and gameIsRunning then
    for i = 1, #snake do
      if key == snake[i].keys[1] and snake[i].direction.y ~= 1 then snake[i].tmpDirection = {x = 0, y = -1} end
      if key == snake[i].keys[2] and snake[i].direction.y ~= -1 then snake[i].tmpDirection = {x = 0, y = 1} end
      if key == snake[i].keys[3] and snake[i].direction.x ~= 1 then snake[i].tmpDirection = {x = -1, y = 0} end
      if key == snake[i].keys[4] and snake[i].direction.x ~= -1 then snake[i].tmpDirection = {x = 1, y = 0} end
    end
  end
end

function love.mousereleased( x, y, button )
  if not gameIsRunning then
    y = y - offset
    
    for i = 1, #buttons do
      if x > buttons[i].pos.x and x < buttons[i].pos.x + buttons[i].size.x and y > buttons[i].pos.y and y < buttons[i].pos.y + buttons[i].size.y then
        if i == 1 then
          result = -1
          showHighscore = true
          showControls = false
        elseif i == 2 then
          result = -1
          showHighscore = false
          showControls = true
        elseif i == 3 or i == 4 or i == 5 or i == 6 then
          result = -1
          showHighscore = false
          showControls = false
          gameIsRunning = true
          activeSnakes = i - 2
          initiateWorld()
          timer = 0
        else
          love.event.quit()
        end
      end
    end
  end
end

--[[
  Main game loop, updates the game progression
]]--
function love.update(dt)
  timer = timer + dt
  
  if not gameIsRunning then
    local x, y = love.mouse.getPosition()
    y = y - offset
    
    for i = 1, #buttons do
      if x > buttons[i].pos.x and x < buttons[i].pos.x + buttons[i].size.x and y > buttons[i].pos.y and y < buttons[i].pos.y + buttons[i].size.y then
        if love.mouse.isDown("l") then
          buttons[i].pushed = true
        else
          buttons[i].hover = true
          buttons[i].pushed = false
        end
      else
        buttons[i].hover = false
        buttons[i].pushed = false
      end
    end
  end
  
  if not enterText and gameIsRunning then
    if timer > 0.1 then
      timer = timer - 0.1
      
      -- update snake positions
      for i = 1, activeSnakes do
        -- dont update dead snakes
        if snake[i].alive == false then goto continue end
        
        snake[i].direction = snake[i].tmpDirection
        
        -- find new position
        local pos = {x = snake[i].body[1].x, y = snake[i].body[1].y}
        pos.x = pos.x + snake[i].direction.x
        pos.y = pos.y + snake[i].direction.y
        
        -- check to see if snake eats a apple
        for j = 1, #apples do
          if equal(snake[i].body[1], apples[j]) then
            table.insert(snake[i].body, 1, apples[j])
            table.remove(apples, j)
            generateApples(1)
            snake[i].score = snake[i].score + 1
            break
          end
        end
        
        -- move the snake forwards one step
        table.remove(snake[i].body)
        table.insert(snake[i].body, 1, pos)
        
        ::continue::
      end
      
      -- check for collisions
      for i = 1, activeSnakes do
        local pos = {x = snake[i].body[1].x, y = snake[i].body[1].y}
        
        -- check if snake hits any walls
        if pos.x < 1 or pos.x > worldWidth or pos.y < 1 or pos.y > worldHeight then
          snake[i].alive = false
        end
        
        -- check if snake hits any part of any snake
        for j = 1, activeSnakes do
          for k = 1, #snake[j].body do
            -- no intersection with snakes own head
            if equal(pos, snake[j].body[k]) and not (i == j and k == 1) then
              snake[i].alive = false
              break
            end
          end
        end
      end
      
      -- find the result of the game
      local count = 0
      for i = 1, activeSnakes do
        if snake[i].alive == true then count = count + 1 end
      end
      
      -- single player
      if activeSnakes == 1 and count == 0 then
        gameIsRunning = false
        result = 1
      end
      
      -- multiplayer with no surviving snakes
      if activeSnakes > 1 and count == 0 then
        gameIsRunning = false
        result = 0
      end
      
      -- multiplayer with one surviving snake
      if activeSnakes > 1 and count == 1 then
        gameIsRunning = false
        for i = 1, activeSnakes do
          if snake[i].alive then result = i end
        end
      end
    end
  end
end

--[[
  Draw function
]]--
function love.draw()
  -- draw border
  love.graphics.setColor(wallColor)
  love.graphics.rectangle("fill", 10, 10, love.graphics:getWidth() - 20, 30)
  love.graphics.rectangle("fill", 10, 10 + offset, love.graphics:getWidth() - 20, love.graphics:getHeight() - offset - 20)
  
  local width = 140
  for i = 1, activeSnakes do
    if snake[i].alive then
      love.graphics.setColor(snake[i].color)
    else
      love.graphics.setColor(100, 100, 100)
    end
    love.graphics.rectangle("fill", 10 + 4 * i + width * (i - 1), 14, width, 22)
    love.graphics.setColor(wallColor)
    love.graphics.print("SCORE:" .. snake[i].score, 13 + 4 * i + width * (i - 1), 14)
  end
  
  -- render apples
  for i = 1, #apples do
    love.graphics.setColor(200, 55, 55)
    love.graphics.rectangle("fill", apples[i].x * 10, offset + apples[i].y * 10, 10, 10)
  end
  
  -- render snakes
  for i = 1, activeSnakes do
    love.graphics.setColor(snake[i].color)    
    for j = 1, #snake[i].body do
      love.graphics.rectangle("fill",
        1 + snake[i].body[j].x * 10,
        1 + offset + snake[i].body[j].y * 10,
        8, 8)
    end
  end
  
  -- result after a game
  if result >= 0 then drawEndGame() end
  -- draw menu
  if not gameIsRunning then drawMenu() end    
  -- controlls
  if showControls then drawControls() end
  -- highscore
  if showHighscore then drawHighscore() end
end

--[[
]]--
function drawEndGame()
  -- three cases, either single player game then display score
  -- or multiplayer where the result was a tie
  -- or multiplayer where one player was the winner
  if activeSnakes == 1 then
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("fill", 178, offset + 14, 408, 22)
    love.graphics.setColor(wallColor)
    love.graphics.print("FINAL SCORE: " .. snake[1].score, 182, offset + 14)
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
  end
end

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
    love.graphics.print("-" .. highscore[i].score, 230, offset + 14 + 26 * (i - 1))
    love.graphics.print("-" ..  string.upper(highscore[i].name), 300, offset + 14 + 26 * (i - 1))
  end
end

--[[
]]--
function drawControls()
  local k = {"UP", "DOWN", "LEFT", "RIGHT", "", "PAUSE", "EXIT"}
  
  -- render backgrounds
  love.graphics.setColor(255, 255, 255)
  for i = 1, 7 do
    love.graphics.rectangle("fill", 178, offset + 14 + (i - 1) * 26, 408, 22)
  end
  
  -- render control text
  love.graphics.setColor(wallColor)
  for i = 1, #k do
    love.graphics.print(k[i], 182, offset + 14 + 26 * (i - 1))
    love.graphics.print("-", 240, offset + 14 + 26 * (i - 1))
  end
  
  -- render general buttons
  love.graphics.print("P", 260, offset + 14 + 130)
  love.graphics.print("ESCAPE", 260, offset + 14 + 156)
  
  -- render snake control buttons
  for i = 1, 4 do
    love.graphics.setColor(snake[i].color)
    love.graphics.print(string.upper(snake[i].keys[1]), 210 + 50 * i, offset + 14)
    love.graphics.print(string.upper(snake[i].keys[2]), 210 + 50 * i, offset + 14 + 26)
    love.graphics.print(string.upper(snake[i].keys[3]), 210 + 50 * i, offset + 14 + 52)
    love.graphics.print(string.upper(snake[i].keys[4]), 210 + 50 * i, offset + 14 + 78)
  end
end