--
-- Created by IntelliJ IDEA.
-- User: Robyn
-- Date: 9/1/2019
-- Time: 4:03 PM
-- To change this template use File | Settings | File Templates.
--
local constants = require("constants")


function convertToTable(...)
    return {...}
end

--BEGIN MAIN SCRIPT
rednet.open("back")

--Sync with available farmers
local farmers = convertToTable(rednet.lookup(constants.farmProtocol))
local ready = true
local farmerCount = 0

--Check farmers' statuses
for key, farmerId in pairs(farmers) do
    farmerCount = farmerCount + 1

    print("Checking status of farmer " .. farmerId)
    rednet.send(farmerId, { type = constants.checkStatusMessage }, constants.farmProtocol)

    local id, message = rednet.receive(constants.farmProtocol)

    if message.type == constants.noFuelMessage then
        print("ERROR: Farmer " .. id .. " has no fuel!")
        ready = false

    elseif message.type == constants.notEnoughFuelMessage then
        print("Farmer " .. id .. " doesn't have enough fuel. Required fuel: " .. message.requiredFuel .. " Current fuel: " .. message.totalFuel)
        ready = false

    elseif message.type == constants.readyMessage then
        print("Farmer " .. id .. " is ready!")
    end
end

if not ready then
   return
else
    --Activate farmers
    print("Activating all farmers...")
    rednet.broadcast({ type = constants.startMessage }, constants.farmProtocol)

    print("Farming in progress...")

    --Wait for farmers to finish
    while farmerCount > 0 do
        local id, message = rednet.receive(constants.farmProtocol)
        if message.type == constants.finishedMessage then
            print("Farmer " .. id .. " finished farming!")
        end
    end

    println("Farming completed!")
end
