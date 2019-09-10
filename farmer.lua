--
-- Created by IntelliJ IDEA.
-- User: Robyn
-- Date: 9/5/2019
-- Time: 11:27 PM
-- To change this template use File | Settings | File Templates.
--
local constants = require("constants")

function refuel()
    local success = true

    if turtle.getFuelLevel() == 0 then
        --Try to refuel from selected slot initially
        success = turtle.refuel(1)

        if not success then
            --Scan for fuel and refuel by 1 unit
            for i=1,16 do
                turtle.select(i)
                success = turtle.refuel(1)
                if success then break end
            end
        end
    end

    return success
end

function getRequiredFuel(width, length)
    return width*length + (width - 1)*(length % 2) + length
end

function getTotalFuel()
    --Initial fuel
    local total = turtle.getFuelLevel()

    --Scan for fuel items, and calculate total fuel
    for i=1,16 do
        local itemData = turtle.getItemDetail(i)

        if itemData then
            local fuelMultiplier = constants.fuelValues[itemData.name]

            if fuelMultiplier then
                total = total + itemData.count*fuelMultiplier
            end
        end
    end

    return total
end

--Moves forward, collects wheat, and places the seed
function doFarm()
    refuel()
    turtle.forward()

    turtle.digDown()
    turtle.suckDown()

    --Scan for seeds and select the slot
    for i=1,16 do
        local itemData = turtle.getItemDetail(i)

        if itemData and itemData.name == "minecraft:wheat_seeds" then
            turtle.select(i)
            break
        end
    end

    turtle.placeDown()
end


--BEGIN MAIN SCRIPT
rednet.open("right")

--Initialize label and host
local computerId = os.getComputerID()
local label = "Farmer " .. computerId

os.setComputerLabel(label)
rednet.host(constants.farmProtocol, label)

while true do
    --Listen for commands from controller
    local controllerId, message = rednet.receive(constants.farmProtocol)

    --Handle status check
    if message.type == constants.checkStatusMessage then

        --Refuel, check required fuel levels, and report back to controller
        local responseMessage
        local fuelStatus = refuel()
        local requiredFuel = getRequiredFuel(args[1] or constants.farmWidth, args[2] or constants.farmLength)
        local totalFuel = getTotalFuel()

        if not fuelStatus then
            responseMessage = { type = constants.noFuelMessage }
        elseif totalFuel < requiredFuel then
            responseMessage = {
                type = constants.notEnoughFuelMessage,
                requiredFuel = requiredFuel,
                totalFuel = totalFuel
            }
        else responseMessage = { type = constants.readyMessage }
        end

        --Wait until controller is ready to receive, then send response
        sleep(2)
        rednet.send(controllerId, responseMessage, constants.farmProtocol)

    --Handle signal to start farming
    elseif message.type == constants.startMessage then

        --Variables to keep track of position
        local x = 0
        local y = -1
        local xCounter = 0
        local yCounter = 1

        --Repeat a zigzag pattern within the farm boundaries
        repeat
            doFarm()
            x = x + xCounter
            y = y + yCounter

            --Handle turns
            if x == 0 and y % 2 == 0 then
                turtle.turnRight()
                xCounter = 1
                yCounter = 0
            elseif x == 0 and y % 2 == 1 then
                turtle.turnRight()
                xCounter = 0
                yCounter = 1
            elseif x == constants.farmWidth - 1 and y % 2 == 1 then
                turtle.turnLeft()
                xCounter = -1
                yCounter = 0
            elseif x == constants.farmWidth - 1 and y % 2 == 0 then
                turtle.turnLeft()
                xCounter = 0
                yCounter = 1
            end

        until y == constants.farmLength - 1 and ((x == 0 and constants.farmLength % 2 == 0) or (x == constants.farmWidth - 1 and constants.farmLength % 2 == 1))

        --If x coord needs adjusting, move left
        if x == constants.farmWidth - 1 then
            turtle.turnLeft()
            for i=1, constants.farmWidth - 1 do
                turtle.forward()
            end
            turtle.turnRight()
        end

        for i=1, constants.farmLength do
            turtle.back()
        end

        --Finished farming
        rednet.send(controllerId, { type = constants.finishedMessage }, constants.farmProtocol)
    end
end