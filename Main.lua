--[[
	MasensDev Hub - Main.lua (Key System + Hub)
	Created for MasensDev
]]

-- ==========================================
-- KONFIGURASI KEY (UBAH BAGIAN INI)
-- ==========================================
local KEY_LINK = "https://link-target.net/9347872/7RtKPjiaj3bW"   -- link yang otomatis tersalin saat tombol "Get Link" ditekan

local VALID_KEYS = {                                      -- daftar key yang berlaku
	"SENADINEW",
	"SENADINEW",
}

-- (Opsional) Daftar key dari file online, satu key per baris. Contoh:
-- "https://raw.githubusercontent.com/ens9555/Senadi/main/keys.txt"
-- Dengan ini Anda bisa ganti key tanpa mengubah script. Kosongkan ("") jika tidak dipakai.
local KEY_LIST_URL = ""

local KEY_DURATION = 12 * 60 * 60                         -- masa berlaku key (12 jam, dalam detik)
local SAVE_FILE = "MasensDevHub_Key.json"                 -- file penyimpanan key di perangkat pemain
-- ==========================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local env = (typeof(getgenv) == "function" and getgenv()) or _G

-- ==========================================
-- PENYIMPANAN KEY (DataStore sisi client)
-- ==========================================
-- Catatan: DataStoreService Roblox hanya bisa dipakai dari server game, bukan dari
-- script executor. Sebagai gantinya key + waktu disimpan di file lokal (writefile).
-- Jika executor tidak mendukung file, penyimpanan memakai memori selama game berjalan.

local function now()
	local ok, t = pcall(function() return workspace:GetServerTimeNow() end)
	if ok and type(t) == "number" then return math.floor(t) end
	return os.time()
end

local function canUseFiles()
	return typeof(writefile) == "function" and typeof(readfile) == "function" and typeof(isfile) == "function"
end

local function saveKey(key)
	local data = { key = key, time = now() }
	env.MasensDevKeyData = data
	if canUseFiles() then
		pcall(function() writefile(SAVE_FILE, HttpService:JSONEncode(data)) end)
	end
end

local function loadSavedKey()
	if canUseFiles() then
		local ok, data = pcall(function()
			if isfile(SAVE_FILE) then
				return HttpService:JSONDecode(readfile(SAVE_FILE))
			end
		end)
		if ok and type(data) == "table" then return data end
	end
	return env.MasensDevKeyData
end

local function clearSavedKey()
	env.MasensDevKeyData = nil
	if canUseFiles() then
		pcall(function() writefile(SAVE_FILE, "") end)
	end
end

-- ==========================================
-- VALIDASI KEY
-- ==========================================
local function trim(s)
	return (tostring(s):match("^%s*(.-)%s*$"))
end

