-- Tự động xóa thông báo lỗi nếu có
local VirtualUser = game:GetService("VirtualUser")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Vô hiệu hóa script theo dõi AFK mặc định của game (nếu có)
pcall(function()
    if LocalPlayer:WaitForChild("PlayerScripts"):FindFirstChild("Scripts") then
        LocalPlayer.PlayerScripts.Scripts.Core["Idle Tracking"].Enabled = false
    end
end)

-- Kết nối với sự kiện Idled của hệ thống Roblox
LocalPlayer.Idled:Connect(function()
    pcall(function()
        -- Giả lập nhấn giữ chuột phải
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(0.5)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end)
end)

-- Vòng lặp phụ chủ động (Đề phòng sự kiện Idled không kích hoạt)
task.spawn(function()
    while task.wait(math.random(60, 180)) do -- Thực hiện ngẫu nhiên từ 1 đến 3 phút
        pcall(function()
            -- Giả lập một hành động gõ phím nhỏ không ảnh hưởng đến game
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        end)
    end
end)

print("Anti-AFK đã kích hoạt thành công!")
