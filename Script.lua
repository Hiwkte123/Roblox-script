local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- ==================== [ 0. 基礎清理與設置 ] ====================
if CoreGui:FindFirstChild("FinalFixedGUI") then 
    CoreGui:FindFirstChild("FinalFixedGUI"):Destroy() 
end

local screenGui = Instance.new("ScreenGui", CoreGui)
screenGui.Name = "FinalFixedGUI"
screenGui.ResetOnSpawn = false

-- 全局核心狀態變數
local currentText = "🎬 Content Creator"
local currentColor = Color3.fromRGB(255, 105, 180) 
local currentSize = 20 
local currentWinsInput = ""
local autoLoadEnabled = false 
local isTitleEquipped = false 
local isWinsLocked = false -- 新增：Wins 鎖定狀態追蹤

local FILE_NAME = "sbty_multi_configs.json"
local BG_IMAGE_NAME = "sbty_custom_bg.png"

-- 圓角與外框萬能輔助函數
local function applyCorner(obj, radius)
    local corner = Instance.new("UICorner", obj)
    corner.CornerRadius = UDim.new(0, radius)
end

local function applyStroke(obj, color, thickness)
    local stroke = Instance.new("UIStroke", obj)
    stroke.Color = color
    stroke.Thickness = thickness
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
end

-- ==================== [ 萬能拖曳函數 ] ====================
local function setDraggable(gui)
    local dragging, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = gui.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    gui.InputEnded:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
            dragging = false 
        end 
    end)
end

-- ==================== [ 1. 開關按鈕 (圓潤小櫻花) ] ====================
local toggle = Instance.new("TextButton", screenGui)
toggle.Size = UDim2.new(0, 60, 0, 60)
toggle.Position = UDim2.new(0.05, 0, 0.1, 0)
toggle.BackgroundColor3 = Color3.fromRGB(255, 182, 193) 
toggle.Text = "🌸"
toggle.Font = Enum.Font.GothamBold
toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
toggle.TextSize = 26
applyCorner(toggle, 30) 
applyStroke(toggle, Color3.fromRGB(255, 105, 180), 2)
setDraggable(toggle)

