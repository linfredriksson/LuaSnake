--e = love.filesystem.exists("highscorea.lua") -- probably best to check if it exists

function love.load()
  wallColor = {0, 0, 0}
  backgroundColor = {255, 255, 255}
  love.graphics.setBackgroundColor(backgroundColor)
  posY = love.graphics:getHeight() * 0.5
  posX = love.graphics:getWidth() * 0.5
  timer = 0
  direction = "right"
  enterText = false
  inputText = ""
  highscore = {}
  loadHighscore()
  --snake1 = {}
  snake = {
    {color = {255, 0, 0}, body = {}, start = {x = 200, y = 200}, keys = {"w", "s", "a", "d"}, score = 0, direction = {x = 1, y = 0}},
    {color = {0, 255, 0}, body = {}, start = {x = 400, y = 200}, keys = {"i", "k", "j", "l"}, score = 0, direction = {x = -1, y = 0}}
  }
  apples = {}
  generateApples()
  setupSnake(snake[1], 3)
  setupSnake(snake[2], 3)
end

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

function generateApples(n)
  n = n or 0
  for i = 1, n do
  end
end

function compare(a, b)
  return a.score > b.score
end

function setupSnake(snake, l)
  snake.body = {}
  if l == nil or l == 0 then l = 1 end
  
  for i = 1, l do
    table.insert(snake.body, {x = snake.start.x + i * snake.direction.x * 10, y = snake.start.y + i * snake.direction.y})
  end
end

function saveHighscore()
  -- insert the new highscore and sort the list
  table.insert(highscore, {name = inputText, score = math.random(100)})
  table.sort(highscore, compare)
  
  -- only keep a maximum of 10 entries in the highscore table
  while #highscore > 10 do table.remove(highscore) end
end

function loadHighscore()
  --if love.filesystem.exists("highscorea.lua") then -- check if this actually works
  highscore = love.filesystem.load("highscore.lua")()
  --end
end

function love.textinput(t)
  if enterText then inputText = inputText .. t end
end

function love.keypressed(key)
  if key == "escape" then love.event.quit() end
  if key == "return" then enterText =  not enterText end
  if key == "backspace" then inputText = string.sub(inputText, 1, -2) end
  
  if not enterText and key == "k" then saveHighscore() end
  
  if not enterText then
    if key == snake[1].keys[1] and snake[1].direction.y ~= 1 then snake[1].direction = {x = 0, y = -1} end
    if key == snake[1].keys[2] and snake[1].direction.y ~= -1 then snake[1].direction = {x = 0, y = 1} end
    if key == snake[1].keys[3] and snake[1].direction.x ~= 1 then snake[1].direction = {x = -1, y = 0} end
    if key == snake[1].keys[4] and snake[1].direction.x ~= -1 then snake[1].direction = {x = 1, y = 0} end
  end
end

function love.update(dt)
  timer = timer + dt
  if not enterText then
    if timer > 0.1 then
      timer = timer - 0.1
      
      local pos = {x = snake[1].body[1].x, y = snake[1].body[1].y}
      pos.x = pos.x + snake[1].direction.x * 10
      pos.y = pos.y + snake[1].direction.y * 10
      table.remove(snake[1].body)
      table.insert(snake[1].body, 1, pos)
      
      if pos.x <= 10 then snake[1].direction = {x = 1, y = 0} end
      if pos.x >= love.graphics:getWidth() - 20 then snake[1].direction = {x = -1, y = 0} end
      if pos.y <= 120 then snake[1].direction = {x = 0, y = 1} end
      if pos.y >= love.graphics:getHeight() - 20 then snake[1].direction = {x = 0, y = -1} end
    end
  end
end

function love.draw()
  -- draw border
  love.graphics.setColor(wallColor)
  love.graphics.rectangle("fill", 10, 10, love.graphics:getWidth() - 20, 100)
  love.graphics.rectangle("fill", 10, 120, love.graphics:getWidth() - 20, love.graphics:getHeight() - 130)
  
  love.graphics.setColor(backgroundColor)
  love.graphics.print("Input text: " .. inputText, 10, 10)
  love.graphics.print("Snake length: " .. #snake[1].body, 10, 30)
  
  love.graphics.print("Highscore length: " .. #highscore, 150, 10)
  for i = 1, #highscore do
    love.graphics.print(highscore[i].score, 150, 20 + i * 10)
    love.graphics.print(highscore[i].name, 170, 20 + i * 10)
  end
  
  love.graphics.setColor(snake[1].color)
  for i = 1, #snake[1].body do
    love.graphics.print(snake[1].body[i].x, 10, 40 + i * 10)
    love.graphics.print(snake[1].body[i].y, 40, 40 + i * 10)
    love.graphics.rectangle("fill", snake[1].body[i].x, snake[1].body[i].y, 10, 10)
  end
end