
-- Maze solving turtle program using right-hand wall following algorithm
-- This can handle mazes with left and right turns

-- Movement functions
function moveForward()
    if turtle.forward() then
        return true
    else
        return false
    end
end

function turnLeft()
    turtle.turnLeft()
end

function turnRight()
    turtle.turnRight()
end

function turnAround()
    turtle.turnRight()
    turtle.turnRight()
end

-- Check if there's a wall in front
function isWallAhead()
    return turtle.detect()
end

-- Check if there's a wall to the right
function isWallRight()
    turtle.turnRight()
    local hasWall = turtle.detect()
    turtle.turnLeft()
    return hasWall
end

-- Check if there's a wall to the left
function isWallLeft()
    turtle.turnLeft()
    local hasWall = turtle.detect()
    turtle.turnRight()
    return hasWall
end

-- Check if we're standing on a yellow concrete block (maze exit)
function isOnYellowConcrete()
    local success, data = turtle.inspectDown()
    if success then
        return data.name == "minecraft:yellow_concrete"
    end
    return false
end

-- Main maze solving function using right-hand rule
function solveMaze()
    print("Starting maze solving...")
    local steps = 0
    local maxSteps = 1000  -- Prevent infinite loops
    
    while steps < maxSteps do
        steps = steps + 1
        
        -- Right-hand wall following algorithm:
        -- 1. If you can turn right, turn right and move forward
        -- 2. Else if you can move forward, move forward
        -- 3. Else if you can turn left, turn left
        -- 4. Else turn around
        
        if not isWallRight() then
            -- Can turn right - do it and move forward
            turnRight()
            if not isWallAhead() then
                moveForward()
                print("Turned right and moved forward (step " .. steps .. ")")
            else
                -- Wall appeared after turning right, turn back left
                turnLeft()
            end
        elseif not isWallAhead() then
            -- Can move forward
            moveForward()
            print("Moved forward (step " .. steps .. ")")
        elseif not isWallLeft() then
            -- Can turn left
            turnLeft()
            print("Turned left (step " .. steps .. ")")
        else
            -- Dead end - turn around
            turnAround()
            print("Dead end - turned around (step " .. steps .. ")")
        end
        
        -- Check if we've reached the yellow concrete block (maze exit)
        if isOnYellowConcrete() then
            print("Yellow concrete block found - maze solved!")
            break
        end
        
        -- Small delay to make it easier to follow
        sleep(0.5)
    end
    
    if steps >= maxSteps then
        print("Maximum steps reached - stopping to prevent infinite loop")
    else
        print("Maze solving completed in " .. steps .. " steps!")
    end
end

-- Alternative simple maze solver that tries all directions
function solveMazeSimple()
    print("Starting simple maze solving...")
    local steps = 0
    local maxSteps = 500
    
    while steps < maxSteps do
        steps = steps + 1
        
        -- Try to move forward first
        if not isWallAhead() then
            moveForward()
            print("Moved forward (step " .. steps .. ")")
        else
            -- Try turning right
            turnRight()
            if not isWallAhead() then
                moveForward()
                print("Turned right and moved forward (step " .. steps .. ")")
            else
                -- Try turning left (from original position)
                turnLeft()  -- Back to original direction
                turnLeft()  -- Now facing left
                if not isWallAhead() then
                    moveForward()
                    print("Turned left and moved forward (step " .. steps .. ")")
                else
                    -- Turn around
                    turnLeft()  -- Back to original
                    turnLeft()  -- Now facing back
                    if not isWallAhead() then
                        moveForward()
                        print("Turned around and moved forward (step " .. steps .. ")")
                    else
                        print("Completely stuck!")
                        break
                    end
                end
            end
        end
        
        sleep(0.3)
    end
    
    print("Simple maze solving completed!")
end

-- Run the maze solver
print("Turtle Maze Solver")
print("Choose solving method:")
print("1. Right-hand wall following (recommended)")
print("2. Simple direction trying")

-- For automatic execution, use the right-hand rule
solveMaze()