-- ==================== [ 2. 主面板（柔和粉底、圓角） ] ====================
local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 330, 0, 300) 
frame.Position = UDim2.new(0.2, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(255, 240, 245) 
frame.Visible = false 
applyCorner(frame, 18) 
applyStroke(frame, Color3.fromRGB(255, 160, 175), 2) 
setDraggable(frame)

local bgImageLabel = Instance.new("ImageLabel", frame)
bgImageLabel.Size = UDim2.new(1, 0, 1, 0)
bgImageLabel.Position = UDim2.new(0, 0, 0, 0)
bgImageLabel.BackgroundTransparency = 1
bgImageLabel.ScaleType = Enum.ScaleType.Crop 
bgImageLabel.ZIndex = 0 
applyCorner(bgImageLabel, 18)

toggle.Activated:Connect(function() frame.Visible = not frame.Visible end)

-- ==================== [ 3. 四分頁功能切換標籤 ] ====================
local tabWins = Instance.new("TextButton", frame)
tabWins.Size = UDim2.new(0.23, 0, 0, 32); tabWins.Position = UDim2.new(0.02, 0, 0.02, 0)
tabWins.BackgroundColor3 = Color3.fromRGB(255, 192, 203); tabWins.Text = "☠ WINS"; tabWins.Font = Enum.Font.GothamBold; tabWins.TextColor3 = Color3.fromRGB(139, 58, 58); tabWins.TextSize = 10; tabWins.ZIndex = 2
applyCorner(tabWins, 8)

local tabTitle = Instance.new("TextButton", frame)
tabTitle.Size = UDim2.new(0.23, 0, 0, 32); tabTitle.Position = UDim2.new(0.26, 0, 0.02, 0)
tabTitle.BackgroundColor3 = Color3.fromRGB(245, 225, 230); tabTitle.Text = "⚙ 稱號"; tabTitle.Font = Enum.Font.GothamBold; tabTitle.TextColor3 = Color3.fromRGB(180, 140, 150); tabTitle.TextSize = 10; tabTitle.ZIndex = 2
applyCorner(tabTitle, 8)

local tabSave = Instance.new("TextButton", frame)
tabSave.Size = UDim2.new(0.23, 0, 0, 32); tabSave.Position = UDim2.new(0.50, 0, 0.02, 0)
tabSave.BackgroundColor3 = Color3.fromRGB(245, 225, 230); tabSave.Text = "💾 存檔"; tabSave.Font = Enum.Font.GothamBold; tabSave.TextColor3 = Color3.fromRGB(180, 140, 150); tabSave.TextSize = 10; tabSave.ZIndex = 2
applyCorner(tabSave, 8)

local tabSize = Instance.new("TextButton", frame)
tabSize.Size = UDim2.new(0.23, 0, 0, 32); tabSize.Position = UDim2.new(0.74, 0, 0.02, 0)
tabSize.BackgroundColor3 = Color3.fromRGB(245, 225, 230); tabSize.Text = "📏 縮放"; tabSize.Font = Enum.Font.GothamBold; tabSize.TextColor3 = Color3.fromRGB(180, 140, 150); tabSize.TextSize = 10; tabSize.ZIndex = 2
applyCorner(tabSize, 8)

local sign = Instance.new("TextLabel", frame)
sign.Size = UDim2.new(1, 0, 0, 20); sign.Position = UDim2.new(0, 0, 1, -22)
sign.Text = "sbty.tw 🇹🇼 | Designed by 閃爆湯圓"; sign.Font = Enum.Font.Code; sign.TextColor3 = Color3.fromRGB(120, 60, 70); sign.TextSize = 9; sign.BackgroundTransparency = 1; sign.ZIndex = 2

local containerWins = Instance.new("Frame", frame)
containerWins.Size = UDim2.new(1, 0, 1, -45); containerWins.Position = UDim2.new(0, 0, 0, 38); containerWins.BackgroundTransparency = 1; containerWins.ZIndex = 2

local containerTitle = Instance.new("Frame", frame)
containerTitle.Size = UDim2.new(1, 0, 1, -45); containerTitle.Position = UDim2.new(0, 0, 0, 38); containerTitle.BackgroundTransparency = 1; containerTitle.Visible = false; containerTitle.ZIndex = 2

local containerSave = Instance.new("Frame", frame)
containerSave.Size = UDim2.new(1, 0, 1, -45); containerSave.Position = UDim2.new(0, 0, 0, 38); containerSave.BackgroundTransparency = 1; containerSave.Visible = false; containerSave.ZIndex = 2

local containerSize = Instance.new("Frame", frame)
containerSize.Size = UDim2.new(1, 0, 1, -45); containerSize.Position = UDim2.new(0, 0, 0, 38); containerSize.BackgroundTransparency = 1; containerSize.Visible = false; containerSize.ZIndex = 2

-- ==================== [ 4. WINS & TITLE 介面組件 ] ====================
local boxWins = Instance.new("TextBox", containerWins)
boxWins.Size = UDim2.new(0.85, 0, 0, 38); boxWins.Position = UDim2.new(0.075, 0, 0.12, 0)
boxWins.BackgroundColor3 = Color3.fromRGB(255, 255, 255); boxWins.PlaceholderText = "支援輸入 1K, 5M, 10B 等..."; boxWins.Text = ""; boxWins.TextColor3 = Color3.fromRGB(100, 50, 60); boxWins.Font = Enum.Font.Gotham; boxWins.TextSize = 12; boxWins.ZIndex = 2
applyCorner(boxWins, 10); applyStroke(boxWins, Color3.fromRGB(255, 182, 193), 1)

local applyBtn = Instance.new("TextButton", containerWins)
applyBtn.Size = UDim2.new(0.4, 0, 0, 38); applyBtn.Position = UDim2.new(0.075, 0, 0.45, 0)
applyBtn.Text = "⚡ 應用 ⚡"; applyBtn.Font = Enum.Font.GothamBold; applyBtn.TextColor3 = Color3.new(1, 1, 1); applyBtn.TextSize = 12; applyBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180); applyBtn.ZIndex = 2
applyCorner(applyBtn, 12)