local function getValidKeys()
	local keys = {}
	for _, k in ipairs(VALID_KEYS) do
		keys[#keys + 1] = trim(k)
	end
	if KEY_LIST_URL ~= "" then
		pcall(function()
			local body = game:HttpGet(KEY_LIST_URL)
			for line in string.gmatch(body, "[^\r\n]+") do
				local k = trim(line)
				if k ~= "" then keys[#keys + 1] = k end
			end
		end)
	end
	return keys
end

local function isValidKey(key)
	for _, k in ipairs(getValidKeys()) do
		if k == key then return true end
	end
	return false
end

-- ==========================================
-- HUB UTAMA (dijalankan setelah key valid)
-- ==========================================
local function StartHub()
--[[
	MasensDev Hub - Mount Valhalla / Universal Utility
	Created for MasensDev
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- DATA & STATUS
-- ==========================================
local checkpointCoords = {
	["Checkpoint 1"]  = Vector3.new(49.55, 24.40, 1381.20),
	["Checkpoint 2"]  = Vector3.new(135.50, 128.70, 2422.27),
	["Checkpoint 3"]  = Vector3.new(-181.11, 231.91, 3249.66),
	["Checkpoint 4"]  = Vector3.new(-1065.58, 375.89, 3565.64),
	["Checkpoint 5"]  = Vector3.new(-1340.38, 538.91, 4262.86),
	["Checkpoint 6"]  = Vector3.new(-1517.40, 775.60, 4920.05),
	["Checkpoint 7"]  = Vector3.new(-2121.20, 749.45, 6098.00),
	["Checkpoint 8"]  = Vector3.new(-3245.72, 749.80, 6161.96),
	["Checkpoint 9"]  = Vector3.new(-3267.90, 747.45, 6880.70),
	["Checkpoint 10"] = Vector3.new(-2919.83, 838.18, 7689.13),
	["Checkpoint 11"] = Vector3.new(-2929.55, 853.23, 8514.40),
	["Checkpoint 12"] = Vector3.new(-3247.30, 934.45, 9264.80),
	["Checkpoint 13"] = Vector3.new(-3473.01, 1031.62, 9840.74),
	["Checkpoint 14"] = Vector3.new(-3487.89, 1031.56, 10595.05),
	["Checkpoint 15"] = Vector3.new(-3659.64, 1052.70, 11292.28),
	["Checkpoint 16"] = Vector3.new(-3970.07, 1125.21, 12212.48),
	["Checkpoint 17"] = Vector3.new(-3995.75, 1119.20, 13095.45),
	["Checkpoint 18"] = Vector3.new(-4033.28, 1287.00, 13994.72),
	["Checkpoint 19"] = Vector3.new(-4343.25, 1286.65, 14976.30),
	["Checkpoint 20"] = Vector3.new(-4744.35, 1332.95, 15841.85),
	["Checkpoint 21"] = Vector3.new(-4731.75, 1330.50, 16833.45),
	["Checkpoint 22"] = Vector3.new(-4962.30, 1402.40, 17409.85),
	["Checkpoint 23"] = Vector3.new(-5229.81, 1534.86, 18054.15),
	["Checkpoint 24"] = Vector3.new(-5340.59, 1747.90, 18708.38),
	["Checkpoint 25"] = Vector3.new(-5380.16, 1744.80, 19672.40),
	["Checkpoint 26"] = Vector3.new(-5397.29, 1854.40, 20389.19),
	["Checkpoint 27"] = Vector3.new(-5694.70, 1947.70, 20875.35),
	["Checkpoint 28"] = Vector3.new(-5744.00, 1982.80, 21187.50),
	["Checkpoint 29"] = Vector3.new(-6512.20, 1988.50, 21172.00),
	["Checkpoint 30"] = Vector3.new(-6635.50, 2054.80, 21706.60),
	["Summit"]        = Vector3.new(-6635.24, 2233.75, 22311.40),
}

local infJumpEnabled = false
local noclipEnabled = false
local flyEnabled = false
local autoCPEnabled = false
local antiAFKEnabled = false
local lowGraphicEnabled = false

local customSpeed = 16
local customJump = 50
local flySpeed = 50          -- kecepatan Fly (studs/s)
local teleportSpeed = 50     -- batas kecepatan teleport otomatis (studs/s)
local selectedTargetPlayer = nil

-- ==========================================
-- THEME & HELPER
-- ==========================================
local Theme = {
	Bg         = Color3.fromRGB(16, 16, 22),
	Header     = Color3.fromRGB(22, 22, 30),
	Sidebar    = Color3.fromRGB(20, 20, 28),
	Card       = Color3.fromRGB(30, 30, 41),
	CardHover  = Color3.fromRGB(40, 40, 54),
	CardActive = Color3.fromRGB(46, 38, 82),
	Accent     = Color3.fromRGB(124, 92, 255),
	Accent2    = Color3.fromRGB(70, 170, 255),
	Text       = Color3.fromRGB(240, 240, 248),
	SubText    = Color3.fromRGB(150, 150, 172),
	Off        = Color3.fromRGB(62, 62, 80),
	Stroke     = Color3.fromRGB(52, 52, 70),
	Danger     = Color3.fromRGB(235, 80, 90),
}

local function create(class, props, parent)
	local obj = Instance.new(class)
	for k, v in pairs(props) do
		obj[k] = v
	end
	if parent then obj.Parent = parent end
	return obj
end

local function corner(obj, radius)
	return create("UICorner", { CornerRadius = UDim.new(0, radius) }, obj)
end

local function stroke(obj, color, thickness)
	return create("UIStroke", {
		Color = color or Theme.Stroke,
		Thickness = thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, obj)
end

local function tween(obj, time, props)
	TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function myRoot()
	local char = LocalPlayer.Character
	return char and char:FindFirstChild("HumanoidRootPart")
end

local function myHumanoid()
	local char = LocalPlayer.Character
	return char and char:FindFirstChildOfClass("Humanoid")
end

local function rootOf(char)
	return char and char:FindFirstChild("HumanoidRootPart")
end

-- Hapus GUI lama agar tidak duplikat
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
if playerGui:FindFirstChild("MasensDevHub") then
	playerGui.MasensDevHub:Destroy()
end

local ScreenGui = create("ScreenGui", {
	Name = "MasensDevHub",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 999,
}, playerGui)

-- Fungsi drag (mouse + touch). Mengembalikan fungsi untuk cek apakah baru saja digeser.
local function makeDraggable(handle, target)
	local dragging, dragStart, startPos = false, nil, nil
	local moved = false

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			moved = false
			dragStart = input.Position
			startPos = target.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			if delta.Magnitude > 6 then moved = true end
			if moved then
				target.Position = UDim2.new(
					startPos.X.Scale, startPos.X.Offset + delta.X,
					startPos.Y.Scale, startPos.Y.Offset + delta.Y
				)
			end
		end
	end)

	return function() return moved end
end

-- Notifikasi kecil
local toast = create("TextLabel", {
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -24),
	Size = UDim2.fromOffset(0, 32),
	AutomaticSize = Enum.AutomaticSize.X,
	BackgroundColor3 = Theme.Header,
	BackgroundTransparency = 0.05,
	Font = Enum.Font.GothamMedium,
	Text = "",
	TextColor3 = Theme.Text,
	TextSize = 13,
	Visible = false,
	ZIndex = 50,
}, ScreenGui)
corner(toast, 16)
stroke(toast, Theme.Accent, 1)
create("UIPadding", { PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16) }, toast)

local toastToken = 0
local function notify(msg)
	toastToken += 1
	local mine = toastToken
	toast.Text = msg
	toast.Visible = true
	task.delay(2, function()
		if mine == toastToken then toast.Visible = false end
	end)
end

-- ==========================================
-- MAIN WINDOW
-- ==========================================
local MainFrame = create("Frame", {
	Name = "MainFrame",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	Size = UDim2.fromOffset(520, 340),
	BackgroundColor3 = Theme.Bg,
	BorderSizePixel = 0,
	ClipsDescendants = true,
}, ScreenGui)
corner(MainFrame, 12)
stroke(MainFrame, Theme.Stroke, 1)

local uiScale = create("UIScale", { Scale = 1 }, MainFrame)

local function fitScale()
	local cam = workspace.CurrentCamera
	if not cam then return 1 end
	local vp = cam.ViewportSize
	return math.clamp(math.min(vp.X / 560, vp.Y / 380), 0.5, 1)
end
uiScale.Scale = fitScale()

-- Header
local Header = create("Frame", {
	Size = UDim2.new(1, 0, 0, 42),
	BackgroundColor3 = Theme.Header,
	BorderSizePixel = 0,
}, MainFrame)

local headerLine = create("Frame", {
	AnchorPoint = Vector2.new(0, 1),
	Position = UDim2.new(0, 0, 1, 0),
	Size = UDim2.new(1, 0, 0, 2),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BorderSizePixel = 0,
}, Header)
create("UIGradient", {
	Color = ColorSequence.new(Theme.Accent, Theme.Accent2),
}, headerLine)

create("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 14, 0, 4),
	Size = UDim2.new(1, -70, 0, 20),
	Font = Enum.Font.GothamBold,
	Text = "MasensDev Hub",
	TextColor3 = Theme.Text,
	TextSize = 16,
	TextXAlignment = Enum.TextXAlignment.Left,
}, Header)

create("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 14, 0, 23),
	Size = UDim2.new(1, -70, 0, 14),
	Font = Enum.Font.Gotham,
	Text = "Mount Senadi  •  Universal Utility",
	TextColor3 = Theme.SubText,
	TextSize = 11,
	TextXAlignment = Enum.TextXAlignment.Left,
}, Header)

local CloseButton = create("TextButton", {
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -10, 0.5, -1),
	Size = UDim2.fromOffset(28, 28),
	BackgroundColor3 = Theme.Card,
	AutoButtonColor = false,
	Font = Enum.Font.GothamBold,
	Text = "X",
	TextColor3 = Theme.Text,
	TextSize = 13,
}, Header)
corner(CloseButton, 14)
CloseButton.MouseEnter:Connect(function() tween(CloseButton, 0.15, { BackgroundColor3 = Theme.Danger }) end)
CloseButton.MouseLeave:Connect(function() tween(CloseButton, 0.15, { BackgroundColor3 = Theme.Card }) end)

makeDraggable(Header, MainFrame)

-- Sidebar
local Sidebar = create("Frame", {
	Position = UDim2.new(0, 0, 0, 42),
	Size = UDim2.new(0, 120, 1, -42),
	BackgroundColor3 = Theme.Sidebar,
	BorderSizePixel = 0,
}, MainFrame)

