function love.load()
  love.window.setMode(600, 400)
  posY = love.graphics:getHeight() * 0.5
  posX = love.graphics:getWidth() * 0.5
  timer = 0
  direction = "right"
  enterText = false
  inputText = ""
  snakeX = {}
  snakeY = {}
  setupSnake(4)
end

function setupSnake(l)
  snakeX = {}
  snakeY = {}
  
  if l == nil then l = 1 end
  
  for i = 1, l do
    table.insert(snakeX, 100 - i * 10)
    table.insert(snakeY, 100)
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
    --[[if key == "w" or key == "s" or key == "a" or key == "d" then
      local x = snakeX[1]
      local y = snakeY[1]
      
      table.remove(snakeX)
      table.remove(snakeY)
      
      if key == "w" then y = y - 10 end
      if key == "s" then y = y + 10 end
      if key == "a" then x = x - 10 end
      if key == "d" then x = x + 10 end
      
      table.insert(snakeX, 1, x)
      table.insert(snakeY, 1, y)

      end--]]
  end
end

function love.keyreleased( key )
end

function love.update(dt)
  timer = timer + dt
  if not enterText then
    if love.keyboard.isDown("up") then posY = posY - 100 * dt end
    if love.keyboard.isDown("down") then posY = posY + 100 * dt end
    if love.keyboard.isDown("right") then posX = posX + 100 * dt end
    if love.keyboard.isDown("left") then posX = posX - 100 * dt end
    
    if timer > 0.2 then
      timer = 0
      local x = snakeX[1]
      local y = snakeY[1]
      table.remove(snakeX)
      table.remove(snakeY)
      if direction == "up" then y = y - 10 end
      if direction == "down" then y = y + 10 end
      if direction == "left" then x = x - 10 end
      if direction == "right" then x = x + 10 end
      table.insert(snakeX, 1, x)
      table.insert(snakeY, 1, y)
      
      -- keep snake in the window
      if x <= 10 then direction = "right" end
      if x >= love.graphics:getWidth() - 20 then direction = "left" end
      if y <= 10 then direction = "down" end
      if y >= love.graphics:getHeight() - 20 then direction = "up" end
    end
  end
end

function love.draw()
  love.graphics.rectangle("fill", posX, posY, 32, 32)
  love.graphics.print('Hello World!', posX, posY)
  love.graphics.print(inputText, 20, 20)
  love.graphics.print("Snake length: " .. #snakeX, 20, 40)

  for i = 1, #snakeX do
    love.graphics.print(snakeX[i], 20, 50 + i * 10)
    love.graphics.print(snakeY[i], 50, 50 + i * 10)
    
    love.graphics.rectangle("fill", snakeX[i], snakeY[i], 10, 10)
  end
end