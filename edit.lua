local function digDownForward()                                                 
                                                                                
    print("Starting to dig down and forward until bedrock...")                  
                                                                                
                                                                                
                                                                                
    while true do                                                               
                                                                                
        -- Dig down                                                             
                                                                                
        while turtle.detectDown() do                                            
                                                                                
            if not turtle.digDown() then                                        
                                                                                
                print("Hit bedrock or couldn't dig down!")                      
                                                                                
                return                                                          
                                                                                
            end                                                                 
                                                                                
        end                                                                     
                                                                                
                                                                                
                                                                                
        -- Move down                                                            
                                                                                
        if not turtle.down() then                                               
                                                                                
            print("Couldn't move down, possibly at bedrock level!")             
                                                                                
            return                                                              
                                                                                
        end                                                                     
                                                                                
                                                                                
                                                                                
        -- Dig forward                                                          
                                                                                
        while turtle.detect() do                                                
                                                                                
            if not turtle.dig() then                                            
                                                                                
                print("Hit bedrock or couldn't dig forward!")                   
                                                                                
                return                                                          
                                                                                
            end                                                                 
                                                                                
        end                                                                     
                                                                                
                                                                                
                                                                                
        -- Move forward                                                         
                                                                                
        if not turtle.forward() then                                            
                                                                                
            print("Couldn't move forward!")                                     
                                                                                
            return                                                              
                                                                                
        end                                                                     
                                                                                
    end                                                                         
                                                                                
end                                                                             
                                                                                
                                                                                
                                                                                
-- Refuel the turtle at the start                                               
                                                                                
local function refuel()                                                         
                                                                                
    turtle.select(1)                                                            
                                                                                
    while turtle.getFuelLevel() < 10 do                                         
                                                                                
        turtle.refuel(1)                                                        
                                                                                
    end                                                                         
                                                                                
    print("Current fuel: " .. turtle.getFuelLevel())                            
                                                                                
end                                                                             
                                                                                
                                                                                
                                                                                
refuel()                                                                        
                                                                                
digDownForward()                                                                
                                                                                
print("Finished digging.")    