local sidebarList = create("Frame", {
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 1, -30),
}, Sidebar)
create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, sidebarList)
create("UIPadding", {
	PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
}, sidebarList)

create("TextLabel", {
	AnchorPoint = Vector2.new(0, 1),
	Position = UDim2.new(0, 0, 1, -6),
	Size = UDim2.new(1, 0, 0, 16),
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	Text = "by MasensDev",
	TextColor3 = Theme.SubText,
	TextSize = 11,
}, Sidebar)

local PageHolder = create("Frame", {
	Position = UDim2.new(0, 120, 0, 42),
	Size = UDim2.new(1, -120, 1, -42),
	BackgroundTransparency = 1,
}, MainFrame)

-- Tab system
local tabs, pages = {}, {}

local function selectTab(name)
	for tName, btn in pairs(tabs) do
		local active = (tName == name)
		tween(btn, 0.15, {
			BackgroundColor3 = active and Theme.Accent or Theme.Sidebar,
			TextColor3 = active and Color3.new(1, 1, 1) or Theme.SubText,
		})
		pages[tName].Visible = active
	end
end

local function createTab(name, order)
	local btn = create("TextButton", {
		LayoutOrder = order,
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundColor3 = Theme.Sidebar,
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamSemibold,
		Text = name,
		TextColor3 = Theme.SubText,
		TextSize = 13,
	}, sidebarList)
	corner(btn, 8)

	local page = create("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Visible = false,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = Theme.Accent,
	}, PageHolder)
	create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, page)
	create("UIPadding", {
		PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 12),
	}, page)

	tabs[name] = btn
	pages[name] = page
	btn.MouseButton1Click:Connect(function() selectTab(name) end)
	return page
end

local mainPage = createTab("Main", 1)
local playerPage = createTab("Pemain", 2)
local autoPage = createTab("Otomatis", 3)
local settingsPage = createTab("Settings", 4)

-- ==========================================
-- UI COMPONENTS
-- ==========================================
local function createSection(parent, text)
	return create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = string.upper(text),
		TextColor3 = Theme.Accent2,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, parent)
end

local function createButton(parent, text, callback)
	local btn = create("TextButton", {
		Size = UDim2.new(1, 0, 0, 38),
		BackgroundColor3 = Theme.Card,
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamMedium,
		Text = text,
		TextColor3 = Theme.Text,
		TextSize = 13,
	}, parent)
	corner(btn, 8)
	stroke(btn, Theme.Stroke, 1)
	btn.MouseEnter:Connect(function() tween(btn, 0.15, { BackgroundColor3 = Theme.CardHover }) end)
	btn.MouseLeave:Connect(function() tween(btn, 0.15, { BackgroundColor3 = Theme.Card }) end)
	btn.MouseButton1Click:Connect(callback)
	return btn
end

-- Mengembalikan fungsi setter (untuk mengubah status switch dari kode)
local function createToggle(parent, text, default, callback)
	local state = default
	local card = create("TextButton", {
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = Theme.Card,
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Text = "",
	}, parent)
	corner(card, 8)
	stroke(card, Theme.Stroke, 1)

	create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 0),
		Size = UDim2.new(1, -70, 1, 0),
		Font = Enum.Font.GothamMedium,
		Text = text,
		TextColor3 = Theme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, card)

	local track = create("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(40, 20),
		BackgroundColor3 = Theme.Off,
		BorderSizePixel = 0,
	}, card)
	corner(track, 10)

	local knob = create("Frame", {
		Position = UDim2.new(0, 2, 0.5, -8),
		Size = UDim2.fromOffset(16, 16),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
	}, track)
	corner(knob, 8)

	local function render(animate)
		local trackGoal = { BackgroundColor3 = state and Theme.Accent or Theme.Off }
		local knobGoal = { Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8) }
		if animate then
			tween(track, 0.15, trackGoal)
			tween(knob, 0.15, knobGoal)
		else
			track.BackgroundColor3 = trackGoal.BackgroundColor3
			knob.Position = knobGoal.Position
		end
	end
	render(false)

	card.MouseEnter:Connect(function() tween(card, 0.15, { BackgroundColor3 = Theme.CardHover }) end)
	card.MouseLeave:Connect(function() tween(card, 0.15, { BackgroundColor3 = Theme.Card }) end)
	card.MouseButton1Click:Connect(function()
		state = not state
		render(true)
		callback(state)
	end)

	return function(value)
		state = value
		render(true)
	end
end

local function createInputNumber(parent, labelText, defaultValue, minValue, maxValue, callback)
	local current = defaultValue
	local card = create("Frame", {
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = Theme.Card,
		BorderSizePixel = 0,
	}, parent)
	corner(card, 8)
	stroke(card, Theme.Stroke, 1)

	create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 0),
		Size = UDim2.new(0.62, -12, 1, 0),
		Font = Enum.Font.GothamMedium,
		Text = labelText,
		TextColor3 = Theme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, card)

	local box = create("TextBox", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.new(0.34, 0, 0, 26),
		BackgroundColor3 = Theme.Bg,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Text = tostring(defaultValue),
		TextColor3 = Theme.Text,
		TextSize = 13,
		ClearTextOnFocus = false,
	}, card)
	corner(box, 6)
	local boxStroke = stroke(box, Theme.Stroke, 1)

	box.Focused:Connect(function() tween(boxStroke, 0.15, { Color = Theme.Accent }) end)
	box.FocusLost:Connect(function()
		tween(boxStroke, 0.15, { Color = Theme.Stroke })
		local num = tonumber(box.Text)
		if num then
			num = math.clamp(num, minValue, maxValue)
			current = num
			box.Text = tostring(num)
			callback(num)
		else
			box.Text = tostring(current)
		end
	end)
end

