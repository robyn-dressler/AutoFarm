--
-- Created by IntelliJ IDEA.
-- User: Robyn
-- Date: 9/5/2019
-- Time: 11:38 PM
-- To change this template use File | Settings | File Templates.
--
local constants = {
    farmProtocol = "farm",
    checkStatusMessage = "checkStatus",
    startMessage = "startFarm",
    readyMessage = "ready",
    noFuelMessage = "noFuel",
    notEnoughFuelMessage = "notEnoughFuel",
    finishedMessage = "finishedMessage",
    farmWidth = 10,
    farmLength = 10,
    fuelValues = {
        ["minecraft:coal"] = 80,
        ["minecraft:coal_block"] = 720,
        ["railcraft:fuel.coke"] = 320
    }
}

return constants