local restoreBtn = Instance.new("TextButton", containerWins)
restoreBtn.Size = UDim2.new(0.4, 0, 0, 38); restoreBtn.Position = UDim2.new(0.525, 0, 0.45, 0)
restoreBtn.Text = "↩ 重置 ↩"; restoreBtn.Font = Enum.Font.GothamBold; restoreBtn.TextColor3 = Color3.new(1, 1, 1); restoreBtn.TextSize = 12; restoreBtn.BackgroundColor3 = Color3.fromRGB(220, 100, 100); restoreBtn.ZIndex = 2
applyCorner(restoreBtn, 12)

local textInput = Instance.new("TextBox", containerTitle)
textInput.Size = UDim2.new(0.85, 0, 0, 32); textInput.Position = UDim2.new(0.075, 0, 0.05, 0)
textInput.BackgroundColor3 = Color3.fromRGB(255, 255, 255); textInput.Text = currentText; textInput.PlaceholderText = "輸入稱號文字..."; textInput.TextColor3 = Color3.fromRGB(100, 50, 60); textInput.Font = Enum.Font.Gotham; textInput.TextSize = 12; textInput.ZIndex = 2
applyCorner(textInput, 8); applyStroke(textInput, Color3.fromRGB(255, 182, 193), 1)

local sizeInput = Instance.new("TextBox", containerTitle)
sizeInput.Size = UDim2.new(0.35, 0, 0, 32); sizeInput.Position = UDim2.new(0.075, 0, 0.23, 0)
sizeInput.BackgroundColor3 = Color3.fromRGB(255, 255, 255); sizeInput.Text = tostring(currentSize); sizeInput.PlaceholderText = "大小"; sizeInput.TextColor3 = Color3.fromRGB(100, 50, 60); sizeInput.Font = Enum.Font.Gotham; sizeInput.TextSize = 12; sizeInput.ZIndex = 2
applyCorner(sizeInput, 8); applyStroke(sizeInput, Color3.fromRGB(230, 230, 230), 1)

local titleApplyBtn = Instance.new("TextButton", containerTitle)
titleApplyBtn.Size = UDim2.new(0.45, 0, 0, 32); titleApplyBtn.Position = UDim2.new(0.475, 0, 0.23, 0)
titleApplyBtn.Text = "確定修改"; titleApplyBtn.Font = Enum.Font.GothamBold; titleApplyBtn.TextColor3 = Color3.new(1, 1, 1); titleApplyBtn.TextSize = 12; titleApplyBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180); titleApplyBtn.ZIndex = 2
applyCorner(titleApplyBtn, 10)

local gridFrame = Instance.new("Frame", containerTitle)
gridFrame.Size = UDim2.new(0.85, 0, 0, 60); gridFrame.Position = UDim2.new(0.075, 0, 0.46, 0); gridFrame.BackgroundTransparency = 1
local gridLayout = Instance.new("UIGridLayout", gridFrame)
gridLayout.CellSize = UDim2.new(0, 44, 0, 26); gridLayout.CellPadding = UDim2.new(0, 4, 0, 4); gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
local presetColors = {Color3.fromRGB(255, 105, 180), Color3.fromRGB(255, 60, 60), Color3.fromRGB(255, 140, 40), Color3.fromRGB(255, 210, 40), Color3.fromRGB(60, 240, 100), Color3.fromRGB(40, 200, 255), Color3.fromRGB(60, 90, 255), Color3.fromRGB(160, 60, 255), Color3.fromRGB(255, 255, 255), Color3.fromRGB(120, 120, 120)}

-- ==================== [ 5. 多存檔列表組件 ] ====================
local customNameInput = Instance.new("TextBox", containerSave)
customNameInput.Size = UDim2.new(0.55, 0, 0, 30); customNameInput.Position = UDim2.new(0.05, 0, 0.04, 0)
customNameInput.BackgroundColor3 = Color3.fromRGB(255, 255, 255); customNameInput.PlaceholderText = "✍ 存檔名字..."; customNameInput.Text = ""; customNameInput.TextColor3 = Color3.fromRGB(150, 70, 90); customNameInput.Font = Enum.Font.Gotham; customNameInput.TextSize = 11; customNameInput.ZIndex = 2
applyCorner(customNameInput, 8); applyStroke(customNameInput, Color3.fromRGB(255, 182, 193), 1)

