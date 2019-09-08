
function fetchFile(fileName)
    local shortName = string.match(fileName, "/[^/]+$"):sub(2)
    local file = io.open(shortName, "w")
    local response = http.get(fileName)

    file:write(response.readAll())
    file:flush()
end

local filesToDownload = {
    "https://raw.githubusercontent.com/robyn-dressler/AutoFarm/master/constants.lua",
    "https://raw.githubusercontent.com/robyn-dressler/AutoFarm/master/farmer.lua",
    "https://raw.githubusercontent.com/robyn-dressler/AutoFarm/master/farmController.lua"
}

for key, url in pairs(filesToDownload) do
    print("Downloading " .. url)
    fetchFile(url)
end
