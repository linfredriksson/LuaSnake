function love.load()
  love.window.setMode(600, 400)
  posY = love.graphics:getHeight() * 0.5
  posX = love.graphics:getWidth() * 0.5
  timer = 0
  direction = "right"
  enterText = false
  inputText = ""
  snake = {}
  setupSnake(4)
end

function setupSnake(l)
  snake = {}
  if l == nil then l = 1 end
  for i = 1, l do
    table.insert(snake, {x = 100 - i * 10, y = 100})
  end
end

function love.textinput(t)
  if enterText then inputText = inputText .. t end
end

function love.keypressed(key)
  if key == "escape" then love.event.quit() end
  if key == "return" then enterText =  not enterText end
  if key == "backspace" then inputText = string.sub(inputText, 1, -2) end
  
  if not enterText then
    if key == "w" and direction ~= "down" then direction = "up" end
    if key == "s" and direction ~= "up" then direction = "down" end
    if key == "a" and direction ~= "right" then direction = "left" end
    if key == "d" and direction ~= "left" then direction = "right" end
  end
end

function love.keyreleased( key )
end

function love.update(dt)
  timer = timer + dt
  if not enterText then
    if timer > 0.1 then
      timer = timer - 0.1
      
      local pos = {x = snake[1].x, y = snake[1].y}
      table.remove(snake)
      if direction == "up" then pos.y = pos.y - 10 end
      if direction == "down" then pos.y = pos.y + 10 end
      if direction == "left" then pos.x = pos.x - 10 end
      if direction == "right" then pos.x = pos.x + 10 end
      table.insert(snake, 1, pos)
      
      -- keep snake in the window
      if pos.x <= 10 then direction = "right" end
      if pos.x >= love.graphics:getWidth() - 20 then direction = "left" end
      if pos.y <= 10 then direction = "down" end
      if pos.y >= love.graphics:getHeight() - 20 then direction = "up" end
    end
  end
end

function love.draw()
  love.graphics.print("Input text: " .. inputText, 10, 10)
  love.graphics.print("Snake length: " .. #snake, 10, 30)
  
  for i = 1, #snake do
    love.graphics.print(snake[i].x, 10, 40 + i * 10)
    love.graphics.print(snake[i].y, 40, 40 + i * 10)
    love.graphics.rectangle("fill", snake[i].x, snake[i].y, 10, 10)
  end
end