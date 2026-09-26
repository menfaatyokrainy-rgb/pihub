-- ================================
-- Modern UI Library (Luau / Roblox)
-- Kullanım:
--   local a = LibraryName:Window("Pencere Başlığı")
--   local Tab1 = a:Tab("Sekme Adı", "rbxassetid://0")
-- ================================

local Library = {}
Library.__index = Library

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ================= THEME =================
local Theme = {
    Background = Color3.fromRGB(24, 24, 28),
    Section    = Color3.fromRGB(32, 32, 38),
    Element    = Color3.fromRGB(40, 40, 48),
    Accent     = Color3.fromRGB(88, 101, 242),
    Text       = Color3.fromRGB(235, 235, 240),
    SubText    = Color3.fromRGB(160, 160, 170),
    Stroke     = Color3.fromRGB(55, 55, 62),
}

-- ================= HELPERS =================
local function create(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    for _, child in ipairs(children or {}) do
        child.Parent = inst
    end
    return inst
end

local function corner(radius)
    return create("UICorner", { CornerRadius = UDim.new(0, radius or 8) })
end

local function stroke(color, thickness)
    return create("UIStroke", {
        Color = color or Theme.Stroke,
        Thickness = thickness or 1,
    })
end

local function tween(obj, props, time, style, dir)
    local t = TweenService:Create(obj, TweenInfo.new(
        time or 0.2,
        style or Enum.EasingStyle.Quad,
        dir or Enum.EasingDirection.Out
    ), props)
    t:Play()
    return t
end

local function makeDraggable(topbar, frame)
    local dragging, dragInput, dragStart, startPos

    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ================= ROOT GUI =================
local function getGuiParent()
    local ok, result = pcall(function()
        return gethui and gethui() or CoreGui
    end)
    if ok and result then
        return result
    end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local ScreenGui = create("ScreenGui", {
    Name = "ModernUILibrary",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 999,
})

pcall(function()
    ScreenGui.Parent = getGuiParent()
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- ================= WINDOW =================
function Library:Window(title)
    local Window = {}
    Window.Tabs = {}

    local Main = create("Frame", {
        Name = "Main",
        Size = UDim2.new(0, 560, 0, 380),
        Position = UDim2.new(0.5, -280, 0.5, -190),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Parent = ScreenGui,
    }, {
        corner(10),
        stroke(Theme.Stroke, 1),
    })

    -- subtle open animation
    Main.Size = UDim2.new(0, 0, 0, 0)
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    tween(Main, {
        Size = UDim2.new(0, 560, 0, 380),
        Position = UDim2.new(0.5, -280, 0.5, -190),
    }, 0.3)

    -- Topbar
    local TopBar = create("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Theme.Section,
        BorderSizePixel = 0,
        Parent = Main,
    }, {
        corner(10),
    })

    -- cover bottom corners of topbar so it looks flush
    create("Frame", {
        Size = UDim2.new(1, 0, 0, 12),
        Position = UDim2.new(0, 0, 1, -12),
        BackgroundColor3 = Theme.Section,
        BorderSizePixel = 0,
        Parent = TopBar,
    })

    create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = title or "Window",
        TextColor3 = Theme.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TopBar,
    })

    local CloseBtn = create("TextButton", {
        Name = "Close",
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -36, 0.5, -14),
        BackgroundColor3 = Theme.Element,
        Text = "✕",
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = Theme.SubText,
        AutoButtonColor = false,
        Parent = TopBar,
    }, { corner(6) })

    CloseBtn.MouseButton1Click:Connect(function()
        tween(Main, { Size = UDim2.new(0, 0, 0, 0) }, 0.2)
        task.delay(0.2, function()
            ScreenGui.Enabled = false
        end)
    end)

    local MinimizeBtn = create("TextButton", {
        Name = "Minimize",
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -70, 0.5, -14),
        BackgroundColor3 = Theme.Element,
        Text = "–",
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = Theme.SubText,
        AutoButtonColor = false,
        Parent = TopBar,
    }, { corner(6) })

    makeDraggable(TopBar, Main)

    -- Sidebar (tab list)
    local Sidebar = create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 150, 1, -42),
        Position = UDim2.new(0, 0, 0, 42),
        BackgroundColor3 = Theme.Section,
        BorderSizePixel = 0,
        Parent = Main,
    })

    local SidebarList = create("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    SidebarList.Parent = Sidebar

    create("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
    }).Parent = Sidebar

    -- Content container
    local ContentHolder = create("Frame", {
        Name = "ContentHolder",
        Size = UDim2.new(1, -150, 1, -42),
        Position = UDim2.new(0, 150, 0, 42),
        BackgroundTransparency = 1,
        Parent = Main,
    })

    local isMinimized = false
    local expandedSize = UDim2.new(0, 560, 0, 380)
    MinimizeBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            tween(Main, { Size = UDim2.new(0, 560, 0, 42) }, 0.25)
            Sidebar.Visible = false
            ContentHolder.Visible = false
        else
            tween(Main, { Size = expandedSize }, 0.25)
            task.delay(0.1, function()
                Sidebar.Visible = true
                ContentHolder.Visible = true
            end)
        end
    end)

    Window.Main = Main
    Window.ContentHolder = ContentHolder
    Window.Sidebar = Sidebar
    Window.ActiveTab = nil

    -- ================= TAB =================
    function Window:Tab(name, icon)
        local Tab = {}
        Tab.Elements = {}

        local TabButton = create("TextButton", {
            Name = name,
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundColor3 = Theme.Element,
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
            Parent = Sidebar,
        }, { corner(6) })

        local IconImg
        if icon and icon ~= "" then
            IconImg = create("ImageLabel", {
                Size = UDim2.new(0, 18, 0, 18),
                Position = UDim2.new(0, 8, 0.5, -9),
                BackgroundTransparency = 1,
                Image = icon,
                ImageColor3 = Theme.SubText,
                Parent = TabButton,
            })
        end

        create("TextLabel", {
            Size = UDim2.new(1, -(icon and 34 or 12), 1, 0),
            Position = UDim2.new(0, icon and 34 or 12, 0, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium,
            Text = name,
            TextColor3 = Theme.SubText,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = TabButton,
        })

        local Page = create("ScrollingFrame", {
            Name = name .. "Page",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            Parent = ContentHolder,
        })

        create("UIPadding", {
            PaddingTop = UDim.new(0, 12),
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
            PaddingBottom = UDim.new(0, 12),
        }).Parent = Page

        create("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }).Parent = Page

        Tab.Button = TabButton
        Tab.Page = Page

        local function selectTab()
            for _, other in pairs(Window.Tabs) do
                other.Page.Visible = false
                tween(other.Button, { BackgroundTransparency = 1 }, 0.15)
                local lbl = other.Button:FindFirstChildOfClass("TextLabel")
                if lbl then tween(lbl, { TextColor3 = Theme.SubText }, 0.15) end
                if other.IconImg then tween(other.IconImg, { ImageColor3 = Theme.SubText }, 0.15) end
            end

            Page.Visible = true
            tween(TabButton, { BackgroundTransparency = 0 }, 0.15)
            local lbl = TabButton:FindFirstChildOfClass("TextLabel")
            if lbl then tween(lbl, { TextColor3 = Theme.Text }, 0.15) end
            if IconImg then tween(IconImg, { ImageColor3 = Theme.Accent }, 0.15) end
            Window.ActiveTab = Tab
        end

        TabButton.MouseButton1Click:Connect(selectTab)
        Tab.IconImg = IconImg

        Window.Tabs[#Window.Tabs + 1] = Tab

        if #Window.Tabs == 1 then
            selectTab()
        end

        -- ============ ELEMENTS ============

        local function baseHolder(height)
            return create("Frame", {
                Size = UDim2.new(1, 0, 0, height),
                BackgroundColor3 = Theme.Section,
                Parent = Page,
            }, { corner(8), stroke() })
        end

        function Tab:Section(sectionName)
            local Holder = create("Frame", {
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundTransparency = 1,
                Parent = Page,
            })
            create("TextLabel", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                Text = sectionName,
                TextColor3 = Theme.Accent,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Holder,
            })
            return Holder
        end

        function Tab:Button(text, callback)
            callback = callback or function() end
            local Holder = baseHolder(38)

            local Btn = create("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamMedium,
                Text = text,
                TextColor3 = Theme.Text,
                TextSize = 14,
                AutoButtonColor = false,
                Parent = Holder,
            })

            Btn.MouseEnter:Connect(function()
                tween(Holder, { BackgroundColor3 = Theme.Element }, 0.15)
            end)
            Btn.MouseLeave:Connect(function()
                tween(Holder, { BackgroundColor3 = Theme.Section }, 0.15)
            end)
            Btn.MouseButton1Click:Connect(function()
                tween(Holder, { BackgroundColor3 = Theme.Accent }, 0.1)
                task.delay(0.1, function()
                    tween(Holder, { BackgroundColor3 = Theme.Section }, 0.2)
                end)
                callback()
            end)

            return Holder
        end

        function Tab:Toggle(text, default, callback)
            callback = callback or function() end
            local state = default or false
            local Holder = baseHolder(38)

            create("TextLabel", {
                Size = UDim2.new(1, -60, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamMedium,
                Text = text,
                TextColor3 = Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Holder,
            })

            local Switch = create("Frame", {
                Size = UDim2.new(0, 40, 0, 20),
                Position = UDim2.new(1, -52, 0.5, -10),
                BackgroundColor3 = state and Theme.Accent or Theme.Element,
                Parent = Holder,
            }, { corner(10) })

            local Knob = create("Frame", {
                Size = UDim2.new(0, 16, 0, 16),
                Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                BackgroundColor3 = Theme.Text,
                Parent = Switch,
            }, { corner(8) })

            local Click = create("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                Parent = Holder,
            })

            Click.MouseButton1Click:Connect(function()
                state = not state
                tween(Switch, { BackgroundColor3 = state and Theme.Accent or Theme.Element }, 0.15)
                tween(Knob, { Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8) }, 0.15)
                callback(state)
            end)

            return Holder
        end

        function Tab:Slider(text, min, max, default, callback)
            callback = callback or function() end
            min = min or 0
            max = max or 100
            local value = math.clamp(default or min, min, max)

            local Holder = baseHolder(46)

            create("TextLabel", {
                Size = UDim2.new(1, -60, 0, 20),
                Position = UDim2.new(0, 12, 0, 4),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamMedium,
                Text = text,
                TextColor3 = Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Holder,
            })

            local ValueLabel = create("TextLabel", {
                Size = UDim2.new(0, 50, 0, 20),
                Position = UDim2.new(1, -58, 0, 4),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamMedium,
                Text = tostring(value),
                TextColor3 = Theme.SubText,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = Holder,
            })

            local Track = create("Frame", {
                Size = UDim2.new(1, -24, 0, 6),
                Position = UDim2.new(0, 12, 0, 30),
                BackgroundColor3 = Theme.Element,
                Parent = Holder,
            }, { corner(3) })

            local Fill = create("Frame", {
                Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = Theme.Accent,
                Parent = Track,
            }, { corner(3) })

            local dragging = false

            local function updateFromX(xPos)
                local rel = math.clamp((xPos - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                value = math.floor(min + (max - min) * rel)
                Fill.Size = UDim2.new(rel, 0, 1, 0)
                ValueLabel.Text = tostring(value)
                callback(value)
            end

            Track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    updateFromX(input.Position.X)
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                    or input.UserInputType == Enum.UserInputType.Touch) then
                    updateFromX(input.Position.X)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            return Holder
        end

        function Tab:Dropdown(text, options, default, callback)
            callback = callback or function() end
            options = options or {}
            local selected = default or options[1]
            local open = false

            local Holder = baseHolder(38)
            Holder.ClipsDescendants = false
            Holder.ZIndex = 2

            create("TextLabel", {
                Size = UDim2.new(0.5, -12, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamMedium,
                Text = text,
                TextColor3 = Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Holder,
            })

            local Selector = create("TextButton", {
                Size = UDim2.new(0.5, -12, 0, 28),
                Position = UDim2.new(0.5, 0, 0.5, -14),
                BackgroundColor3 = Theme.Element,
                Font = Enum.Font.GothamMedium,
                Text = tostring(selected) .. "  ▾",
                TextColor3 = Theme.SubText,
                TextSize = 13,
                AutoButtonColor = false,
                ZIndex = 3,
                Parent = Holder,
            }, { corner(6) })

            local ListFrame = create("Frame", {
                Size = UDim2.new(1, 0, 0, #options * 28),
                Position = UDim2.new(0, 0, 1, 4),
                BackgroundColor3 = Theme.Element,
                Visible = false,
                ZIndex = 5,
                Parent = Selector,
            }, { corner(6), stroke() })

            local ListLayout = create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
            })
            ListLayout.Parent = ListFrame

            for _, opt in ipairs(options) do
                local OptBtn = create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Gotham,
                    Text = tostring(opt),
                    TextColor3 = Theme.Text,
                    TextSize = 13,
                    ZIndex = 6,
                    Parent = ListFrame,
                })
                OptBtn.MouseButton1Click:Connect(function()
                    selected = opt
                    Selector.Text = tostring(opt) .. "  ▾"
                    ListFrame.Visible = false
                    open = false
                    callback(opt)
                end)
            end

            Selector.MouseButton1Click:Connect(function()
                open = not open
                ListFrame.Visible = open
            end)

            return Holder
        end

        function Tab:Textbox(text, placeholder, callback)
            callback = callback or function() end
            local Holder = baseHolder(38)

            create("TextLabel", {
                Size = UDim2.new(0.4, -12, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamMedium,
                Text = text,
                TextColor3 = Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Holder,
            })

            local Box = create("TextBox", {
                Size = UDim2.new(0.6, -12, 0, 26),
                Position = UDim2.new(0.4, 0, 0.5, -13),
                BackgroundColor3 = Theme.Element,
                Font = Enum.Font.Gotham,
                PlaceholderText = placeholder or "",
                Text = "",
                TextColor3 = Theme.Text,
                PlaceholderColor3 = Theme.SubText,
                TextSize = 13,
                ClearTextOnFocus = false,
                Parent = Holder,
            }, { corner(6) })

            create("UIPadding", { PaddingLeft = UDim.new(0, 8) }).Parent = Box

            Box.FocusLost:Connect(function(enterPressed)
                callback(Box.Text, enterPressed)
            end)

            return Holder
        end

        function Tab:Label(text)
            local Holder = create("Frame", {
                Size = UDim2.new(1, 0, 0, 24),
                BackgroundTransparency = 1,
                Parent = Page,
            })
            create("TextLabel", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = Theme.SubText,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Holder,
            })
            return Holder
        end

        return Tab
    end

    return Window
end

return Library
