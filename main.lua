-- functions used to display the GUI
require "gui"

--[[
  Load function initiating the game and all global functions
]]--
function love.load()
  gameColor1 = {255, 255, 255} -- walls and buttons
  gameColor2 = {30, 30, 30} -- background and text
  love.graphics.setBackgroundColor(gameColor1)
  
  -- font used for all text in the gui
  love.graphics.setFont(love.graphics.newFont("pxlxxl.ttf", 36))
  
  -- set random seed to prevent apples from always
  -- starting at the same positions
  math.randomseed(os.time())
  
  -- global variables
  showHighscore = false
  showControls = false
  gameIsRunning = false
  result = -1       -- 0 = tie game, bigger than 0 indicates id of player with highest score regardless of game type
  timer = 0         -- accumulates time, then when bigger than a number x update snakes
  enterText = false -- true while players can enter their name for the highscore
  inputText = ""    -- used when players enter their name into the highscore
  defaultLength = 5 -- start length of snakes
  worldHeight = 28  -- game world height
  worldWidth = 58   -- game world width
  offset = 40       -- offset in pixels from the top of the window down to the menu
  activeSnakes = 0  -- number of active snakes 1 for singleplayer 2-4 for multiplayer
  
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
end

--[[
  Function is run when the game is shut down. Used to save high score to file
  so as to keep it between game sessions. The function creates a table than
  later can be read and assigned to the high score table
]]--
function love.quit()
  local s = "local highscore = {\n"
  
  for i = 1, #highscore do
    s = s.."\t{name = \""..highscore[i].name.."\", score = "..highscore[i].score.."}"
    if i ~= #highscore then s = s .. ",\n" end
  end
  
  s = s .. "\n}\nreturn highscore"

  -- save Lua table to file
  love.filesystem.write( "highscore.lua", s)
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
  Function used to generate n number of apples at random
  positions inside the game world
]]--
function generateApples(n)
  local occupied = false
  local pos

  -- generate n apples
  for i = 1, n do
    -- give it 20 tries to find a empty spot before
    -- taking whatever position is current even if
    -- it will be on top of a snake
    while i < 20 do
      -- find a random position in the game world
      pos = {
        x = math.random(worldWidth),
        y = math.random(worldHeight)
      }
      
      -- check if pos is occupied by one of the snakes
      for j = 1, activeSnakes do
        for k = 1, #snake[j].body do
          if equal(pos, snake[j].body[k]) then
            occupied = true
            break
          end
        end
      end
      
      -- check if pos is occupied by another apple
      for j = 1, #apples do
        if equal(pos, apples[j]) then
          occupied = true
          break
        end
      end
      
      i = i + 1
      if not occupied then break end
    end
    
    table.insert(apples, pos)
  end
end

--[[
  Initiate a snake by creating its body. Function takes a snake
  and the length of its body when the game starts
]]--
function setupSnake(snake, l)
  -- reset the snake body and variables
  snake.body = {}
  snake.score = 0
  snake.alive = true
  snake.direction = snake.startDirection  
  -- tmpDirection prevents turning to fast creating a 180 degree
  -- turn where the snake can go back inside itself
  snake.tmpDirection = snake.startDirection
  
  -- create snake body
  for i = 1, l do
    table.insert(snake.body, {
      x = snake.start.x - i * snake.direction.x,
      y = snake.start.y - i * snake.direction.y})
  end
end

--[[
  Save score to high score table. Function takes the index
  of the snake with the score high enough to enter the
  high score table
]]--
function saveHighscore(snakeIndex)
  -- insert the new high score and sort the list
  table.insert(highscore, {name = inputText, score = snake[snakeIndex].score})
  table.sort(highscore, compare)
  
  -- only keep a maximum of 10 entries in the high score table
  while #highscore > 10 do table.remove(highscore) end
end

--[[
  Load high score table from file
]]--
function loadHighscore()
  if love.filesystem.exists("highscore.lua") then
    highscore = love.filesystem.load("highscore.lua")()
  end
end

--[[
  Reads user input and is used when entering name for high score table.
]]--
function love.textinput(t)
  if enterText and string.len(inputText) < 20 then
    inputText = inputText .. tostring(t)
  end
end

--[[
  Handles pressed keys
]]--
function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
  
  if key == "backspace" then
    inputText = string.sub(inputText, 1, -2)
  end
  
  if key == "return" and enterText then
    enterText = false
    saveHighscore(result)
    inputText = ""
  end
end

