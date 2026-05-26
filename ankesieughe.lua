-- ==========================================================
-- PHẦN 1: RADAR BÁM ĐUÔI TỰ ĐỘNG (Hỗ trợ nhiều ID)
-- ==========================================================
local TARGET_IDS = {
    10970668731, -- ID bạn vừa gửi
       -- Bạn có thể thêm ID thứ 2 ở đây
       -- Thêm ID thứ 3 ở đây (nhớ có dấu phẩy ở cuối mỗi số)
}
local CHECK_INTERVAL = 12 -- Số giây quét vị trí một lần

local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local isSameServer = false
local currentTarget = nil

-- Hàm quét tìm mục tiêu đang online
local function scanTargets()
    local success, result = pcall(function()
        return game:HttpPostAsync("https://roblox.com", 
            HttpService:JSONEncode({userIds = TARGET_IDS}), "application/json")
    end)
    
    if success and result then
        local data = HttpService:JSONDecode(result)
        if data and data.userPresences then
            -- Duyệt qua danh sách để tìm người đang ở Public Server (userPresenceType == 2)
            for _, presence in ipairs(data.userPresences) do
                if presence.userPresenceType == 2 and presence.gameId and presence.placeId then
                    return presence.userId, presence.gameId, presence.placeId
                end
            end
        end
    end
    return nil, nil, nil
end

-- Kiểm tra ngay khi vừa vào game
local foundId, targetJobId, targetPlaceId = scanTargets()
if foundId then
    currentTarget = foundId
    if game.JobId ~= targetJobId then
        print("[Radar] Phát hiện mục tiêu " .. foundId .. " đang ở server khác. Đang bay theo...")
        pcall(function()
            TeleportService:TeleportToPlaceInstance(targetPlaceId, targetJobId, Players.LocalPlayer)
        end)
    else
        print("[Radar] Đã vào chung server với mục tiêu: " .. foundId)
        isSameServer = true
    end
else
    print("[Radar] Hiện tại không có ai trong danh sách đang online ở server công khai.")
end

-- Vòng lặp quét ngầm liên tục đề phòng họ đổi server hoặc người khác vào online
task.spawn(function()
    while true do
        task.wait(CHECK_INTERVAL)
        local fId, tJobId, tPlaceId = scanTargets()
        if fId and game.JobId ~= tJobId then
            print("[Radar] Mục tiêu đổi server hoặc phát hiện mục tiêu mới! Đang dịch chuyển...")
            TeleportService:TeleportToPlaceInstance(tPlaceId, tJobId, Players.LocalPlayer)
            break
        end
    end
end)

-- ==========================================================
-- PHẦN 2: ĐOẠN LOADSTRING ĂN KÉ CỦA BẠN (Nằm riêng ở cuối)
-- ==========================================================
if isSameServer then
    print("[Ăn Ké] Kích hoạt script ăn ké của bạn...")
    
    -- Bạn hãy dán cái loadstring ăn ké của bạn vào ngay dưới dòng này nhé:
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ngodongkc123-lgtm/lungtung/refs/heads/main/anke.lua"))()

end
