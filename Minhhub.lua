- [[ Minh HUB - ANTI BAN & MULTI-SEA UPDATE ]] --

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- 1. HỆ THỐNG ANTI-BAN & BYPASS CƠ BẢN
local RawMeta = getrawmetatable(game)
local OldNamecall = RawMeta.__namecall
setreadonly(RawMeta, false)

RawMeta.__namecall = newcclosure(function(self, ...)
    local Method = getnamecallmethod()
    local Args = {...}
    
    -- Chặn game gửi các gói tin báo cáo nghi vấn (Report/Log) về Server
    if Method == "FireServer" and tostring(self) == "AdminCrash" or tostring(self) == "ReportBypass" then
        return nil
    end
    -- Chặn phát hiện thay đổi tốc độ chạy hoặc nhảy bất thường
    if Method == "FireServer" and tostring(self) == "WalkSpeedChanged" then
        return nil
    end
    return OldNamecall(self, ...)
end)
setreadonly(RawMeta, true)

-- 2. PHÂN CHIA DỮ LIỆU CHUẨN THEO TỪNG SEA (1, 2, 3)
local CurrentSea = 1
local PlaceId = game.PlaceId

if PlaceId == 2753915549 then
    CurrentSea = 1
elseif PlaceId == 4442272125 then
    CurrentSea = 2
elseif PlaceId == 7449423635 then
    CurrentSea = 3
end

print("Stree Hub đã nhận diện: Sea " .. tostring(CurrentSea))

-- Cấu hình cấp độ và Quái/NPC tương ứng từng Sea để tránh lỗi nhận nhầm Quest
local SeaData = {
    [1] = {
        {MinLvl = 1, MaxLvl = 14, Mob = "Bandit", QuestNPC = "Bandit Quest Giver", QuestName = "BanditQuest1", QuestIndex = 1},
        {MinLvl = 15, MaxLvl = 29, Mob = "Monkey", QuestNPC = "Monkey Quest Giver", QuestName = "JungleQuest", QuestIndex = 1},
        -- Thêm các bãi quái Sea 1 vào đây...
    },
    [2] = {
        {MinLvl = 700, MaxLvl = 724, Mob = "Raider", QuestNPC = "Area 1 Quest Giver", QuestName = "Area1Quest", QuestIndex = 1},
        {MinLvl = 725, MaxLvl = 774, Mob = "Mercenary", QuestNPC = "Area 1 Quest Giver", QuestName = "Area1Quest", QuestIndex = 2},
        -- Thêm các bãi quái Sea 2 vào đây...
    },
    [3] = {
        {MinLvl = 1500, MaxLvl = 1524, Mob = "Reborn Skeleton", QuestNPC = "Floating Turtle Quest Giver", QuestName = "TurtleQuest1", QuestIndex = 1},
        -- Thêm các bãi quái Sea 3 vào đây...
    }
}

-- 3. HÀM KIỂM TRA NHIỆM VỤ AN TOÀN (QUEST CHECK LOGIC)
function GetCurrentQuest()
    local MyLevel = LocalPlayer.Data.Level.Value
    local TargetSeaData = SeaData[CurrentSea]
    
    if TargetSeaData then
        for _, data in ipairs(TargetSeaData) do
            if MyLevel >= data.MinLvl and MyLevel <= data.MaxLvl then
                return data
            end
        end
    end
    return nil
end

-- 4. HÀM DỊCH CHUYỂN AN TOÀN (ANTI-CHEAT BYPASS TWEEN)
function SafeTween(targetCFrame)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local HRP = LocalPlayer.Character.HumanoidRootPart
    
    local Distance = (HRP.Position - targetCFrame.Position).Magnitude
    -- Tốc độ Tween vừa phải (khoảng 300-350), đi quá nhanh sẽ bị Server Kick (Lỗi 267)
    local Speed = 320 
    local Duration = Distance / Speed
    
    -- Tạo một chút độ lệch ngẫu nhiên về vị trí để không bị trùng lặp tọa độ tuyệt đối
    local RandomOffset = Vector3.new(math.random(-1, 1), math.random(18, 22), math.random(-1, 1))
    local FinalCFrame = targetCFrame * CFrame.new(RandomOffset)

    local TweenInfo = TweenInfo.new(Duration, Enum.EasingStyle.Linear)
    local Tween = TweenService:Create(HRP, TweenInfo, {CFrame = FinalCFrame})
    Tween:Play()
    return Tween
end

-- 5. HÀM GOM QUÁI CHỐNG KHÓA TÀI KHOẢN (SAFE BRING MOBS)
_G.BringMobs = true

function SafeBringMobs(MobName)
    task.spawn(function()
        while _G.BringMobs and task.wait(0.1) do
            pcall(function()
                if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
                local MyHRP = LocalPlayer.Character.HumanoidRootPart
                
                for _, enemy in ipairs(game:GetService("Workspace").Enemies:GetChildren()) do
                    if enemy.Name == MobName and enemy:FindFirstChild("HumanoidRootPart") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                        -- Chỉ gom quái khi nó ở trong phạm vi hợp lý (dưới 350 studs)
                        local Distance = (enemy.HumanoidRootPart.Position - MyHRP.Position).Magnitude
                        if Distance <= 350 then
                            enemy.HumanoidRootPart.CanCollide = false
                            -- Khóa quái đứng yên tại chỗ phía dưới tầm đánh của người chơi một chút
                            enemy.HumanoidRootPart.CFrame = MyHRP.CFrame * CFrame.new(0, -15, 0)
                            enemy.HumanoidRootPart.Velocity = Vector3.zero
                        end
                    end
                end
            end)
        end
    end)
end

-- 6. HỆ THỐNG TỰ ĐỘNG LƯU SETTINGS KHÔNG LỖI
local FolderName = "StreeHub | Blox Fruits"
local FileName = FolderName .. "/Settings.json"

_G.Settings = {
    AutoFarm = false,
    AutoNewWorld = true,
    WeaponSelected = "Melee"
}

function SaveSettings()
    if not isfolder(FolderName) then makefolder(FolderName) end
    writefile(FileName, HttpService:JSONEncode(_G.Settings))
end

function LoadSettings()
    if isfile(FileName) then
        local Success, Data = pcall(function()
            return HttpService:JSONDecode(readfile(FileName))
        end)
        if Success and type(Data) == "table" then
            _G.Settings = Data
        end
    end
end

-- Tải cài đặt ngay khi khởi chạy script
LoadSettings())