-- Dropdown pilihan (klik untuk buka daftar, klik opsi untuk memilih)
local function createDropdown(parent, labelText, options, defaultValue, callback)
	local current = defaultValue
	local isListOpen = false

	local wrapper = create("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	}, parent)
	create("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, wrapper)

	local head = create("TextButton", {
		LayoutOrder = 1,
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = Theme.Card,
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Text = "",
	}, wrapper)
	corner(head, 8)
	local headStroke = stroke(head, Theme.Stroke, 1)

	create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 0),
		Size = UDim2.new(0.35, -12, 1, 0),
		Font = Enum.Font.GothamMedium,
		Text = labelText,
		TextColor3 = Theme.SubText,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, head)

	local valueLabel = create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0.35, 0, 0, 0),
		Size = UDim2.new(0.65, -34, 1, 0),
		Font = Enum.Font.GothamBold,
		Text = current,
		TextColor3 = Theme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, head)

	local arrow = create("TextLabel", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(14, 14),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = "v",
		TextColor3 = Theme.Accent2,
		TextSize = 13,
	}, head)

	local list = create("ScrollingFrame", {
		LayoutOrder = 2,
		Size = UDim2.new(1, 0, 0, 150),
		BackgroundColor3 = Theme.Sidebar,
		BorderSizePixel = 0,
		Visible = false,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Theme.Accent,
	}, wrapper)
	corner(list, 8)
	stroke(list, Theme.Stroke, 1)
	create("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }, list)
	create("UIPadding", {
		PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4),
		PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4),
	}, list)

	local optionButtons = {}
	local function renderOptions()
		for name, b in pairs(optionButtons) do
			local selected = (name == current)
			b.BackgroundColor3 = selected and Theme.Accent or Theme.Card
			b.TextColor3 = selected and Color3.new(1, 1, 1) or Theme.Text
		end
	end

	local function setListOpen(value)
		isListOpen = value
		list.Visible = value
		arrow.Text = value and "^" or "v"
		tween(headStroke, 0.15, { Color = value and Theme.Accent or Theme.Stroke })
	end

	for i, name in ipairs(options) do
		local b = create("TextButton", {
			LayoutOrder = i,
			Size = UDim2.new(1, -4, 0, 28),
			BackgroundColor3 = Theme.Card,
			AutoButtonColor = false,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamMedium,
			Text = name,
			TextColor3 = Theme.Text,
			TextSize = 12,
		}, list)
		corner(b, 6)
		b.MouseButton1Click:Connect(function()
			current = name
			valueLabel.Text = name
			renderOptions()
			setListOpen(false)
			callback(name)
		end)
		optionButtons[name] = b
	end
	renderOptions()

	head.MouseEnter:Connect(function() tween(head, 0.15, { BackgroundColor3 = Theme.CardHover }) end)
	head.MouseLeave:Connect(function() tween(head, 0.15, { BackgroundColor3 = Theme.Card }) end)
	head.MouseButton1Click:Connect(function() setListOpen(not isListOpen) end)
end

-- ==========================================
-- TOMBOL BUKA / TUTUP GUI (BULAT "MD")
-- ==========================================
local isOpen = true

local function setOpen(open)
	isOpen = open
	local target = fitScale()
	if open then
		MainFrame.Visible = true
		uiScale.Scale = target * 0.85
		TweenService:Create(uiScale, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = target }):Play()
	else
		local tw = TweenService:Create(uiScale, TweenInfo.new(0.15, Enum.EasingStyle.Quad), { Scale = target * 0.85 })
		tw.Completed:Connect(function()
			if not isOpen then MainFrame.Visible = false end
		end)
		tw:Play()
	end
end

local ToggleGuiButton = create("TextButton", {
	Name = "ToggleGuiButton",
	Position = UDim2.new(0, 16, 0.5, -26),
	Size = UDim2.fromOffset(52, 52),
	BackgroundColor3 = Color3.new(1, 1, 1),
	AutoButtonColor = false,
	Font = Enum.Font.GothamBlack,
	Text = "MD",
	TextColor3 = Color3.new(1, 1, 1),
	TextSize = 18,
	ZIndex = 10,
}, ScreenGui)
corner(ToggleGuiButton, 26)
stroke(ToggleGuiButton, Color3.fromRGB(255, 255, 255), 2).Transparency = 0.6
create("UIGradient", {
	Color = ColorSequence.new(Theme.Accent, Theme.Accent2),
	Rotation = 45,
}, ToggleGuiButton)

local wasDragged = makeDraggable(ToggleGuiButton, ToggleGuiButton)
ToggleGuiButton.Activated:Connect(function()
	if wasDragged() then return end
	setOpen(not isOpen)
end)
CloseButton.MouseButton1Click:Connect(function() setOpen(false) end)

-- ==========================================
-- TAB 1: MAIN
-- ==========================================
createSection(mainPage, "Gerakan")

createToggle(mainPage, "Infinite Jump", false, function(state)
	infJumpEnabled = state
end)

UserInputService.JumpRequest:Connect(function()
	if infJumpEnabled then
		local hum = myHumanoid()
		if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
	end
end)

createToggle(mainPage, "No Clip", false, function(state)
	noclipEnabled = state
end)

RunService.Stepped:Connect(function()
	if noclipEnabled then
		local char = LocalPlayer.Character
		if char then
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then part.CanCollide = false end
			end
		end
	end
end)

createInputNumber(mainPage, "Kecepatan (WalkSpeed)", 16, 0, 500, function(value)
	customSpeed = value
	local hum = myHumanoid()
	if hum then hum.WalkSpeed = customSpeed end
end)

createInputNumber(mainPage, "Jump Power", 50, 0, 500, function(value)
	customJump = value
	local hum = myHumanoid()
	if hum then
		hum.UseJumpPower = true
		hum.JumpPower = customJump
	end
end)

createSection(mainPage, "Fly")

-- Tombol naik/turun di layar (untuk HP) - muncul saat Fly aktif
local flyUp, flyDown = false, false
local flyButtons = create("Frame", {
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -20, 0.5, 0),
	Size = UDim2.fromOffset(60, 130),
	BackgroundTransparency = 1,
	Visible = false,
}, ScreenGui)

local function createHoldButton(text, yPos, setter)
	local b = create("TextButton", {
		Position = UDim2.new(0, 0, 0, yPos),
		Size = UDim2.fromOffset(60, 60),
		BackgroundColor3 = Theme.Header,
		BackgroundTransparency = 0.1,
		AutoButtonColor = false,
		Font = Enum.Font.GothamBold,
		Text = text,
		TextColor3 = Theme.Text,
		TextSize = 13,
	}, flyButtons)
	corner(b, 30)
	stroke(b, Theme.Accent, 2)
	b.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			setter(true)
			tween(b, 0.1, { BackgroundColor3 = Theme.Accent })
		end
	end)
	b.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			setter(false)
			tween(b, 0.1, { BackgroundColor3 = Theme.Header })
		end
	end)
end
createHoldButton("UP", 0, function(v) flyUp = v end)
createHoldButton("DOWN", 70, function(v) flyDown = v end)

local flyBV, flyBG, flyConn = nil, nil, nil

local function stopFly()
	if flyConn then flyConn:Disconnect() flyConn = nil end
	if flyBV then flyBV:Destroy() flyBV = nil end
	if flyBG then flyBG:Destroy() flyBG = nil end
	flyUp, flyDown = false, false
	flyButtons.Visible = false
	local hum = myHumanoid()
	if hum then hum.PlatformStand = false end
