-- [[ MINH HUB - FULL AUTO BRING & AUTO CLICK FIX ]] --

local KavoUiLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = KavoUiLib.CreateLib("Minh Hub - Blox Fruits", "DarkTheme")

-- 1. TẠO NÚT BẬT/TẮT MENU TRÊN ĐIỆN THOẠI
local ScreenGui = Instance.new("ScreenGui")
local ToggleBtn = Instance.new("TextButton")

ScreenGui.Parent = game:GetService("CoreInterface") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.Name = "MinhHubToggle"

ToggleBtn.Parent = ScreenGui
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleBtn.Position = UDim2.new(0, 10, 0, 150)
ToggleBtn.Size = UDim2.new(0, 80, 0, 35)
ToggleBtn.Text = "Ẩn/Hiện UI"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 12
ToggleBtn.Font = Enum.Font.SourceSansBold

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = ToggleBtn

local UiOpened = true
ToggleBtn.MouseButton1Click:Connect(function()
    UiOpened = not UiOpened
    if UiOpened then
        game:GetService("CoreGui").KavoUI.Main:TweenPosition(UDim2.new(0.5, -262, 0.5, -175), "Out", "Quart", 0.3, true)
    else
        game:GetService("CoreGui").KavoUI.Main:TweenPosition(UDim2.new(0.5, -262, 1, 10), "Out", "Quart", 0.3, true)
    end
end)

-- 2. CẤU HÌNH LOGIC GAME
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

_G.AutoFarm = false
_G.BringMobs = false

local MainTab = Window:NewTab("Auto Farm")
local MainSection = MainTab:NewSection("Chức năng Farm")

-- BẬT/TẮT GOM QUÁI
MainSection:NewToggle("Tự động gom quái (Auto Bring)", "Gom tất cả quái xung quanh lại một chỗ", function(state)
    _G.BringMobs = state
    if state then
        SafeBringAllMobs()
    end
end)

-- BẬT/TẮT TỰ ĐỘNG ĐÁNH (CÓ TỰ ĐỘNG LẤY VŨ KHÍ)
MainSection:NewToggle("Tự động đánh (Auto Click)", "Tự lấy vũ khí và vung tay đánh", function(state)
    _G.AutoFarm = state
    task.spawn(function()
        while _G.AutoFarm and task.wait(0.1) do
            pcall(function()
                -- TỰ ĐỘNG LẤY VŨ KHÍ MELEE (Combat, Black Leg, Electro...) LÊN TAY
                if not LocalPlayer.Character:FindFirstChildOfClass("Tool") then
                    for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
                        if tool:IsA("Tool") and (tool.ToolTip == "Melee" or tool.ToolTip == "Sword") then
                            LocalPlayer.Character.Humanoid:EquipTool(tool)
                            break
                        end
                    end
                end
                
                -- VUNG TAY ĐÁNH QUÁI
                local VirtualUser = game:GetService("VirtualUser")
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new(851, 158))
            end)
        end
    end)
end)

-- HÀM GOM QUÁI STACK CHUẨN (HÚT TRƯỚC MẶT 5 STUDS)
function SafeBringAllMobs()
    task.spawn(function()
        while _G.BringMobs and task.wait(0.1) do
            pcall(function()
                if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
                local MyHRP = LocalPlayer.Character.HumanoidRootPart
                
                for _, enemy in ipairs(game:GetService("Workspace").Enemies:GetChildren()) do
                    if enemy:FindFirstChild("HumanoidRootPart") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                        local Distance = (enemy.HumanoidRootPart.Position - MyHRP.Position).Magnitude
                        if Distance <= 350 then
                            enemy.HumanoidRootPart.CanCollide = false
                            -- Gom quái tụ lại một cục ngay trước mặt để đánh lan trúng hết cả đám
                            enemy.HumanoidRootPart.CFrame = MyHRP.CFrame * CFrame.new(0, 0, -5)
                            enemy.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                            
                            -- Gom thêm phần thân quái nếu bị tách rời lỗi vị trí ngoài đời thực
                            if enemy:FindFirstChild("Head") then
                                enemy.Head.CanCollide = false
                            end
                        end
                    end
                end
            end)
        end
    end)
end