--[[
  Function is called whenever a mouse button is released and is
  used to activate the menu buttons when they have been clicked
]]--
function love.mousereleased(x, y, button)
  -- only check if the game is not currently running
  if not gameIsRunning and button == "l" then
    y = y - offset
    
    for i = 1, #buttons do
      if x > buttons[i].pos.x and x < buttons[i].pos.x + buttons[i].size.x and
        y > buttons[i].pos.y and y < buttons[i].pos.y + buttons[i].size.y then
        
        result = -1
        inputText = ""

          -- highscore
        if i == 1 then
          showHighscore = true
          showControls = false
          enterText = false
        
        -- controls
        elseif i == 2 then
          showHighscore = false
          showControls = true
          enterText = false
        
        -- start a new game session
        elseif i == 3 or i == 4 or i == 5 or i == 6 then
          showHighscore = false
          showControls = false
          gameIsRunning = true
          enterText = false
          activeSnakes = i - 2
          initiateWorld()
          timer = 0
        
        -- quit game
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
  
  -- if a game is not currently in progress then check to
  -- see if mouse is hovering over a button and sets
  -- pushed/hover to true and false, this is then used when
  -- rendering the buttons to give them appropriate color
  if not gameIsRunning then
    local x, y = love.mouse.getPosition()
    y = y - offset
    
    for i = 1, #buttons do
      if x > buttons[i].pos.x and x < buttons[i].pos.x + buttons[i].size.x and
        y > buttons[i].pos.y and y < buttons[i].pos.y + buttons[i].size.y then
        
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

  -- update snakes if the game is running
  if gameIsRunning then
    -- user input for controlling the snake
    if not enterText and gameIsRunning then
      for i = 1, #snake do
        if love.keyboard.isDown(snake[i].keys[1]) and snake[i].direction.y ~= 1 then snake[i].tmpDirection = {x = 0, y = -1} end
        if love.keyboard.isDown(snake[i].keys[2]) and snake[i].direction.y ~= -1 then snake[i].tmpDirection = {x = 0, y = 1} end
        if love.keyboard.isDown(snake[i].keys[3]) and snake[i].direction.x ~= 1 then snake[i].tmpDirection = {x = -1, y = 0} end
        if love.keyboard.isDown(snake[i].keys[4]) and snake[i].direction.x ~= -1 then snake[i].tmpDirection = {x = 1, y = 0} end
      end
    end
    
    -- update snake positions when timer > 0.1
    if timer > 0.1 then
      timer = timer - 0.1
      
      for i = 1, activeSnakes do
        -- do not update a dead snake
        if snake[i].alive == true then
          snake[i].direction = snake[i].tmpDirection
          
          -- find new position
          local pos = {
            x = snake[i].body[1].x + snake[i].direction.x,
            y = snake[i].body[1].y + snake[i].direction.y}
          
          -- check to see if snake eats a apple
          for j = 1, #apples do
            if equal(snake[i].body[1], apples[j]) then
              -- add body part to snake and add points
              table.insert(snake[i].body, 1, apples[j])
              snake[i].score = snake[i].score + 1
              
              -- remove apple and generate a new one
              table.remove(apples, j)              
              generateApples(1)
              
              break
            end
          end
          
          -- move the snake forwards one step
          table.remove(snake[i].body)
          table.insert(snake[i].body, 1, pos)
        end
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
      
      -- check how many snakes is still alive
      local count = 0
      for i = 1, activeSnakes do
        if snake[i].alive == true then count = count + 1 end
      end
      
      -- if single player and no snake alive
      if activeSnakes == 1 and count == 0 then
        gameIsRunning = false
        result = 1
      end
      
      -- if multiplayer with no surviving snakes
      if activeSnakes > 1 and count == 0 then
        gameIsRunning = false
        result = 0
      end
      
      -- if multiplayer with one surviving snake
      if activeSnakes > 1 and count == 1 then
        gameIsRunning = false
        for i = 1, activeSnakes do
          if snake[i].alive then result = i end
        end
      end
      
      -- if one snake won the game and had a score higher than 0
      if result >= 1 and snake[result].score > 0 then
        -- if there are less than 10 entries in the high score or the
        -- winner had a higher score than at least one entry in the high score list
        if #highscore < 10 or snake[result].score > highscore[#highscore].score then
          enterText = true
        end
      end
    end
  end
end

--[[
  Draw function
]]--
function love.draw()
  -- draw walls and background
  love.graphics.setColor(gameColor2)
  love.graphics.rectangle("fill", 10, 10, love.graphics:getWidth() - 20, 30)
  love.graphics.rectangle("fill", 10, 10 + offset, love.graphics:getWidth() - 20, love.graphics:getHeight() - offset - 20)
  
  -- draw snake score in the top of the window
  for i = 1, activeSnakes do
    if snake[i].alive then
      love.graphics.setColor(snake[i].color)
    else
      love.graphics.setColor(100, 100, 100)
    end
    love.graphics.rectangle("fill", 10 + 4 * i + 140 * (i - 1), 14, 140, 22)
    love.graphics.setColor(gameColor2)
    love.graphics.print("SCORE:" .. snake[i].score, 13 + 4 * i + 140 * (i - 1), 14)
  end
  
  -- draw apples
  for i = 1, #apples do
    love.graphics.setColor(200, 55, 55)
    love.graphics.rectangle("fill", apples[i].x * 10, offset + apples[i].y * 10, 10, 10)
  end
  
  -- draw snakes
  for i = 1, activeSnakes do
    love.graphics.setColor(snake[i].color)    
    for j = 1, #snake[i].body do
      love.graphics.rectangle("fill",
        1 + snake[i].body[j].x * 10,
        1 + offset + snake[i].body[j].y * 10,
        8, 8)
    end
  end
  
  -- if needed, draw result after a game
  if result >= 0 then drawEndGame() end
  
  -- if needed, draw menu
  if not gameIsRunning then drawMenu() end    
  
  -- if needed, draw controls
  if showControls then drawControls() end
  
  -- if needed, draw high score
  if showHighscore then drawHighscore() end
end
