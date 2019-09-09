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

--Activate farmers
for key, farmerId in pairs(farmers) do
    print("Activating farmer " .. farmerId)
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
   exit()
end
