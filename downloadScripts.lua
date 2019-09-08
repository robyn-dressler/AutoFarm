
function fetchFile(fileName)
    local shortName = string.match(fileName, "[^/]+\.[^/]+$")
    local file = io.open(shortName, "w")
    local response = http.get(fileName)

    file:write(response.readAll())
end

local filesToDownload = {
    "https://raw.githubusercontent.com/robyn-dressler/AutoFarm/master/constants.lua",
    "https://raw.githubusercontent.com/robyn-dressler/AutoFarm/master/farmer.lua",
    "https://raw.githubusercontent.com/robyn-dressler/AutoFarm/master/farmController.lua"
}

for url in filesToDownload do
    fetchFile(url)
end