end

local function startFly()
	local root, hum = myRoot(), myHumanoid()
	if not root or not hum then return false end
	stopFly()

	hum.PlatformStand = true
	flyBV = create("BodyVelocity", {
		MaxForce = Vector3.new(1e9, 1e9, 1e9),
		Velocity = Vector3.zero,
	}, root)
	flyBG = create("BodyGyro", {
		MaxTorque = Vector3.new(1e9, 1e9, 1e9),
		P = 9e4,
		CFrame = root.CFrame,
	}, root)
	flyButtons.Visible = true

	flyConn = RunService.RenderStepped:Connect(function()
		local r, h = myRoot(), myHumanoid()
		if not r or not h or not flyBV or not flyBV.Parent then return end
		local cam = workspace.CurrentCamera

		local vertical = 0
		if flyUp or UserInputService:IsKeyDown(Enum.KeyCode.Space) then vertical += 1 end
		if flyDown or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vertical -= 1 end

		flyBV.Velocity = h.MoveDirection * flySpeed + Vector3.new(0, vertical * flySpeed, 0)

		local look = cam.CFrame.LookVector
		local flat = Vector3.new(look.X, 0, look.Z)
		if flat.Magnitude < 0.01 then flat = r.CFrame.LookVector * Vector3.new(1, 0, 1) end
		flyBG.CFrame = CFrame.new(r.Position, r.Position + flat)
	end)
	return true
end

local setFlySwitch
setFlySwitch = createToggle(mainPage, "Fly Mode", false, function(state)
	flyEnabled = state
	if state then
		if not startFly() then
			flyEnabled = false
			setFlySwitch(false)
			notify("Karakter belum siap")
		end
	else
		stopFly()
	end
end)

createInputNumber(mainPage, "Kecepatan Fly", 50, 1, 500, function(value)
	flySpeed = value
end)

create("TextLabel", {
	Size = UDim2.new(1, 0, 0, 28),
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	Text = "Gerak: joystick / WASD. Naik-turun: tombol UP/DOWN di layar atau Space / Ctrl.",
	TextColor3 = Theme.SubText,
	TextSize = 11,
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Left,
}, mainPage)

-- Sinkronisasi saat respawn
LocalPlayer.CharacterAdded:Connect(function(char)
	local hum = char:WaitForChild("Humanoid")
	hum.WalkSpeed = customSpeed
	hum.UseJumpPower = true
	hum.JumpPower = customJump
	if flyEnabled then
		stopFly()
		task.wait(0.5)
		if flyEnabled then startFly() end
	end
end)

-- ==========================================
-- TAB 2: PEMAIN (pilih pemain di server)
-- ==========================================
createSection(playerPage, "Target Terpilih")

local selectedCard = create("Frame", {
	Size = UDim2.new(1, 0, 0, 64),
	BackgroundColor3 = Theme.CardActive,
	BorderSizePixel = 0,
}, playerPage)
corner(selectedCard, 10)
stroke(selectedCard, Theme.Accent, 1)

local selectedAvatar = create("ImageLabel", {
	Position = UDim2.new(0, 10, 0.5, -22),
	Size = UDim2.fromOffset(44, 44),
	BackgroundColor3 = Theme.Bg,
	BorderSizePixel = 0,
	Image = "",
}, selectedCard)
corner(selectedAvatar, 22)

local selectedNick = create("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 64, 0, 12),
	Size = UDim2.new(1, -74, 0, 20),
	Font = Enum.Font.GothamBold,
	Text = "Belum ada target",
	TextColor3 = Theme.Text,
	TextSize = 15,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextTruncate = Enum.TextTruncate.AtEnd,
}, selectedCard)

local selectedUser = create("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 64, 0, 33),
	Size = UDim2.new(1, -74, 0, 18),
	Font = Enum.Font.Gotham,
	Text = "Pilih pemain dari daftar di bawah",
	TextColor3 = Theme.SubText,
	TextSize = 12,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextTruncate = Enum.TextTruncate.AtEnd,
}, selectedCard)

-- Cache foto profil
local thumbCache = {}
local function getThumb(userId)
	if thumbCache[userId] then return thumbCache[userId] end
	local ok, img = pcall(function()
		return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
	end)
	if ok and img then
		thumbCache[userId] = img
		return img
	end
	return ""
end

local function updateSelectedCard()
	if selectedTargetPlayer then
		selectedNick.Text = selectedTargetPlayer.DisplayName
		selectedUser.Text = "@" .. selectedTargetPlayer.Name
		local plr = selectedTargetPlayer
		task.spawn(function()
			local img = getThumb(plr.UserId)
			if selectedTargetPlayer == plr then selectedAvatar.Image = img end
		end)
	else
		selectedNick.Text = "Belum ada target"
		selectedUser.Text = "Pilih pemain dari daftar di bawah"
		selectedAvatar.Image = ""
	end
end

-- Aksi target
createButton(playerPage, "Teleport ke Pemain Terpilih", function()
	local root = myRoot()
	local tRoot = selectedTargetPlayer and rootOf(selectedTargetPlayer.Character)
	if root and tRoot then
		root.CFrame = tRoot.CFrame + Vector3.new(0, 3, 0)
	else
		notify("Pilih pemain dulu / karakter target belum ada")
	end
end)

local followConn = nil
createToggle(playerPage, "Follow Pemain Terpilih", false, function(state)
	if followConn then followConn:Disconnect() followConn = nil end
	if state then
		followConn = RunService.RenderStepped:Connect(function()
			local root = myRoot()
			local tRoot = selectedTargetPlayer and rootOf(selectedTargetPlayer.Character)
			if root and tRoot then
				-- menempel 3 stud di belakang target
				root.CFrame = tRoot.CFrame * CFrame.new(0, 0, 3)
			end
		end)
	end
end)

local playerSection = createSection(playerPage, "Pemain di Server")

local refreshPlayerList

