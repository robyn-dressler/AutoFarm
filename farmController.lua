--
-- Created by IntelliJ IDEA.
-- User: Robyn
-- Date: 9/1/2019
-- Time: 4:03 PM
-- To change this template use File | Settings | File Templates.
--
require("constants")


function convertToTable(...)
    return {...}
end

--BEGIN MAIN SCRIPT
rednet.open("back")

--Sync with available farmers
local farmers = convertToTable(rednet.lookup(farmProtocol))
local ready = true

--Activate farmers
for farmerId in farmers do
    print("Activating farmer " .. farmerId)
    rednet.send(farmerId, startMessage, farmProtocol)
    local id, message = rednet.receive(farmProtocol)

    if message == noFuelMessage then
        print("ERROR: Farmer " .. id .. " has no fuel!")
    elseif message == readyMessage then
        print("Farmer " .. id .. " is ready!")
    end
end

if not ready then
   exit()
end
