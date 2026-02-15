-- [[ THE NUCLEAR SEARCH ]]
local ItemsToKeep = {["Lucky Arrow"] = true, ["Pure Rokakaka"] = true, ["Lucky Stone Mask"] = true, ["Rib Cage of The Saint's Corpse"] = true, ["Dio's Diary"] = true}

local Player = game.Players.LocalPlayer
local Root = Player.Character:WaitForChild("HumanoidRootPart")

local function getRealItems()
    local found = {}
    -- We are looking for ProximityPrompts - the NEW way YBA handles items
    for _, v in ipairs(game:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            local item = v.Parent
            if item:IsA("BasePart") or item:IsA("Model") then
                table.insert(found, item)
            end
        -- Fallback for older items with TouchTransmitters
        elseif v:IsA("TouchTransmitter") and v.Parent.Name == "Handle" then
            table.insert(found, v.Parent)
        end
    end
    return found
end

task.spawn(function()
    local list = getRealItems()
    if #list > 0 then
        for _, obj in ipairs(list) do
            local targetPos = obj:IsA("Model") and obj:GetModelCFrame() or obj.CFrame
            Root.CFrame = targetPos
            task.wait(1) -- Wait for Hydrogen to sync
            
            -- Pickup Spam
            fireproximityprompt(obj:FindFirstChildOfClass("ProximityPrompt") or obj)
            fireclickdetector(obj:FindFirstChildOfClass("ClickDetector") or obj)
            firetouchtransmitter(obj:IsA("Model") and obj.PrimaryPart or obj, Root, 0)
        end
        -- Sell Logic
        for _, item in ipairs(Player.Backpack:GetChildren()) do
            if not ItemsToKeep[item.Name] then
                game:GetService("Players").LocalPlayer.Character.RemoteEvent:FireServer("SellItem", item.Name)
            end
        end
    end
    task.wait(2)
    -- HOP
    local s = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
    for _, server in pairs(s.data) do
        if server.playing < server.maxPlayers and server.id ~= game.JobId then
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, server.id)
        end
    end
end)