createButton(playerPage, "Refresh Daftar Pemain", function()
	refreshPlayerList()
	notify("Daftar diperbarui: " .. (#Players:GetPlayers() - 1) .. " pemain lain di server")
end)

local searchBox = create("TextBox", {
	Size = UDim2.new(1, 0, 0, 34),
	BackgroundColor3 = Theme.Card,
	BorderSizePixel = 0,
	Font = Enum.Font.Gotham,
	PlaceholderText = "Cari nickname / username...",
	PlaceholderColor3 = Theme.SubText,
	Text = "",
	TextColor3 = Theme.Text,
	TextSize = 13,
	ClearTextOnFocus = false,
}, playerPage)
corner(searchBox, 8)
local searchStroke = stroke(searchBox, Theme.Stroke, 1)
create("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }, searchBox)
searchBox.Focused:Connect(function() tween(searchStroke, 0.15, { Color = Theme.Accent }) end)
searchBox.FocusLost:Connect(function() tween(searchStroke, 0.15, { Color = Theme.Stroke }) end)

local playerListHolder = create("Frame", {
	Size = UDim2.new(1, 0, 0, 0),
	AutomaticSize = Enum.AutomaticSize.Y,
	BackgroundTransparency = 1,
}, playerPage)
create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, playerListHolder)

local function buildPlayerCard(plr, order)
	local isSelected = (plr == selectedTargetPlayer)
	local card = create("TextButton", {
		LayoutOrder = order,
		Size = UDim2.new(1, 0, 0, 52),
		BackgroundColor3 = isSelected and Theme.CardActive or Theme.Card,
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Text = "",
	}, playerListHolder)
	corner(card, 8)
	stroke(card, isSelected and Theme.Accent or Theme.Stroke, 1)

	local avatar = create("ImageLabel", {
		Position = UDim2.new(0, 8, 0.5, -19),
		Size = UDim2.fromOffset(38, 38),
		BackgroundColor3 = Theme.Bg,
		BorderSizePixel = 0,
		Image = "",
	}, card)
	corner(avatar, 19)
	task.spawn(function()
		avatar.Image = getThumb(plr.UserId)
	end)

	create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 56, 0, 8),
		Size = UDim2.new(1, -64, 0, 18),
		Font = Enum.Font.GothamBold,
		Text = plr.DisplayName,
		TextColor3 = Theme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, card)

	create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 56, 0, 27),
		Size = UDim2.new(1, -64, 0, 16),
		Font = Enum.Font.Gotham,
		Text = "@" .. plr.Name,
		TextColor3 = Theme.SubText,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, card)

	if not isSelected then
		card.MouseEnter:Connect(function() tween(card, 0.15, { BackgroundColor3 = Theme.CardHover }) end)
		card.MouseLeave:Connect(function() tween(card, 0.15, { BackgroundColor3 = Theme.Card }) end)
	end

	card.MouseButton1Click:Connect(function()
		selectedTargetPlayer = plr
		updateSelectedCard()
		refreshPlayerList()
		notify("Target: " .. plr.DisplayName .. " (@" .. plr.Name .. ")")
	end)
end

