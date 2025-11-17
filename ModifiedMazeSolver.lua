
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

-- Position tracking for loop detection using relative coordinates
local positionHistory = {}
local maxHistorySize = 15
local currentX, currentY = 0, 0
local currentDirection = 0 -- 0=North, 1=East, 2=South, 3=West
local turnCounter = 0 -- Count consecutive turns without forward movement
local maxTurns = 3 -- Maximum turns before forcing forward movement
local visitCounts = {} -- Track how many times we've visited each position
local maxVisits = 3 -- Maximum visits before seeking least visited neighbor

-- Update position based on movement
function updatePosition()
    if currentDirection == 0 then -- North
        currentY = currentY + 1
    elseif currentDirection == 1 then -- East
        currentX = currentX + 1
    elseif currentDirection == 2 then -- South
        currentY = currentY - 1
    else -- West
        currentX = currentX - 1
    end
end

-- Update direction based on turns
function updateDirection(turn)
    if turn == "left" then
        currentDirection = (currentDirection - 1) % 4
    elseif turn == "right" then
        currentDirection = (currentDirection + 1) % 4
    elseif turn == "around" then
        currentDirection = (currentDirection + 2) % 4
    end
end

-- Add current position to history and track visit counts
function addPositionToHistory()
    local posKey = currentX .. "," .. currentY
    table.insert(positionHistory, posKey)
    
    -- Track visit count for this position
    visitCounts[posKey] = (visitCounts[posKey] or 0) + 1
    
    -- Keep history size manageable
    if #positionHistory > maxHistorySize then
        table.remove(positionHistory, 1)
    end
end

-- Get visit count for a position
function getVisitCount(x, y)
    local posKey = x .. "," .. y
    return visitCounts[posKey] or 0
end

-- Get the position coordinates for a direction from current position
function getPositionInDirection(direction)
    local newX, newY = currentX, currentY
    local actualDirection = (currentDirection + direction) % 4
    
    if actualDirection == 0 then -- North
        newY = newY + 1
    elseif actualDirection == 1 then -- East
        newX = newX + 1
    elseif actualDirection == 2 then -- South
        newY = newY - 1
    else -- West
        newX = newX - 1
    end
    
    return newX, newY
end

-- Find the direction to the least visited adjacent block
function findLeastVisitedDirection()
    local directions = {
        {dir = 0, name = "forward", canGo = not isWallAhead()},
        {dir = 1, name = "right", canGo = not isWallRight()},
        {dir = 3, name = "left", canGo = not isWallLeft()}
    }
    
    local bestDirection = nil
    local lowestVisitCount = math.huge
    
    for _, dirInfo in ipairs(directions) do
        if dirInfo.canGo then
            local newX, newY = getPositionInDirection(dirInfo.dir)
            local visitCount = getVisitCount(newX, newY)
            
            print("Direction " .. dirInfo.name .. " leads to position (" .. newX .. "," .. newY .. ") with " .. visitCount .. " visits")
            
            if visitCount < lowestVisitCount then
                lowestVisitCount = visitCount
                bestDirection = dirInfo
            end
        end
    end
    
    return bestDirection, lowestVisitCount
end

-- Check if current position has been visited too many times
function isOverVisited()
    local currentPos = currentX .. "," .. currentY
    local visits = visitCounts[currentPos] or 0
    return visits >= maxVisits
end