local saveBtn = Instance.new("TextButton", containerSave)
saveBtn.Size = UDim2.new(0.32, 0, 0, 30); saveBtn.Position = UDim2.new(0.63, 0, 0.04, 0)
saveBtn.Text = "💾 儲存"; saveBtn.Font = Enum.Font.GothamBold; saveBtn.TextColor3 = Color3.new(1, 1, 1); saveBtn.TextSize = 11; saveBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180); saveBtn.ZIndex = 2
applyCorner(saveBtn, 8)

local autoToggleBtn = Instance.new("TextButton", containerSave)
autoToggleBtn.Size = UDim2.new(0.9, 0, 0, 22); autoToggleBtn.Position = UDim2.new(0.05, 0, 0.18, 0)
autoToggleBtn.Text = "自動啟用最後一筆: [關閉]"; autoToggleBtn.Font = Enum.Font.GothamBold; autoToggleBtn.TextColor3 = Color3.fromRGB(200, 80, 100); autoToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255); autoToggleBtn.ZIndex = 2
applyCorner(autoToggleBtn, 6); applyStroke(autoToggleBtn, Color3.fromRGB(255, 200, 210), 1)

local scrollFrame = Instance.new("ScrollingFrame", containerSave)
scrollFrame.Size = UDim2.new(0.9, 0, 0.55, 0) 
scrollFrame.Position = UDim2.new(0.05, 0, 0.30, 0)
scrollFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
scrollFrame.ScrollBarThickness = 4; scrollFrame.BorderSizePixel = 0; scrollFrame.ZIndex = 2
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
applyCorner(scrollFrame, 10); applyStroke(scrollFrame, Color3.fromRGB(255, 210, 220), 1)

local scrollListLayout = Instance.new("UIListLayout", scrollFrame)
scrollListLayout.Padding = UDim.new(0, 4); scrollListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- ==================== [ 6. 📏 大小縮放分頁 + 🖼️ 網址背景功能 ] ====================
local sizeTitleLabel = Instance.new("TextLabel", containerSize)
sizeTitleLabel.Size = UDim2.new(0.9, 0, 0, 20); sizeTitleLabel.Position = UDim2.new(0.05, 0, 0.02, 0)
sizeTitleLabel.Text = "微調主選單介面大小"; sizeTitleLabel.Font = Enum.Font.GothamBold; sizeTitleLabel.TextColor3 = Color3.fromRGB(150, 70, 90); sizeTitleLabel.TextSize = 11; sizeTitleLabel.BackgroundTransparency = 1; sizeTitleLabel.ZIndex = 2

local btnLarge = Instance.new("TextButton", containerSize)
btnLarge.Size = UDim2.new(0.28, 0, 0, 30); btnLarge.Position = UDim2.new(0.05, 0, 0.12, 0)
btnLarge.Text = "🧱 大"; btnLarge.Font = Enum.Font.GothamBold; btnLarge.TextColor3 = Color3.fromRGB(150, 70, 90); btnLarge.TextSize = 11; btnLarge.BackgroundColor3 = Color3.fromRGB(255, 192, 203); btnLarge.ZIndex = 2
applyCorner(btnLarge, 8); applyStroke(btnLarge, Color3.fromRGB(255, 105, 180), 1)

local btnMedium = Instance.new("TextButton", containerSize)
btnMedium.Size = UDim2.new(0.28, 0, 0, 30); btnMedium.Position = UDim2.new(0.36, 0, 0.12, 0)
btnMedium.Text = "📦 中"; btnMedium.Font = Enum.Font.GothamBold; btnMedium.TextColor3 = Color3.fromRGB(120, 100, 105); btnMedium.TextSize = 11; btnMedium.BackgroundColor3 = Color3.fromRGB(255, 255, 255); btnMedium.ZIndex = 2
applyCorner(btnMedium, 8); applyStroke(btnMedium, Color3.fromRGB(230, 230, 230), 1)

local btnSmall = Instance.new("TextButton", containerSize)
btnSmall.Size = UDim2.new(0.28, 0, 0, 30); btnSmall.Position = UDim2.new(0.67, 0, 0.12, 0)
btnSmall.Text = "🔎 小"; btnSmall.Font = Enum.Font.GothamBold; btnSmall.TextColor3 = Color3.fromRGB(120, 100, 105); btnSmall.TextSize = 11; btnSmall.BackgroundColor3 = Color3.fromRGB(255, 255, 255); btnSmall.ZIndex = 2
applyCorner(btnSmall, 8); applyStroke(btnSmall, Color3.fromRGB(230, 230, 230), 1)