refreshPlayerList = function()
	-- target yang sudah keluar dari server dilepas otomatis
	if selectedTargetPlayer and selectedTargetPlayer.Parent ~= Players then
		selectedTargetPlayer = nil
		updateSelectedCard()
	end
	for _, child in ipairs(playerListHolder:GetChildren()) do
		if child:IsA("GuiObject") then child:Destroy() end
	end

	local query = string.lower(searchBox.Text)
	local list = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			if query == "" or string.find(string.lower(plr.Name), query, 1, true)
				or string.find(string.lower(plr.DisplayName), query, 1, true) then
				table.insert(list, plr)
			end
		end
	end
	table.sort(list, function(a, b) return string.lower(a.DisplayName) < string.lower(b.DisplayName) end)

	playerSection.Text = "PEMAIN DI SERVER (" .. (#Players:GetPlayers() - 1) .. ")"

	if #list == 0 then
		create("TextLabel", {
			Size = UDim2.new(1, 0, 0, 40),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Text = "Tidak ada pemain lain yang cocok",
			TextColor3 = Theme.SubText,
			TextSize = 12,
		}, playerListHolder)
		return
	end

	for i, plr in ipairs(list) do
		buildPlayerCard(plr, i)
	end
end

searchBox:GetPropertyChangedSignal("Text"):Connect(function() refreshPlayerList() end)

Players.PlayerAdded:Connect(function() refreshPlayerList() end)
Players.PlayerRemoving:Connect(function(plr)
	if plr == selectedTargetPlayer then
		selectedTargetPlayer = nil
		updateSelectedCard()
	end
	task.defer(refreshPlayerList)
end)

refreshPlayerList()

-- ==========================================
-- TAB 3: OTOMATIS
-- ==========================================
createSection(autoPage, "Teleport Checkpoint")

local cpNames = {}
for i = 1, 30 do
	cpNames[#cpNames + 1] = "Checkpoint " .. i
end
cpNames[#cpNames + 1] = "Summit"

local selectedCP = cpNames[1]
createDropdown(autoPage, "Tujuan", cpNames, selectedCP, function(value)
	selectedCP = value
end)

createButton(autoPage, "Teleport ke Checkpoint Terpilih", function()
	local root = myRoot()
	local pos = checkpointCoords[selectedCP]
	if root and pos then
		root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
		notify("Teleport ke " .. selectedCP)
	else
		notify("Karakter belum siap")
	end
end)

createSection(autoPage, "Auto Checkpoint")

-- Tanpa batas maksimal (minimal 1 stud/s)
createInputNumber(autoPage, "Kecepatan Otomatis CP (studs/s)", 50, 1, math.huge, function(value)
	teleportSpeed = value
end)

local statusLabel = create("TextLabel", {
	Size = UDim2.new(1, 0, 0, 20),
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	Text = "Status: nonaktif",
	TextColor3 = Theme.SubText,
	TextSize = 12,
	TextXAlignment = Enum.TextXAlignment.Left,
}, autoPage)

local autoCPRun = 0

local function isRunActive(run)
	return autoCPEnabled and run == autoCPRun
end

local function smoothTeleportTo(target, run)
	local root = myRoot()
	if not root then return end

	local startPos = root.Position
	local distance = (target - startPos).Magnitude
	local duration = distance / math.max(teleportSpeed, 1)
	local elapsed = 0

	while elapsed < duration and isRunActive(run) do
		elapsed += RunService.RenderStepped:Wait()
		root = myRoot()
		if not root then return end
		root.CFrame = CFrame.new(startPos:Lerp(target, math.clamp(elapsed / duration, 0, 1)))
	end

	if isRunActive(run) then
		root = myRoot()
		if root then root.CFrame = CFrame.new(target) end
	end
end

-- Tunggu sampai karakter hidup & siap
local function waitUntilAlive(run)
	while isRunActive(run) do
		local hum = myHumanoid()
		if myRoot() and hum and hum.Health > 0 then break end
		task.wait(0.25)
	end
end

-- Reset checkpoint lewat RemoteEvent (dipanggil setelah menyentuh Summit)
local function resetCheckpoint(run)
	local remote = game:GetService("ReplicatedStorage"):FindFirstChild("ResetCPEvent")
	if remote then
		local ok = pcall(function() remote:FireServer() end)
		if not ok then notify("Gagal memanggil ResetCPEvent") end
	else
		notify("ResetCPEvent tidak ditemukan di ReplicatedStorage")
	end

	-- beri waktu server memproses reset, lalu pastikan karakter siap
	if isRunActive(run) then task.wait(2) end
	waitUntilAlive(run)
end

local function autoCPLoop(run)
	-- Siklus pertama mengikuti CP di leaderstats, siklus berikutnya (setelah Summit) mulai dari 1
	local useSavedProgress = true

	while isRunActive(run) do
		waitUntilAlive(run)

		local startIndex = 1
		if useSavedProgress then
			local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
			local cpValue = leaderstats and leaderstats:FindFirstChild("CP")
			if cpValue and cpValue.Value > 0 then
				startIndex = math.clamp(math.floor(cpValue.Value), 1, 30)
			end
		end
		useSavedProgress = false

		for i = startIndex, 30 do
			if not isRunActive(run) then break end
			waitUntilAlive(run) -- jika mati di tengah jalan, tunggu respawn lalu lanjut
			if not isRunActive(run) then break end

			local cpName = "Checkpoint " .. i
			if checkpointCoords[cpName] then
				statusLabel.Text = "Status: menuju " .. cpName
				smoothTeleportTo(checkpointCoords[cpName], run)
				task.wait(0.5)
			end
		end

		if isRunActive(run) and checkpointCoords["Summit"] then
			statusLabel.Text = "Status: menuju Summit"
			smoothTeleportTo(checkpointCoords["Summit"], run)

			if isRunActive(run) then
				statusLabel.Text = "Status: Summit! reset checkpoint..."
				task.wait(1)
				resetCheckpoint(run)
				if isRunActive(run) then
					statusLabel.Text = "Status: mengulang dari Checkpoint 1"
				end
			end
		end

		task.wait(1)
	end
	if run == autoCPRun then statusLabel.Text = "Status: nonaktif" end
end

createToggle(autoPage, "Otomatis Checkpoint Menuju", false, function(state)
	autoCPRun += 1
	autoCPEnabled = state
	if state then
		task.spawn(autoCPLoop, autoCPRun)
	else
		statusLabel.Text = "Status: nonaktif"
	end
end)

-- ==========================================
-- TAB 4: SETTINGS
-- ==========================================
createSection(settingsPage, "Server")

createButton(settingsPage, "Rejoin Server", function()
	if #Players:GetPlayers() <= 1 then
		TeleportService:Teleport(game.PlaceId, LocalPlayer)
	else
		TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
	end
end)

createButton(settingsPage, "Ganti Server (Server Hop)", function()
	local success = pcall(function()
		local servers = {}
		local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
		local req = HttpService:JSONDecode(game:HttpGet(url))
		for _, server in ipairs(req.data) do
			if server.playing < server.maxPlayers and server.id ~= game.JobId then
				table.insert(servers, server.id)
			end
		end
		if #servers > 0 then
			TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer)
		else
			notify("Tidak ada server lain yang tersedia")
		end
	end)
	if not success then
		notify("Gagal melakukan server hop otomatis")
	end
end)

createSection(settingsPage, "Lainnya")

-- Anti AFK (event hanya disambungkan sekali)
LocalPlayer.Idled:Connect(function()
	if antiAFKEnabled then
		VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
		task.wait(1)
		VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
	end
end)

createToggle(settingsPage, "Anti AFK", false, function(state)
	antiAFKEnabled = state
end)

createToggle(settingsPage, "Mode Low Graphic", false, function(state)
	lowGraphicEnabled = state
	if lowGraphicEnabled then
		settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
		for _, v in ipairs(workspace:GetDescendants()) do
			if v:IsA("BasePart") then
				v.Material = Enum.Material.SmoothPlastic
				v.Reflectance = 0
			elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
				v.Enabled = false
			end
		end
	else
		settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
	end
end)

-- ==========================================
-- INIT
-- ==========================================
selectTab("Main")

end -- akhir StartHub

-- ==========================================
-- GUI KEY
-- ==========================================
local function ShowKeyGui()
	local Theme = {
		Bg      = Color3.fromRGB(16, 16, 22),
		Header  = Color3.fromRGB(22, 22, 30),
		Card    = Color3.fromRGB(30, 30, 41),
		Hover   = Color3.fromRGB(40, 40, 54),
		Accent  = Color3.fromRGB(124, 92, 255),
		Accent2 = Color3.fromRGB(70, 170, 255),
		Text    = Color3.fromRGB(240, 240, 248),
		SubText = Color3.fromRGB(150, 150, 172),
		Stroke  = Color3.fromRGB(52, 52, 70),
		Ok      = Color3.fromRGB(70, 200, 120),
		Warn    = Color3.fromRGB(255, 190, 80),
		Danger  = Color3.fromRGB(235, 80, 90),
	}

	local function create(class, props, parent)
		local obj = Instance.new(class)
		for k, v in pairs(props) do obj[k] = v end
		if parent then obj.Parent = parent end
		return obj
	end
	local function corner(obj, r) return create("UICorner", { CornerRadius = UDim.new(0, r) }, obj) end
	local function stroke(obj, color, th)
		return create("UIStroke", { Color = color or Theme.Stroke, Thickness = th or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, obj)
	end
	local function tween(obj, t, props)
		TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
	end

	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	if playerGui:FindFirstChild("MasensDevKey") then
		playerGui.MasensDevKey:Destroy()
	end

	local gui = create("ScreenGui", {
		Name = "MasensDevKey",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 1000,
	}, playerGui)

	local frame = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.fromOffset(360, 250),
		BackgroundColor3 = Theme.Bg,
		BorderSizePixel = 0,
		ClipsDescendants = true,
	}, gui)
	corner(frame, 12)
	stroke(frame, Theme.Stroke, 1)

	local scale = create("UIScale", {}, frame)
	local function fit()
		local cam = workspace.CurrentCamera
		if not cam then return 1 end
		local vp = cam.ViewportSize
		return math.clamp(math.min(vp.X / 400, vp.Y / 290), 0.5, 1)
	end
	local target = fit()
	scale.Scale = target * 0.85
	TweenService:Create(scale, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = target }):Play()

	-- Header
	local header = create("Frame", {
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundColor3 = Theme.Header,
		BorderSizePixel = 0,
	}, frame)
	local line = create("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 2),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
	}, header)
	create("UIGradient", { Color = ColorSequence.new(Theme.Accent, Theme.Accent2) }, line)

	create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 16, 0, 5),
		Size = UDim2.new(1, -70, 0, 20),
		Font = Enum.Font.GothamBold,
		Text = "MasensDev Hub",
		TextColor3 = Theme.Text,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, header)
	create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 16, 0, 25),
		Size = UDim2.new(1, -70, 0, 14),
		Font = Enum.Font.Gotham,
		Text = "Verifikasi Key",
		TextColor3 = Theme.SubText,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, header)

	local closeBtn = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, -1),
		Size = UDim2.fromOffset(28, 28),
		BackgroundColor3 = Theme.Card,
		AutoButtonColor = false,
		Font = Enum.Font.GothamBold,
		Text = "X",
		TextColor3 = Theme.Text,
		TextSize = 13,
	}, header)
	corner(closeBtn, 14)
	closeBtn.MouseEnter:Connect(function() tween(closeBtn, 0.15, { BackgroundColor3 = Theme.Danger }) end)
	closeBtn.MouseLeave:Connect(function() tween(closeBtn, 0.15, { BackgroundColor3 = Theme.Card }) end)
	closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

	-- Drag (mouse + touch)
	do
		local dragging, dragStart, startPos = false, nil, nil
		header.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = frame.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then dragging = false end
				end)
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local d = input.Position - dragStart
				frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
			end
		end)
	end

	-- Deskripsi
	create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 20, 0, 54),
		Size = UDim2.new(1, -40, 0, 34),
		Font = Enum.Font.Gotham,
		Text = "Tekan Get Link untuk mengambil key, lalu tempel key di kolom bawah dan tekan Check Key.",
		TextColor3 = Theme.SubText,
		TextSize = 12,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
	}, frame)

	-- Input key
	local keyBox = create("TextBox", {
		Position = UDim2.new(0, 20, 0, 94),
		Size = UDim2.new(1, -40, 0, 38),
		BackgroundColor3 = Theme.Card,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamMedium,
		PlaceholderText = "Masukkan key di sini...",
		PlaceholderColor3 = Theme.SubText,
		Text = "",
		TextColor3 = Theme.Text,
		TextSize = 14,
		ClearTextOnFocus = false,
	}, frame)
	corner(keyBox, 8)
	local keyStroke = stroke(keyBox, Theme.Stroke, 1)
	create("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) }, keyBox)
	keyBox.Focused:Connect(function() tween(keyStroke, 0.15, { Color = Theme.Accent }) end)
	keyBox.FocusLost:Connect(function() tween(keyStroke, 0.15, { Color = Theme.Stroke }) end)

	-- Tombol Get Link
	local getLinkBtn = create("TextButton", {
		Position = UDim2.new(0, 20, 0, 142),
		Size = UDim2.new(0.5, -25, 0, 38),
		BackgroundColor3 = Theme.Card,
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Text = "Get Link",
		TextColor3 = Theme.Text,
		TextSize = 13,
	}, frame)
	corner(getLinkBtn, 8)
	stroke(getLinkBtn, Theme.Stroke, 1)
	getLinkBtn.MouseEnter:Connect(function() tween(getLinkBtn, 0.15, { BackgroundColor3 = Theme.Hover }) end)
	getLinkBtn.MouseLeave:Connect(function() tween(getLinkBtn, 0.15, { BackgroundColor3 = Theme.Card }) end)

	-- Tombol Check Key
	local checkBtn = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -20, 0, 142),
		Size = UDim2.new(0.5, -25, 0, 38),
		BackgroundColor3 = Color3.new(1, 1, 1),
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Text = "Check Key",
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 13,
	}, frame)
	corner(checkBtn, 8)
	create("UIGradient", { Color = ColorSequence.new(Theme.Accent, Theme.Accent2), Rotation = 20 }, checkBtn)

	-- Status & footer
	local status = create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 20, 0, 188),
		Size = UDim2.new(1, -40, 0, 30),
		Font = Enum.Font.GothamMedium,
		Text = "",
		TextColor3 = Theme.SubText,
		TextSize = 12,
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top,
	}, frame)

	create("TextLabel", {
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 1, -8),
		Size = UDim2.new(1, 0, 0, 14),
		Font = Enum.Font.Gotham,
		Text = "Key berlaku " .. math.floor(KEY_DURATION / 3600) .. " jam  •  by MasensDev",
		TextColor3 = Theme.SubText,
		TextSize = 11,
	}, frame)

	local function setStatus(text, color)
		status.Text = text
		status.TextColor3 = color or Theme.SubText
	end

	local function shake()
		task.spawn(function()
			local base = frame.Position
			for _ = 1, 3 do
				frame.Position = base + UDim2.fromOffset(8, 0)
				task.wait(0.04)
				frame.Position = base - UDim2.fromOffset(8, 0)
				task.wait(0.04)
			end
			frame.Position = base
		end)
	end

	-- Get Link -> salin link ke clipboard
	getLinkBtn.MouseButton1Click:Connect(function()
		local copyFn = (typeof(setclipboard) == "function" and setclipboard)
			or (typeof(toclipboard) == "function" and toclipboard)
			or nil
		local copied = false
		if copyFn then
			copied = pcall(copyFn, KEY_LINK)
		end
		if copied then
			setStatus("Link berhasil disalin! Buka browser lalu tempel (paste) link-nya.", Theme.Ok)
		else
			setStatus("Executor tidak mendukung copy. Salin manual: " .. KEY_LINK, Theme.Warn)
		end
	end)

	-- Check Key
	local busy = false
	checkBtn.MouseButton1Click:Connect(function()
		if busy then return end
		local key = trim(keyBox.Text)
		if key == "" then
			setStatus("Masukkan key terlebih dahulu.", Theme.Warn)
			shake()
			return
		end

		busy = true
		setStatus("Memeriksa key...", Theme.SubText)
		task.spawn(function()
			if isValidKey(key) then
				saveKey(key)
				setStatus("Key valid! Membuka hub...", Theme.Ok)
				task.wait(0.8)
				gui:Destroy()
				StartHub()
			else
				setStatus("Key salah atau sudah tidak berlaku.", Theme.Danger)
				shake()
				busy = false
			end
		end)
	end)
end

-- ==========================================
-- START: cek key tersimpan (12 jam)
-- ==========================================
local saved = loadSavedKey()
local keyStillValid = false

if type(saved) == "table" and saved.key and tonumber(saved.time) then
	local age = now() - tonumber(saved.time)
	if age >= 0 and age < KEY_DURATION and isValidKey(trim(saved.key)) then
		keyStillValid = true
		local remaining = KEY_DURATION - age
		print(string.format("[MasensDev] Key masih aktif, sisa %d jam %d menit",
			math.floor(remaining / 3600), math.floor((remaining % 3600) / 60)))
	else
		clearSavedKey() -- sudah lewat 12 jam / key sudah dicabut -> wajib input key lagi
	end
end

if keyStillValid then
	StartHub()
else
	ShowKeyGui()
end
