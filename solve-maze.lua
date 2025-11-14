
local function victory()
    print("We finished the maze!")
    turtle.up()
    for _ = 1,4 do
        turtle.turnRight()
    end    
end

local function look()
    local ok, data = turtle.inspectDown()
    
    if ok and data.name:find("green") then
        print("At start")
    end
    
    if ok and data.name:find("yellow") then
      victory()
      return true
    end  
    
    return false
end

turtle.refuel(10)
if turtle.getFuelLevel() < 10 then
    print("Insert fuel in slot 1")
    return
end

while true do
    local done = look()
    if done then
        return
    end

    -- Idea:
    -- While we dect a block
    -- forward, turn right.
    
local function detectLeft()
    turtle.turnLeft()
    local rv = turtle.detect()
    turtle.turnRight()
    return rv
end

local function detectRight()
    turtle.turnRight()
    local rv = turtle.detect()
    turtle.turnLeft()
    return rv
end

local dr = detectRight()
local dl = detectLeft()
print (" "..dr.." "..dl)
if not (dl or dr) then
    turtle.forward()
end



end