local bgTitleLabel = Instance.new("TextLabel", containerSize)
bgTitleLabel.Size = UDim2.new(0.9, 0, 0, 20); bgTitleLabel.Position = UDim2.new(0.05, 0, 0.32, 0)
bgTitleLabel.Text = "🖼️ 自定義網路照片背景"; bgTitleLabel.Font = Enum.Font.GothamBold; bgTitleLabel.TextColor3 = Color3.fromRGB(150, 70, 90); bgTitleLabel.TextSize = 11; bgTitleLabel.BackgroundTransparency = 1; bgTitleLabel.ZIndex = 2

local bgUrlInput = Instance.new("TextBox", containerSize)
bgUrlInput.Size = UDim2.new(0.9, 0, 0, 32); bgUrlInput.Position = UDim2.new(0.05, 0, 0.44, 0)
bgUrlInput.BackgroundColor3 = Color3.fromRGB(255, 255, 255); bgUrlInput.PlaceholderText = "貼上圖片網址 (https://...)"; bgUrlInput.Text = ""; bgUrlInput.TextColor3 = Color3.fromRGB(100, 50, 60); bgUrlInput.Font = Enum.Font.Gotham; bgUrlInput.TextSize = 10; bgUrlInput.ZIndex = 2
applyCorner(bgUrlInput, 8); applyStroke(bgUrlInput, Color3.fromRGB(255, 182, 193), 1)

local bgApplyBtn = Instance.new("TextButton", containerSize)
bgApplyBtn.Size = UDim2.new(0.42, 0, 0, 32); bgApplyBtn.Position = UDim2.new(0.05, 0, 0.64, 0)
bgApplyBtn.Text = "套用背景圖"; bgApplyBtn.Font = Enum.Font.GothamBold; bgApplyBtn.TextColor3 = Color3.new(1, 1, 1); bgApplyBtn.TextSize = 11; bgApplyBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180); bgApplyBtn.ZIndex = 2
applyCorner(bgApplyBtn, 10)

local bgRemoveBtn = Instance.new("TextButton", containerSize)
bgRemoveBtn.Size = UDim2.new(0.42, 0, 0, 32); bgRemoveBtn.Position = UDim2.new(0.53, 0, 0.64, 0)
bgRemoveBtn.Text = "清除背景圖"; bgRemoveBtn.Font = Enum.Font.GothamBold; bgRemoveBtn.TextColor3 = Color3.new(1, 1, 1); bgRemoveBtn.TextSize = 11; bgRemoveBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 110); bgRemoveBtn.ZIndex = 2
applyCorner(bgRemoveBtn, 10)

local function setBackgroundFromUrl(url)
    local req = (syn and syn.request) or (http and http.request) or request
    if not req then bgUrlInput.Text = "錯誤: 執行器不支援此功能"; return end
    task.spawn(function()
        bgApplyBtn.Text = "下載中..."; local res = req({Url = url, Method = "GET"})
        if res and res.StatusCode == 200 and res.Body then
            if writefile then
                writefile(BG_IMAGE_NAME, res.Body)
                bgImageLabel.Image = getcustomasset(BG_IMAGE_NAME)
                frame.BackgroundTransparency = 0.4
                bgApplyBtn.Text = "SUCCESS"; task.wait(0.8); bgApplyBtn.Text = "套用背景圖"
            end
        else
            bgApplyBtn.Text = "下載失敗❌"; task.wait(1); bgApplyBtn.Text = "套用背景圖"
        end
    end)
end

bgApplyBtn.Activated:Connect(function() if bgUrlInput.Text ~= "" then setBackgroundFromUrl(bgUrlInput.Text) end end)
bgRemoveBtn.Activated:Connect(function() if isfile and isfile(BG_IMAGE_NAME) then delfile(BG_IMAGE_NAME) end; bgImageLabel.Image = ""; frame.BackgroundTransparency = 0; bgUrlInput.Text = "" end)

