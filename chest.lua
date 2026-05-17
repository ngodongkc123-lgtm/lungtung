getgenv().Config = {
    ['Areas'] = {
        "w1a", "w1b", "w1c", "w1d",
        "w2a", "w2b", "w2c", "w2d",
        "w3a", "w3b", "w3c", "w3d",
    },
   ['TeleportDelay'] = 2.5
}

local WORLD1_ID = 8737899170  
local WORLD2_ID = 16498369169 
local WORLD3_ID = 17503543197

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = game.Players.LocalPlayer

local Library = ReplicatedStorage.Library
local Client = ReplicatedStorage.Library.Client

-- SỬA LỖI: Gom các khai báo module lại gọn gàng, không bị trùng lặp biến
local Network = require(Client.Network)
local Breakables = workspace['__THINGS'].Breakables

local SaveModule = require(Client.Save)
local Save = SaveModule.Get or SaveModule.GetSave

-- Cấu hình danh sách Lucky Block muốn farm trên map
local FarmList = {
    ["abcd1"] = true, ["abcd2"] = true, ["abcd3"] = true, ["abcd4"] = true,
    ["abcd5"] = true, ["abcd6"] = true, ["abcd7"] = true, ["abcd8"] = true,
    ["abcd"] = true
}

local Map = workspace:FindFirstChild("Map") or workspace:FindFirstChild("Map2") or workspace:FindFirstChild("Map3")
local Areas = {}

--====================================================================================================
-- LỌC CÁC KHU VỰC TRÊN MAP
--====================================================================================================
for _,v in ipairs(Config.Areas) do
    local Area = Map and Map:FindFirstChild(v)
    if Area then 
        table.insert(Areas, Area)
    else 
        warn("Area not found: " .. v) 
    end
end

--====================================================================================================
-- VÒNG LẶP TELEPORT & CHUYỂN WORLD
--====================================================================================================
task.spawn(function()
    for index, targetArea in ipairs(Areas) do
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart", 2.5)
        
        if rootPart then
            local teleportPart = targetArea:FindFirstChild("PrimaryPart") 
                or targetArea:FindFirstChildWhichIsA("BasePart")
            
            if teleportPart then
                print("Đang dịch chuyển đến khu vực số " .. index .. ": " .. targetArea.Name)
                rootPart.CFrame = teleportPart.CFrame + Vector3.new(0, 5, 0)
                task.wait(Config.TeleportDelay)
            else
                warn("Khu vực " .. targetArea.Name .. " không có phần nền để đứng!")
            end
        else
            warn("Không tìm thấy HumanoidRootPart!")
            break
        end
    end
    
    -- BỘ LOGIC KIỂM TRA PLACEID: Chuyển world xoay vòng liên tục
    if game.PlaceId == WORLD1_ID then
        print("=== CHÚ Ý: Đang ở World 1. Tiến hành chuyển sang World 2... ===")
        pcall(function()
            local World2Remote = ReplicatedStorage:WaitForChild("Network"):WaitForChild("World2Teleport")
            World2Remote:InvokeServer()
        end)
        
    elseif game.PlaceId == WORLD2_ID then
        print("=== CHÚ Ý: Đang ở World 2. Tiến hành chuyển sang World 3... ===")
        pcall(function()
            local World3Remote = ReplicatedStorage:WaitForChild("Network"):WaitForChild("World3Teleport")
            World3Remote:InvokeServer()
        end)
        
    elseif game.PlaceId == WORLD3_ID then
        print("=== CHÚ Ý: Đang ở World 3. Tiến hành quay trở lại World 1... ===")
        pcall(function()
            local World1Remote = ReplicatedStorage:WaitForChild("Network"):WaitForChild("World1Teleport")
            World1Remote:InvokeServer()
        end)
    else
        print("=== CHÚ Ý: ID game không xác định ("..tostring(game.PlaceId).."). Chạy lệnh tele World 2 dự phòng... ===")
        pcall(function()
            local World2Remote = ReplicatedStorage:WaitForChild("Network"):WaitForChild("World2Teleport")
            World2Remote:InvokeServer()
        end)
    end
end)

--=================================================================================================
-- VÒNG LẶP AUTO FARM (ĐÁNH CHEST/BLOCK)
--=================================================================================================
task.spawn(function()
    while true do
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        
        if hrp then
            for _, v in pairs(Breakables:GetChildren()) do
                local id = v:GetAttribute("BreakableID")
                
                if v:IsA("Model") and id and FarmList[id] then
                    local pos = v:GetPivot().Position
                    local dist = (pos - hrp.Position).Magnitude

                    if dist <= 300 then
                        Network.UnreliableFire("Breakables_PlayerDealDamage", v.Name)
                    end
                end
            end
        end
        task.wait(0.05)
    end
end)

--=================================================================================================
-- TỰ ĐỘNG NHẶT TÚI QUÀ (LOOTBAGS) - ĐÃ TỐI ƯU QUÉT SẠCH QUÀ TRÊN ĐẤT
--=================================================================================================
task.spawn(function()
    local LootbagsFolder = workspace['__THINGS']:WaitForChild("Lootbags", 5)
    if LootbagsFolder then
        -- Bước 1: Quét sạch các túi quà đang nằm sẵn trên sàn khi vừa vào game/world mới
        for _, lootbag in ipairs(LootbagsFolder:GetChildren()) do
            Network.Fire("Lootbags_Claim", { lootbag.Name })
        end
        
        -- Bước 2: Chờ nhặt các túi quà mới rơi ra từ block bị đập vỡ
        LootbagsFolder.ChildAdded:Connect(function(lootbag)
            task.wait()
            if lootbag and lootbag.Parent then
                Network.Fire("Lootbags_Claim", { lootbag.Name })
            end
        end)
    end
end)
