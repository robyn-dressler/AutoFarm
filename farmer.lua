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


--BEGIN MAIN SCRIPT
rednet.open("right")

--Initialize label and host
local computerId = os.getComputerID()
local label = "Farmer " .. computerId

os.setComputerLabel(label)
rednet.host(1, label)

--Listen for commands from controller
local controllerId, message = rednet.receive(constants.farmProtocol)

if message == constants.startMessage then
    local responseMessage
    local fuelStatus = refuel()

    if not fuelStatus then responseMessage = constants.noFuelMessage
    else responseMessage = constants.readyMessage
    end

    rednet.send(controllerId, responseMessage, constants.farmProtocol)
end