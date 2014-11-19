--[[
]]--
function love.load()
  -- setup world colors
  wallColor = {0, 0, 0}
  backgroundColor = {255, 255, 255}
  love.graphics.setBackgroundColor(backgroundColor)
  
  -- set random seed to prevent apples from always
  -- starting at the same positions
  math.randomseed(os.time())
  
  -- global variables
  gameIsRunning = false
  timer = 0
  enterText = false
  inputText = ""
  defaultLength = 5
  worldHeight = 28
  worldWidth = 58
  
  -- setup highscore table
  highscore = {}
  loadHighscore()
  
  -- initiate snakes
  snake = {
    {color = {255, 0, 0}, start = {x = 20, y = 13}, startDirection = {x = 1, y = 0}, keys = {"w", "s", "a", "d"}, score = 0, body = {}, direction = {}, tmpDirection={}, alive = true},
    --{color = {0, 255, 0}, start = {x = 38, y = 13}, startDirection = {x =-1, y = 0}, keys = {"i", "k", "j", "l"}, score = 0, body = {}, direction = {}, alive = true}
  }
  
  initiateWorld()
end

--[[
  Initiate snakes and apples before starting a new game
]]--
function initiateWorld()
  for i = 1, #snake do
    setupSnake(snake[i], defaultLength)
  end

  apples = {}
  generateApples(5)
end

--[[
  Save highscore list to file
]]--
function love.quit()
  saveString = "local highscore = {\n"
  
  for i = 1, #highscore do
    saveString = saveString .. "\t{name = \""
    saveString = saveString .. highscore[i].name
    saveString = saveString .. "\", score = "
    saveString = saveString .. highscore[i].score
    saveString = saveString .. "}"
    if i ~= #highscore then saveString = saveString .. ",\n" end
  end
  
  saveString = saveString .. "\n}\nreturn highscore"

  -- save savefile string to file
  love.filesystem.write( "highscore.lua", saveString)
end

--[[
]]--
function generateApples(n)
  n = n or 1
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
      
      for j = 1, #snake do
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
  if key == "return" then
    gameIsRunning = not gameIsRunning
    timer = 0
    if gameIsRunning then initiateWorld() end
  end
  
  if key == "t" then enterText =  not enterText end
  if not enterText and key == "g" then saveHighscore() end
  
  if not enterText and gameIsRunning then
    for i = 1, #snake do
      if key == snake[i].keys[1] and snake[i].direction.y ~= 1 then snake[i].tmpDirection = {x = 0, y = -1} end
      if key == snake[i].keys[2] and snake[i].direction.y ~= -1 then snake[i].tmpDirection = {x = 0, y = 1} end
      if key == snake[i].keys[3] and snake[i].direction.x ~= 1 then snake[i].tmpDirection = {x = -1, y = 0} end
      if key == snake[i].keys[4] and snake[i].direction.x ~= -1 then snake[i].tmpDirection = {x = 1, y = 0} end
    end
  end
end

--[[
  Main game loop, updates the game progression
]]--
function love.update(dt)
  timer = timer + dt
  if not enterText and gameIsRunning then
    if timer > 0.1 then
      timer = timer - 0.1
      
      for i = 1, #snake do
        -- prevents turning to fast and go back inside the snake itself
        snake[i].direction = snake[i].tmpDirection
        
        local pos = {x = snake[i].body[1].x, y = snake[i].body[1].y}
        pos.x = pos.x + snake[i].direction.x
        pos.y = pos.y + snake[i].direction.y
        
        -- check to see if snake eats a apple
        for j = 1, #apples do
          if equal(snake[i].body[1], apples[j]) then
            table.insert(snake[i].body, 1, apples[j])
            table.remove(apples, j)
            generateApples(1)
            break
          end
        end
        
        -- move the snake forwards one step
        table.remove(snake[i].body)
        table.insert(snake[i].body, 1, pos)
        
        -- check if snake hits any walls
        if pos.x < 1 or pos.x > worldWidth or pos.y < 1 or pos.y > worldHeight then
          snake[i].alive = false
        end
        
        -- check if snake hits any part of any snake
        for j = 1, #snake do
          for k = 1, #snake[j].body do
            -- no intersection with snakes own head
            if equal(pos, snake[j].body[k]) and not (i == j and k == 1) then
              snake[i].alive = false
              break
            end
          end
        end
      end
      
      -- if any snake hits anything set alive to false and pause game
      for i = 1, #snake do
        if snake[i].alive == false then
          gameIsRunning = false
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
  love.graphics.rectangle("fill", 10, 10, love.graphics:getWidth() - 20, 90)
  love.graphics.rectangle("fill", 10, 110, love.graphics:getWidth() - 20, love.graphics:getHeight() - 120)
  
  love.graphics.setColor(backgroundColor)
  
  --love.graphics.print("Input text: " .. inputText, 10, 10)
  --love.graphics.print("Snake length: " .. #snake[1].body, 10, 30)
  --love.graphics.print("Highscore length: " .. #highscore, 150, 10)
  
  --for i = 1, #highscore do
  --  love.graphics.print(highscore[i].score, love.graphics:getWidth()-170, i * 10)
  --  love.graphics.print(highscore[i].name, love.graphics:getWidth()-150, i * 10)
  --end
  
  -- render apples
  for i = 1, #apples do
    love.graphics.setColor(200, 55, 55)
    love.graphics.rectangle("fill", apples[i].x * 10, 100 + apples[i].y * 10, 10, 10)
  end
  
  -- render snakes
  for i = 1, #snake do
    love.graphics.setColor(snake[i].color)
    
    love.graphics.print("PLAYER:" .. i, 20 + 70 * (i - 1), 20)
    love.graphics.print("SCORE:" .. #snake[i].body, 20 + 70 * (i - 1), 40)
    
    for j = 1, #snake[i].body do
      love.graphics.rectangle(
        "fill",
        snake[i].body[j].x * 10,
        100 + snake[i].body[j].y * 10,
        10, 10)
    end
  end
end