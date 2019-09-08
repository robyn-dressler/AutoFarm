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
    rednet.send(farmerId, constants.startMessage, constants.farmProtocol)

    local id, message = rednet.receive(constants.farmProtocol)

    if message == constants.noFuelMessage then
        print("ERROR: Farmer " .. id .. " has no fuel!")
    elseif message == constants.readyMessage then
        print("Farmer " .. id .. " is ready!")
    end
end

if not ready then
   exit()
end
