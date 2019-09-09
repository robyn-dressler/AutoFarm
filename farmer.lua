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


--BEGIN MAIN SCRIPT
rednet.open("right")

--Initialize label and host
local computerId = os.getComputerID()
local label = "Farmer " .. computerId

os.setComputerLabel(label)
rednet.host(constants.farmProtocol, label)

--Listen for commands from controller
local controllerId, message = rednet.receive(constants.farmProtocol)

if message.type == constants.checkStatusMessage then
    local responseMessage
    local fuelStatus = refuel()
    local requiredFuel = getRequiredFuel(constants.farmWidth, constants.farmLength)
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
end