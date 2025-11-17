
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

-- Check if we're in an open area (no walls on any side)
function isInOpenArea()
    return not isWallAhead() and not isWallLeft() and not isWallRight()
end

-- Find and follow a wall to get out of open areas
function followWallToExit()
    print("In open area - searching for wall to follow...")
    local searchSteps = 0
    local maxSearchSteps = 50
    
    -- First, try to find a wall by moving in a spiral pattern
    while searchSteps < maxSearchSteps and isInOpenArea() do
        searchSteps = searchSteps + 1
        
        -- Move forward a few steps
        for i = 1, searchSteps do
            if not isInOpenArea() then
                break
            end
            moveForward()
            if isOnYellowConcrete() then
                return true -- Found the exit!
            end
        end
        
        -- Turn right and continue spiral
        turnRight()
        
        if not isInOpenArea() then
            break
        end
    end
    
    -- Now follow the wall using right-hand rule until we're out of the open area
    print("Found wall - following it to exit open area...")
    local wallFollowSteps = 0
    local maxWallFollowSteps = 100
    
    while wallFollowSteps < maxWallFollowSteps do
        wallFollowSteps = wallFollowSteps + 1
        
        -- Right-hand wall following
        if not isWallRight() then
            turnRight()
            if not isWallAhead() then
                moveForward()
            else
                turnLeft()
            end
        elseif not isWallAhead() then
            moveForward()
        elseif not isWallLeft() then
            turnLeft()
        else
            turnAround()
        end
        
        if isOnYellowConcrete() then
            return true -- Found the exit!
        end
        
        -- Check if we're out of the open area (have walls around us again)
        if not isInOpenArea() then
            print("Exited open area - returning to normal maze solving")
            return false
        end
        
        sleep(0.3)
    end
    
    return false
end

-- Main maze solving function - hybrid approach
function solveMaze()
    print("Starting maze solving...")
    local steps = 0
    local maxSteps = 1000  -- Prevent infinite loops
    
    while steps < maxSteps do
        steps = steps + 1
        
        -- Check if we've reached the yellow concrete block (maze exit)
        if isOnYellowConcrete() then
            print("Yellow concrete block found - maze solved!")
            break
        end
        
        -- Check if we're in an open area without walls
        if isInOpenArea() then
            print("Detected open area at step " .. steps)
            local foundExit = followWallToExit()
            if foundExit then
                print("Found exit while following wall!")
                break
            end
            -- Continue with normal algorithm after exiting open area
        else
            -- Normal maze solving: prioritize turns over going forward
            local canGoLeft = not isWallLeft()
            local canGoRight = not isWallRight()
            local canGoForward = not isWallAhead()
            
            print("Step " .. steps .. " - Left=" .. tostring(canGoLeft) .. ", Right=" .. tostring(canGoRight) .. ", Forward=" .. tostring(canGoForward))
            
            if canGoLeft then
                -- Prioritize left turns
                turnLeft()
                moveForward()
                print("Turned left and moved forward (step " .. steps .. ")")
            elseif canGoRight then
                -- Then prioritize right turns
                turnRight()
                moveForward()
                print("Turned right and moved forward (step " .. steps .. ")")
            elseif canGoForward then
                -- Move forward only if no turns available
                moveForward()
                print("Moved forward (step " .. steps .. ")")
            else
                -- Dead end - turn around
                turnAround()
                print("Dead end - turned around (step " .. steps .. ")")
            end
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