local function resizeUI(targetSize, activeBtn)
    frame.Size = targetSize
    btnLarge.BackgroundColor3 = Color3.fromRGB(255, 255, 255); btnLarge.TextColor3 = Color3.fromRGB(120, 100, 105); applyStroke(btnLarge, Color3.fromRGB(230, 230, 230), 1)
    btnMedium.BackgroundColor3 = Color3.fromRGB(255, 255, 255); btnMedium.TextColor3 = Color3.fromRGB(120, 100, 105); applyStroke(btnMedium, Color3.fromRGB(230, 230, 230), 1)
    btnSmall.BackgroundColor3 = Color3.fromRGB(255, 255, 255); btnSmall.TextColor3 = Color3.fromRGB(120, 100, 105); applyStroke(btnSmall, Color3.fromRGB(230, 230, 230), 1)
    activeBtn.BackgroundColor3 = Color3.fromRGB(255, 192, 203); activeBtn.TextColor3 = Color3.fromRGB(150, 70, 90); applyStroke(activeBtn, Color3.fromRGB(255, 105, 180), 1)
end

btnLarge.Activated:Connect(function() resizeUI(UDim2.new(0, 330, 0, 300), btnLarge) end)
btnMedium.Activated:Connect(function() resizeUI(UDim2.new(0, 280, 0, 265), btnMedium) end)
btnSmall.Activated:Connect(function() resizeUI(UDim2.new(0, 230, 0, 230), btnSmall) end)

-- ==================== [ 7. 頁籤切換邏輯 ] ====================
local function switchTab(activeBtn, activeContainer)
    containerWins.Visible = false; containerTitle.Visible = false; containerSave.Visible = false; containerSize.Visible = false
    tabWins.BackgroundColor3 = Color3.fromRGB(245, 225, 230); tabWins.TextColor3 = Color3.fromRGB(180, 140, 150)
    tabTitle.BackgroundColor3 = Color3.fromRGB(245, 225, 230); tabTitle.TextColor3 = Color3.fromRGB(180, 140, 150)
    tabSave.BackgroundColor3 = Color3.fromRGB(245, 225, 230); tabSave.TextColor3 = Color3.fromRGB(180, 140, 150)
    tabSize.BackgroundColor3 = Color3.fromRGB(245, 225, 230); tabSize.TextColor3 = Color3.fromRGB(180, 140, 150)
    activeBtn.BackgroundColor3 = Color3.fromRGB(255, 192, 203); activeBtn.TextColor3 = Color3.fromRGB(139, 58, 58)
    activeContainer.Visible = true
end
tabWins.Activated:Connect(function() switchTab(tabWins, containerWins) end)
tabTitle.Activated:Connect(function() switchTab(tabTitle, containerTitle) end)
tabSave.Activated:Connect(function() switchTab(tabSave, containerSave) end)
tabSize.Activated:Connect(function() switchTab(tabSize, containerSize) end)

-- ==================== [ 8. 核心換算與修改引擎 ] ====================
local function parseAbbreviatedNumber(text)
    local upperText = string.upper(string.gsub(text, "%s", ""))
    local numberPart = string.match(upperText, "^[0-9%.]+")
    local suffixPart = string.match(upperText, "[KMBT]+$")
    local num = tonumber(numberPart) or 0
    if not suffixPart then return math.floor(num) end
    if suffixPart == "K" then num = num * 1000
    elseif suffixPart == "M" then num = num * 1000000
    elseif suffixPart == "B" then num = num * 1000000000
    elseif suffixPart == "T" then num = num * 1000000000000
    end
    return math.floor(num)
end

local originalText, originalLeaderstatsData = nil, {}
local connectionUI, connectionsLeader = nil, {}

local function executeWinsModify(rawInput)
    currentWinsInput = rawInput
    local targetValue = parseAbbreviatedNumber(rawInput)
    boxWins.Text = tostring(rawInput) -- 保持玩家輸入的格式
    isWinsLocked = true -- 啟動強制鎖定狀態
    
    -- 1. 修改左側 UI 數字
    local successUI = pcall(function()
        local label = player.PlayerGui:WaitForChild("SpeedGameUI", 5).Frames.LeftFrame.WinsFrame.WinsLabel
        if label the
