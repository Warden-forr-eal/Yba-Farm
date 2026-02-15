-- [[ SMART FARMER SOURCE ]]
local ItemsToKeep = {
    ["Lucky Arrow"] = true,
    ["Pure Rokakaka"] = true,
    ["Lucky Stone Mask"] = true,
    ["Rib Cage of The Saint's Corpse"] = true,
    ["Dio's Diary"] = true,
    ["Christmas Present"] = true
}

local Player = game.Players.LocalPlayer
local Root = Player.Character:WaitForChild("HumanoidRootPart")

-- SMART SELL: Only sells if NOT in KeepList
local function smartSell()
    local bp = Player:FindFirstChild("Backpack")
    if bp then
        for _, item in ipairs(bp:GetChildren()) do
            if not ItemsToKeep[item.Name] then
                game:GetService("Players").LocalPlayer.Character.RemoteEvent:FireServer("SellItem", item.Name)
                task.wait(0.1)
            end
        end
    end
end

-- SERVER HOPPER
local function serverHop()
    local Http = game:GetService("HttpService")
    local TPS = game:GetService("TeleportService")
    local Api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    pcall(function()
        local s = Http:JSONDecode(game:HttpGet(Api))
        for _, server in pairs(s.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                TPS:TeleportToPlaceInstance(game.PlaceId, server.id)
                return
            end
        end
    end)
end

-- MAIN LOOP
task.spawn(function()
    local foundItems = {}
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ClickDetector") or v:IsA("TouchTransmitter") then
            local p = v.Parent
            if p and (p:IsA("MeshPart") or p:IsA("Part") or p.Name == "Handle") then
                if p.Size.Magnitude < 5 and not p:IsDescendantOf(Player.Character) then
                    table.insert(foundItems, p)
                end
            end
        end
    end

    if #foundItems > 0 then
        for _, item in ipairs(foundItems) do
            Root.CFrame = item.CFrame
            task.wait(0.5)
            firetouchtransmitter(item, Root, 0)
            firetouchtransmitter(item, Root, 1)
            local cd = item:FindFirstChildOfClass("ClickDetector") or item.Parent:FindFirstChildOfClass("ClickDetector")
            if cd then fireclickdetector(cd) end
        end
        task.wait(1)
        smartSell()
    end
    task.wait(1)
    serverHop()
end)

task.delay(40, function() serverHop() end)
