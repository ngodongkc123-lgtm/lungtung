getgenv().Config = {
    ['Areas'] = {
        "1 | Spawn",
        "2 | Colorful Forest",
        "3 | Castle",
        "4 | Green Forest",
        "5 | Autumn",
        "6 | Cherry Blossom",
        "7 | Farm",
        "8 | Backyard",
        "9 | Misty Falls",
        "10 | Mine",
        "11 | Crystal Caverns",
        "12 | Dead Forest",
        "13 | Dark Forest",
        "14 | Mushroom Field",
        "15 | Enchanted Forest",
        "16 | Crimson Forest",
        "17 | Jungle",
        "18 | Jungle Temple",
        "19 | Oasis",
        "20 | Beach",
        "21 | Coral Reef",
        "22 | Shipwreck",
        "23 | Atlantis",
        "24 | Palm Beach",
        "25 | Tiki",
        "26 | Pirate Cove",
        "27 | Pirate Tavern",
        "28 | Shanty Town",
        "29 | Desert Village",
        "30 | Fossil Digsite",
        "31 | Desert Pyramids",
        "32 | Red Desert",
        "33 | Wild West",
        "34 | Grand Canyons",
        "35 | Safari",
        "36 | Mountains",
        "37 | Snow Village",
        "38 | Icy Peaks",
        "39 | Ice Rink",
        "40 | Ski Town",
        "41 | Hot Springs",
        "42 | Fire and Ice",
        "43 | Volcano",
        "44 | Obsidian Cave",
        "45 | Lava Forest",
        "46 | Underworld",
        "47 | Underworld Bridge",
        "48 | Underworld Castle",
        "49 | Metal Dojo",
        "50 | Fire Dojo",
        "51 | Samurai Village",
        "52 | Bamboo Forest",
        "53 | Zen Garden",
        "54 | Flower Field",
        "55 | Fairytale Meadows",
        "56 | Fairytale Castle",
        "57 | Royal Kingdom",
        "58 | Fairy Castle",
        "59 | Cozy Village",
        "60 | Rainbow River",
        "61 | Colorful Mines",
        "62 | Colorful Mountains",
        "63 | Frost Mountains",
        "64 | Ice Sculptures",
        "65 | Snowman Town",
        "66 | Ice Castle",
        "67 | Polar Express",
        "68 | Firefly Cold Forest",
        "69 | Golden Road",
        "70 | No Path Forest",
        "71 | Ancient Ruins",
        "72 | Runic Altar",
        "73 | Wizard Tower",
        "74 | Witch Marsh",
        "75 | Haunted Forest",
        "76 | Haunted Graveyard",
        "77 | Haunted Mansion",
        "78 | Dungeon Entrance",
        "79 | Dungeon",
        "80 | Treasure Dungeon",
        "81 | Empyrean Dungeon",
        "82 | Mythic Dungeon",
        "83 | Cotton Candy Forest",
        "84 | Gummy Forest",
        "85 | Chocolate Waterfall",
        "86 | Sweets",
        "87 | Toys and Blocks",
        "88 | Carnival",
        "89 | Theme Park",
        "90 | Clouds",
        "91 | Cloud Garden",
        "92 | Cloud Forest",
        "93 | Cloud Houses",
        "94 | Cloud Palace",
        "95 | Heaven Gates",
        "96 | Heaven",
        "97 | Heaven Golden Castle",
        "98 | Colorful Clouds",
        "99 | Rainbow Road"
    }
}

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = game.Players.LocalPlayer

local Library = ReplicatedStorage.Library
local Client = ReplicatedStorage.Library.Client

local Network = require(Client.Network)
local Save = require(Client.Save)

local Breakables = workspace['__THINGS'].Breakables
local Map = workspace:FindFirstChild("Map") or workspace:FindFirstChild("Map2") or workspace:FindFirstChild("Map3")
local Areas = {}

for _,v in ipairs(Config.Areas) do
    local Area = Map and Map:FindFirstChild(v)
    if Area then table.insert(Areas, Area)
    else warn("Area not found: " .. v) end
end

game.Players.LocalPlayer.PlayerScripts.Scripts.Core["Idle Tracking"].Enabled = false; game.Players.LocalPlayer.Idled:connect(function() game:GetService("VirtualUser"):Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame) task.wait(1) game:GetService("VirtualUser"):Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame) end)
workspace.__THINGS:FindFirstChild("Lootbags").ChildAdded:Connect(function(lootbag) task.wait() if lootbag then Network.Fire("Lootbags_Claim", { lootbag.Name }) end end)
hookfunction(require(Client.PlayerPet).CalculateSpeedMultiplier,function() return 9999 end)
Network.Fired("Orbs: Create"):Connect(function(InfoTable)
    local Orbs = {}
    for _, v in ipairs(InfoTable) do table.insert(Orbs, v.id) end
    Network.Fire("Orbs: Collect", Orbs)
end)

task.spawn(function()
    while task.wait() do
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        for _, v in pairs(Breakables:GetChildren()) do
            if v:IsA("Model") and v:GetAttribute("BreakableID") == "Pinata" then
                local pos = v:GetPivot().Position
                local dist = (pos - hrp.Position).Magnitude

                if dist <= 300 then
                    Network.UnreliableFire("Breakables_PlayerDealDamage", v.Name)
                    task.wait(0.05)
                end
            end
        end
    end
end)

local PinataUid = nil
local GetPinataUID = function()
    local Misc = Save.Get().Inventory.Misc
    if PinataUid then
        local Entry = Misc[PinataUid]
        if Entry and Entry.id == "Mini Pinata" then return PinataUid end
        PinataUid = nil
    end
    for uid, v in pairs(Misc) do
        if v.id == "Mini Pinata" then PinataUid = uid return uid end
    end
    return nil
end

while task.wait() do
    if GetPinataUID() then
        for _, v in pairs(Areas) do
            if not v:FindFirstChild("INTERACT") then repeat LocalPlayer.Character.HumanoidRootPart.CFrame = v.PERSISTENT.Teleport.CFrame task.wait(0.1) until v:FindFirstChild("INTERACT") end
            LocalPlayer.Character.HumanoidRootPart.CFrame = v.INTERACT.BREAK_ZONES.BREAK_ZONE.CFrame
            a,e = Network.Invoke("MiniPinata_Consume", GetPinataUID())
            if not a and msg ~= "There is already something in this area!" or msg ~= "There are too many random events already in the world!" then 
                repeat a,e = Network.Invoke("MiniPinata_Consume", GetPinataUID()) task.wait(0.1) until a
            end
            Network.Invoke("MiniPinata_Consume", GetPinataUID())
        end
    else
        print("No pinata") break
    end
end