-- Check if we're in a loop by looking for repeated positions
function isInLoop()
    if #positionHistory < 8 then
        return false
    end
    
    -- Check if we're visiting the same small area repeatedly
    local recentPositions = {}
    local uniquePositions = {}
    
    -- Look at the last 8 positions
    for i = math.max(1, #positionHistory - 7), #positionHistory do
        local pos = positionHistory[i]
        recentPositions[pos] = (recentPositions[pos] or 0) + 1
        uniquePositions[pos] = true
    end
    
    -- Count unique positions in recent history
    local uniqueCount = 0
    for _ in pairs(uniquePositions) do
        uniqueCount = uniqueCount + 1
    end
    
    -- If we're only visiting 2-4 unique positions repeatedly, we're likely in a loop
    if uniqueCount <= 4 then
        for pos, count in pairs(recentPositions) do
            if count >= 2 then
                print("Loop detected: visiting " .. uniqueCount .. " unique positions, position " .. pos .. " visited " .. count .. " times")
                return true
            end
        end
    end
    
    return false
end

-- Break out of a loop by trying a more aggressive strategy
function breakLoop()
    print("Loop detected! Attempting to break free from 3x3 area...")
    
    -- Clear position history to start fresh
    positionHistory = {}
    
    -- Strategy: Move in a straight line as far as possible to escape the loop area
    print("Trying to escape loop by moving in straight lines...")
    
    -- Try each direction systematically to find the best escape route
    local directions = {"forward", "right", "left", "back"}
    
    for _, direction in ipairs(directions) do
        print("Trying to escape by going " .. direction)
        
        -- Orient to the chosen direction
        if direction == "right" then
            turnRight()
            updateDirection("right")
        elseif direction == "left" then
            turnLeft()
            updateDirection("left")
        elseif direction == "back" then
            turnAround()
            updateDirection("around")
        end
        -- "forward" requires no turning
        
        -- Try to move as far as possible in this direction
        local moveCount = 0
        local maxMoves = 6 -- Move far enough to escape a 3x3 area
        
        while moveCount < maxMoves and not isWallAhead() do
            moveForward()
            updatePosition()
            moveCount = moveCount + 1
            print("Escape move " .. moveCount .. " in direction " .. direction)
            
            -- Check if we found the exit while escaping
            if isOnYellowConcrete() then
                print("Found exit while escaping loop!")
                return true
            end
        end
        
        -- If we moved at least 3 spaces, we likely escaped the loop
        if moveCount >= 3 then
            print("Successfully escaped loop by moving " .. moveCount .. " steps " .. direction)
            return false
        end
        
        -- If this direction didn't work, try the next one
        -- First return to original orientation
        if direction == "right" then
            turnLeft()
            updateDirection("left")
        elseif direction == "left" then
            turnRight()
            updateDirection("right")
        elseif direction == "back" then
            turnAround()
            updateDirection("around")
        end
    end
    
    print("Could not escape loop with straight line movement, trying random walk...")
    
    -- Last resort: random movement pattern
    for i = 1, 10 do
        local randomDir = math.random(1, 3)
        if randomDir == 1 and not isWallLeft() then
            turnLeft()
            updateDirection("left")
            moveForward()
            updatePosition()
        elseif randomDir == 2 and not isWallRight() then
            turnRight()
            updateDirection("right")
            moveForward()
            updatePosition()
        elseif not isWallAhead() then
            moveForward()
            updatePosition()
        end
        
        if isOnYellowConcrete() then
            print("Found exit during random walk!")
            return true
        end
    end
    
    print("Loop breaking completed, resuming normal maze solving...")
    return false
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
        
        -- Add current position to history for loop detection
        addPositionToHistory()
        
        -- Check for loops and break them
        if isInLoop() then
            local brokeLoop = breakLoop()
            if brokeLoop then
                -- Continue with normal algorithm after breaking loop
            end
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
            -- Check if current position is over-visited
            local currentVisits = getVisitCount(currentX, currentY)
            print("Current position (" .. currentX .. "," .. currentY .. ") visited " .. currentVisits .. " times")
            
            if isOverVisited() then
                -- Find the least visited adjacent block
                local bestDirection, lowestVisits = findLeastVisitedDirection()
                
                if bestDirection then
                    print("Over-visited position! Moving to least visited direction: " .. bestDirection.name .. " (visits: " .. lowestVisits .. ")")
                    
                    if bestDirection.name == "forward" then
                        moveForward()
                        updatePosition()
                        turnCounter = 0
                        print("Moved to least visited block forward (step " .. steps .. ")")
                    elseif bestDirection.name == "right" then
                        turnRight()
                        updateDirection("right")
                        moveForward()
                        updatePosition()
                        turnCounter = 0
                        print("Moved to least visited block right (step " .. steps .. ")")
                    elseif bestDirection.name == "left" then
                        turnLeft()
                        updateDirection("left")
                        moveForward()
                        updatePosition()
                        turnCounter = 0
                        print("Moved to least visited block left (step " .. steps .. ")")
                    end
                else
                    -- No available directions, turn around
                    turnAround()
                    updateDirection("around")
                    turnCounter = 0
                    print("No available directions from over-visited position - turned around (step " .. steps .. ")")
                end
            else
                -- Normal maze solving: prioritize turns over going forward, but limit consecutive turns
                local canGoLeft = not isWallLeft()
                local canGoRight = not isWallRight()
                local canGoForward = not isWallAhead()
                
                print("Step " .. steps .. " - Left=" .. tostring(canGoLeft) .. ", Right=" .. tostring(canGoRight) .. ", Forward=" .. tostring(canGoForward) .. ", TurnCount=" .. turnCounter)
                
                -- If we've made too many turns, force forward movement
                if turnCounter >= maxTurns and canGoForward then
                    moveForward()
                    updatePosition()
                    turnCounter = 0 -- Reset turn counter after moving forward
                    print("Forced forward movement after " .. maxTurns .. " turns (step " .. steps .. ")")
                elseif canGoLeft and turnCounter < maxTurns then
                    -- Prioritize left turns (but only if under turn limit)
                    turnLeft()
                    updateDirection("left")
                    moveForward()
                    updatePosition()
                    turnCounter = turnCounter + 1
                    print("Turned left and moved forward (step " .. steps .. ", turn count: " .. turnCounter .. ")")
                elseif canGoRight and turnCounter < maxTurns then
                    -- Then prioritize right turns (but only if under turn limit)
                    turnRight()
                    updateDirection("right")
                    moveForward()
                    updatePosition()
                    turnCounter = turnCounter + 1
                    print("Turned right and moved forward (step " .. steps .. ", turn count: " .. turnCounter .. ")")
                elseif canGoForward then
                    -- Move forward if no turns available or turn limit reached
                    moveForward()
                    updatePosition()
                    turnCounter = 0 -- Reset turn counter after moving forward
                    print("Moved forward (step " .. steps .. ")")
                else
                    -- Dead end - turn around
                    turnAround()
                    updateDirection("around")
                    turnCounter = 0 -- Reset turn counter after turning around
                    print("Dead end - turned around (step " .. steps .. ")")
                end
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
