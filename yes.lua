--[[
    ImGuiRoblox — Authentic Dear ImGui style for Roblox
    Dark blue theme · Code font · Collapsing headers · Full widget set

    USAGE:
        local ImGui = loadstring(game:HttpGet("URL"))()
        local Gui   = ImGui.new()

        local win = Gui:Window("ImGui Demo", {
            Position = UDim2.new(0, 60, 0, 60),
            Size     = UDim2.new(0, 380, 0, 520),
            MenuBar  = {
                { label = "File",  items = { "New", "Open", "---", "Exit" } },
                { label = "Edit",  items = { "Undo", "Redo" } },
                { label = "Help",  items = { "About" } },
            },
        })

        win:Text("dear imgui says hello.")
        win:Separator()

        win:CollapsingHeader("Widgets", function(s)
            s:CollapsingHeader("Basic", function(b)
                b:Button("Button", function() print("clicked") end)
                b:Checkbox("checkbox", true, function(v) print(v) end)
                b:RadioGroup({"radio a","radio b","radio c"}, 3, function(i) print(i) end)
                b:ColoredButtonRow({
                    {"Click", Color3.fromRGB(180,60,60)},
                    {"Click", Color3.fromRGB(160,160,40)},
                    {"Click", Color3.fromRGB(40,160,40)},
                    {"Click", Color3.fromRGB(40,160,160)},
                })
                b:Dropdown("combo", {"AAAA","BBBB","CCCC","DDDD"}, 1, function(i,v) print(v) end)
                b:InputText("input text", "Hello, world!", function(v) print(v) end)
                b:InputInt("input int", 123, 1, function(v) print(v) end)
                b:InputFloat("input float", 0.001, 0.001, "%.3f", function(v) print(v) end)
                b:ProgressBar(0.72, "Progress")
            end, true)
        end, true)
]]

local UIS          = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

--------------------------------------------------------------------------------
-- Theme — Dear ImGui "Dark" palette
--------------------------------------------------------------------------------
local T = {
    WindowBg        = Color3.fromRGB(15,  15,  15),
    TitleBg         = Color3.fromRGB(10,  10,  10),
    TitleBgActive   = Color3.fromRGB(41,  74, 122),
    MenuBarBg       = Color3.fromRGB(36,  36,  36),
    PopupBg         = Color3.fromRGB(20,  20,  20),
    Border          = Color3.fromRGB(110, 110, 128),

    FrameBg         = Color3.fromRGB(41,  74, 122),
    FrameBgHover    = Color3.fromRGB(52, 100, 170),
    FrameBgActive   = Color3.fromRGB(66, 150, 250),

    Button          = Color3.fromRGB(41,  74, 122),
    ButtonHover     = Color3.fromRGB(66, 150, 250),
    ButtonActive    = Color3.fromRGB(15, 135, 250),

    Header          = Color3.fromRGB(35,  60, 100),
    HeaderOpen      = Color3.fromRGB(41,  74, 122),
    HeaderHover     = Color3.fromRGB(52, 100, 180),

    CheckMark       = Color3.fromRGB(66, 150, 250),
    SliderGrab      = Color3.fromRGB(61, 133, 224),
    Separator       = Color3.fromRGB(110, 110, 128),
    Text            = Color3.fromRGB(255, 255, 255),
    TextDim         = Color3.fromRGB(128, 128, 128),
    Accent          = Color3.fromRGB(66,  150, 250),
    ScrollGrab      = Color3.fromRGB(79,   79,  79),
    CloseBtn        = Color3.fromRGB(180,  60,  60),
    CloseBtnHover   = Color3.fromRGB(220,  80,  80),

    Rounding        = 4,
    SmR             = 2,
    TitleH          = 22,
    MenuBarH        = 22,
    ItemH           = 22,
    Spacing         = 3,
    Padding         = 8,
    Font            = Enum.Font.Code,
    FontBold        = Enum.Font.GothamBold,
    FontSize        = 13,
}

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------
local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r ~= nil and r or T.Rounding)
    c.Parent = p
end

local function stroke(p, col, px)
    local s = Instance.new("UIStroke")
    s.Color = col or T.Border
    s.Thickness = px or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p
end

local function tw(inst, props, t)
    TweenService:Create(inst, TweenInfo.new(t or 0.08, Enum.EasingStyle.Quad), props):Play()
end

local function draggable(handle, target)
    local drag, ds, sp = false
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true; ds = i.Position; sp = target.Position
        end
    end)
    handle.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - ds
            target.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
        end
    end)
end

--------------------------------------------------------------------------------
-- Widget factory — shared by Window and CollapsingHeader sections
--------------------------------------------------------------------------------
local function makeWidgets(contentParent, orderRef, rootFrame)
    local api = {}

    local function item(h)
        orderRef[1] += 1
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1, 0, 0, h or T.ItemH)
        f.BackgroundTransparency = 1; f.BorderSizePixel = 0
        f.LayoutOrder = orderRef[1]; f.Parent = contentParent
        return f
    end

    -- ── Text ──────────────────────────────────────────────────────────────────
    function api:Text(text, color)
        local f = item(T.ItemH)
        local l = Instance.new("TextLabel")
        l.Text = text; l.TextSize = T.FontSize; l.Font = T.Font
        l.TextColor3 = color or T.Text; l.BackgroundTransparency = 1
        l.Size = UDim2.new(1,0,1,0); l.TextXAlignment = Enum.TextXAlignment.Left
        l.TextWrapped = true; l.Parent = f
        return self
    end
    function api:TextDim(text)    return self:Text(text, T.TextDim) end
    function api:TextGreen(text)  return self:Text(text, Color3.fromRGB(90,200,100)) end
    function api:TextRed(text)    return self:Text(text, Color3.fromRGB(220,80,80)) end
    function api:TextYellow(text) return self:Text(text, Color3.fromRGB(230,200,60)) end

    -- ── Separator / Spacing ───────────────────────────────────────────────────
    function api:Separator()
        local f = item(6)
        local line = Instance.new("Frame")
        line.Size = UDim2.new(1,0,0,1); line.Position = UDim2.new(0,0,0.5,0)
        line.BackgroundColor3 = T.Separator; line.BorderSizePixel = 0; line.Parent = f
        return self
    end
    function api:Spacing(h) item(h or 4); return self end

    -- ── Button ────────────────────────────────────────────────────────────────
    function api:Button(text, callback)
        local f = item()
        local btn = Instance.new("TextButton")
        btn.Text = text; btn.TextSize = T.FontSize; btn.Font = T.Font
        btn.TextColor3 = T.Text; btn.BackgroundColor3 = T.Button
        btn.Size = UDim2.new(1,0,1,0); btn.BorderSizePixel = 0; btn.Parent = f
        corner(btn); stroke(btn, T.Border)
        btn.MouseEnter:Connect(function()       tw(btn, {BackgroundColor3 = T.ButtonHover}) end)
        btn.MouseLeave:Connect(function()       tw(btn, {BackgroundColor3 = T.Button}) end)
        btn.MouseButton1Down:Connect(function() tw(btn, {BackgroundColor3 = T.ButtonActive}, 0.04) end)
        btn.MouseButton1Up:Connect(function()   tw(btn, {BackgroundColor3 = T.ButtonHover}) end)
        btn.MouseButton1Click:Connect(function() if callback then callback() end end)
        return self
    end

    -- Row of coloured buttons, equal width
    function api:ColoredButtonRow(buttons, callback)
        local n = #buttons
        local f = item()
        local gap = 4
        for i, b in ipairs(buttons) do
            local text = type(b) == "table" and (b[1] or b.text) or tostring(b)
            local col  = type(b) == "table" and (b[2] or b.color) or T.Button
            local cb   = type(b) == "table" and (b[3] or b.callback) or nil
            local hov  = Color3.new(math.min(col.R*1.35,1), math.min(col.G*1.35,1), math.min(col.B*1.35,1))
            local w    = (1/n)
            local btn  = Instance.new("TextButton")
            btn.Text = text; btn.TextSize = T.FontSize-1; btn.Font = T.Font
            btn.TextColor3 = T.Text; btn.BackgroundColor3 = col
            btn.Size     = UDim2.new(w, i < n and -gap or 0, 1, 0)
            btn.Position = UDim2.new(w*(i-1), i > 1 and gap or 0, 0, 0)
            btn.BorderSizePixel = 0; btn.Parent = f
            corner(btn, T.SmR)
            btn.MouseEnter:Connect(function() tw(btn, {BackgroundColor3 = hov}) end)
            btn.MouseLeave:Connect(function() tw(btn, {BackgroundColor3 = col}) end)
            btn.MouseButton1Click:Connect(function()
                if cb then cb() end
                if callback then callback(i, text) end
            end)
        end
        return self
    end

    -- ── Checkbox ──────────────────────────────────────────────────────────────
    function api:Checkbox(text, default, callback)
        local f = item()
        local checked = default == true
        local box = Instance.new("TextButton")
        box.Text = ""; box.BackgroundColor3 = checked and T.FrameBgActive or T.FrameBg
        box.Size = UDim2.new(0,16,0,16); box.Position = UDim2.new(0,0,0.5,-8)
        box.BorderSizePixel = 0; box.Parent = f
        corner(box, T.SmR); stroke(box, T.Border)
        local mark = Instance.new("Frame")
        mark.Size = UDim2.new(0,10,0,10); mark.Position = UDim2.new(0.5,-5,0.5,-5)
        mark.BackgroundColor3 = T.CheckMark; mark.BorderSizePixel = 0
        mark.Visible = checked; mark.Parent = box
        corner(mark, 2)
        local lbl = Instance.new("TextButton")
        lbl.Text = text; lbl.TextSize = T.FontSize; lbl.Font = T.Font
        lbl.TextColor3 = T.Text; lbl.BackgroundTransparency = 1; lbl.BorderSizePixel = 0
        lbl.Size = UDim2.new(1,-22,1,0); lbl.Position = UDim2.new(0,22,0,0)
        lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = f
        local function toggle()
            checked = not checked; mark.Visible = checked
            tw(box, {BackgroundColor3 = checked and T.FrameBgActive or T.FrameBg})
            if callback then callback(checked) end
        end
        box.MouseButton1Click:Connect(toggle)
        lbl.MouseButton1Click:Connect(toggle)
        box.MouseEnter:Connect(function() tw(box, {BackgroundColor3 = T.FrameBgHover}) end)
        box.MouseLeave:Connect(function() tw(box, {BackgroundColor3 = checked and T.FrameBgActive or T.FrameBg}) end)
        return self
    end

    -- ── Radio group (horizontal) ──────────────────────────────────────────────
    function api:RadioGroup(items, default, callback)
        local f = item()
        local selected = default or 1
        local dots = {}
        local hList = Instance.new("UIListLayout")
        hList.FillDirection = Enum.FillDirection.Horizontal
        hList.VerticalAlignment = Enum.VerticalAlignment.Center
        hList.SortOrder = Enum.SortOrder.LayoutOrder
        hList.Padding = UDim.new(0, 14)
        hList.Parent = f
        for i, name in ipairs(items) do
            local opt = Instance.new("Frame")
            opt.BackgroundTransparency = 1; opt.Size = UDim2.new(0,0,1,0)
            opt.AutomaticSize = Enum.AutomaticSize.X; opt.LayoutOrder = i; opt.Parent = f
            local hInner = Instance.new("UIListLayout")
            hInner.FillDirection = Enum.FillDirection.Horizontal
            hInner.VerticalAlignment = Enum.VerticalAlignment.Center
            hInner.Padding = UDim.new(0,5); hInner.Parent = opt
            local circ = Instance.new("Frame")
            circ.Size = UDim2.new(0,14,0,14); circ.BackgroundColor3 = T.FrameBg; circ.BorderSizePixel = 0; circ.Parent = opt
            corner(circ, 7); stroke(circ, T.Border)
            local dot = Instance.new("Frame")
            dot.Size = UDim2.new(0,8,0,8); dot.Position = UDim2.new(0.5,-4,0.5,-4)
            dot.BackgroundColor3 = T.CheckMark; dot.BorderSizePixel = 0
            dot.Visible = i == selected; dot.Parent = circ
            corner(dot, 4)
            dots[i] = dot
            local txt = Instance.new("TextButton")
            txt.Text = name; txt.TextSize = T.FontSize; txt.Font = T.Font
            txt.TextColor3 = T.Text; txt.BackgroundTransparency = 1; txt.BorderSizePixel = 0
            txt.AutomaticSize = Enum.AutomaticSize.X; txt.Size = UDim2.new(0,0,1,0)
            txt.TextXAlignment = Enum.TextXAlignment.Left; txt.Parent = opt
            txt.MouseButton1Click:Connect(function()
                for j, d in ipairs(dots) do d.Visible = j == i end
                selected = i; if callback then callback(i, name) end
            end)
        end
        return self
    end

    -- ── Toggle switch ─────────────────────────────────────────────────────────
    function api:Toggle(text, default, callback)
        local f = item()
        local on = default == true
        local track = Instance.new("Frame")
        track.Size = UDim2.new(0,36,0,18); track.Position = UDim2.new(0,0,0.5,-9)
        track.BackgroundColor3 = on and T.Accent or T.FrameBg; track.BorderSizePixel = 0; track.Parent = f
        corner(track, 9); stroke(track, T.Border)
        local thumb = Instance.new("Frame")
        thumb.Size = UDim2.new(0,12,0,12)
        thumb.Position = on and UDim2.new(1,-15,0.5,-6) or UDim2.new(0,3,0.5,-6)
        thumb.BackgroundColor3 = Color3.new(1,1,1); thumb.BorderSizePixel = 0; thumb.Parent = track
        corner(thumb, 6)
        local btn = Instance.new("TextButton")
        btn.Text = ""; btn.BackgroundTransparency = 1; btn.Size = UDim2.new(1,0,1,0); btn.Parent = track
        local lbl2 = Instance.new("TextLabel")
        lbl2.Text = text; lbl2.TextSize = T.FontSize; lbl2.Font = T.Font; lbl2.TextColor3 = T.Text
        lbl2.BackgroundTransparency = 1; lbl2.Position = UDim2.new(0,44,0,0)
        lbl2.Size = UDim2.new(1,-44,1,0); lbl2.TextXAlignment = Enum.TextXAlignment.Left; lbl2.Parent = f
        btn.MouseButton1Click:Connect(function()
            on = not on
            tw(track, {BackgroundColor3 = on and T.Accent or T.FrameBg}, 0.12)
            tw(thumb, {Position = on and UDim2.new(1,-15,0.5,-6) or UDim2.new(0,3,0.5,-6)}, 0.12)
            if callback then callback(on) end
        end)
        return self
    end

    -- ── Slider (internal builder) ─────────────────────────────────────────────
    local function buildSlider(parent, mn, mx, default, isInt, fmt, callback)
        local val = default or mn
        local pct = math.clamp((val - mn) / math.max(mx - mn, 0.001), 0, 1)
        local track = Instance.new("Frame")
        track.Size = UDim2.new(1,0,1,0); track.BackgroundColor3 = T.FrameBg
        track.BorderSizePixel = 0; track.Parent = parent
        corner(track, T.SmR); stroke(track, T.Border)
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(pct,0,1,0); fill.BackgroundColor3 = T.SliderGrab
        fill.BorderSizePixel = 0; fill.Parent = track
        corner(fill, T.SmR)
        local valLbl = Instance.new("TextLabel")
        valLbl.Text = isInt and tostring(math.floor(val)) or string.format(fmt or "%.3f", val)
        valLbl.TextSize = T.FontSize-1; valLbl.Font = T.Font; valLbl.TextColor3 = T.Text
        valLbl.BackgroundTransparency = 1; valLbl.Size = UDim2.new(1,0,1,0); valLbl.ZIndex = 3; valLbl.Parent = track
        local hit = Instance.new("TextButton")
        hit.Text = ""; hit.BackgroundTransparency = 1; hit.Size = UDim2.new(1,0,1,0); hit.ZIndex = 4; hit.Parent = track
        local dragging = false
        local function update(x)
            local p = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            val = isInt and math.floor(mn + (mx-mn)*p + 0.5) or (mn + (mx-mn)*p)
            local dp = (val - mn) / math.max(mx-mn, 0.001)
            fill.Size = UDim2.new(dp,0,1,0)
            valLbl.Text = isInt and tostring(val) or string.format(fmt or "%.3f", val)
            if callback then callback(val) end
        end
        hit.MouseButton1Down:Connect(function(x) dragging = true; update(x) end)
        UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
        UIS.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then update(i.Position.X) end end)
    end

    function api:SliderFloat(label2, mn, mx, default, callback, fmt)
        local f = item()
        local sl = Instance.new("Frame"); sl.Size = UDim2.new(0.55,0,1,0); sl.BackgroundTransparency = 1; sl.Parent = f
        buildSlider(sl, mn, mx, default, false, fmt, callback)
        local l2 = Instance.new("TextLabel")
        l2.Text = label2; l2.TextSize = T.FontSize; l2.Font = T.Font; l2.TextColor3 = T.Text
        l2.BackgroundTransparency = 1; l2.Size = UDim2.new(0.44,0,1,0); l2.Position = UDim2.new(0.57,0,0,0)
        l2.TextXAlignment = Enum.TextXAlignment.Left; l2.Parent = f
        return self
    end

    function api:SliderInt(label2, mn, mx, default, callback)
        local f = item()
        local sl = Instance.new("Frame"); sl.Size = UDim2.new(0.55,0,1,0); sl.BackgroundTransparency = 1; sl.Parent = f
        buildSlider(sl, mn, mx, default, true, nil, callback)
        local l2 = Instance.new("TextLabel")
        l2.Text = label2; l2.TextSize = T.FontSize; l2.Font = T.Font; l2.TextColor3 = T.Text
        l2.BackgroundTransparency = 1; l2.Size = UDim2.new(0.44,0,1,0); l2.Position = UDim2.new(0.57,0,0,0)
        l2.TextXAlignment = Enum.TextXAlignment.Left; l2.Parent = f
        return self
    end

    -- ── InputText ─────────────────────────────────────────────────────────────
    function api:InputText(label2, placeholder, callback)
        local f = item()
        local box = Instance.new("TextBox")
        box.Text = ""; box.PlaceholderText = placeholder or ""; box.PlaceholderColor3 = T.TextDim
        box.TextSize = T.FontSize; box.Font = T.Font; box.TextColor3 = T.Text
        box.BackgroundColor3 = T.FrameBg; box.Size = UDim2.new(0.55,0,1,0)
        box.BorderSizePixel = 0; box.ClearTextOnFocus = false
        box.TextXAlignment = Enum.TextXAlignment.Left; box.Parent = f
        corner(box, T.SmR); stroke(box, T.Border)
        local p = Instance.new("UIPadding"); p.PaddingLeft = UDim.new(0,6); p.PaddingRight = UDim.new(0,6); p.Parent = box
        local l2 = Instance.new("TextLabel")
        l2.Text = label2; l2.TextSize = T.FontSize; l2.Font = T.Font; l2.TextColor3 = T.Text
        l2.BackgroundTransparency = 1; l2.Size = UDim2.new(0.44,0,1,0); l2.Position = UDim2.new(0.57,0,0,0)
        l2.TextXAlignment = Enum.TextXAlignment.Left; l2.Parent = f
        box.Focused:Connect(function()    tw(box, {BackgroundColor3 = T.FrameBgHover}) end)
        box.FocusLost:Connect(function()
            tw(box, {BackgroundColor3 = T.FrameBg})
            if callback then callback(box.Text) end
        end)
        return self
    end

    -- ── InputInt / InputFloat with − + ────────────────────────────────────────
    local function numInput(f, valStr, validate, onMinus, onPlus, onType, label2)
        local BW = 22
        local holder = Instance.new("Frame")
        holder.Size = UDim2.new(0.55,0,1,0); holder.BackgroundTransparency = 1; holder.Parent = f

        local box = Instance.new("TextBox")
        box.Text = valStr; box.TextSize = T.FontSize; box.Font = T.Font
        box.TextColor3 = T.Text; box.BackgroundColor3 = T.FrameBg
        box.Size = UDim2.new(1,-(BW*2+4),1,0)
        box.BorderSizePixel = 0; box.ClearTextOnFocus = false
        box.TextXAlignment = Enum.TextXAlignment.Left; box.Parent = holder
        corner(box, T.SmR); stroke(box, T.Border)
        local bp = Instance.new("UIPadding"); bp.PaddingLeft = UDim.new(0,5); bp.Parent = box

        local function makeBtn(sym, xOff)
            local b = Instance.new("TextButton")
            b.Text = sym; b.TextSize = T.FontSize; b.Font = Enum.Font.GothamBold
            b.TextColor3 = T.Text; b.BackgroundColor3 = T.FrameBg
            b.Size = UDim2.new(0,BW-2,1,0); b.Position = UDim2.new(1,xOff,0,0)
            b.BorderSizePixel = 0; b.Parent = holder
            corner(b, T.SmR); stroke(b, T.Border)
            b.MouseEnter:Connect(function() tw(b, {BackgroundColor3 = T.FrameBgHover}) end)
            b.MouseLeave:Connect(function() tw(b, {BackgroundColor3 = T.FrameBg}) end)
            return b
        end
        local minBtn = makeBtn("-", -(BW*2+2))
        local plsBtn = makeBtn("+", -(BW))

        box.FocusLost:Connect(function()
            local s = validate(box.Text); if s then box.Text = s; onType(s) else box.Text = valStr end
        end)
        minBtn.MouseButton1Click:Connect(function() local s = onMinus(); box.Text = s end)
        plsBtn.MouseButton1Click:Connect(function() local s = onPlus();  box.Text = s end)

        local l2 = Instance.new("TextLabel")
        l2.Text = label2; l2.TextSize = T.FontSize; l2.Font = T.Font; l2.TextColor3 = T.Text
        l2.BackgroundTransparency = 1; l2.Size = UDim2.new(0.44,0,1,0); l2.Position = UDim2.new(0.57,0,0,0)
        l2.TextXAlignment = Enum.TextXAlignment.Left; l2.Parent = f
    end

    function api:InputInt(label2, default, step, callback)
        local f = item()
        local val = math.floor(default or 0)
        step = step or 1
        numInput(f, tostring(val),
            function(s) local n = tonumber(s); if n then val = math.floor(n); return tostring(val) end end,
            function() val = val - step; if callback then callback(val) end; return tostring(val) end,
            function() val = val + step; if callback then callback(val) end; return tostring(val) end,
            function()   if callback then callback(val) end end,
            label2
        )
        return self
    end

    function api:InputFloat(label2, default, step, fmt2, callback)
        if type(fmt2) == "function" then callback = fmt2; fmt2 = nil end
        local f = item()
        local val = default or 0.0
        step = step or 0.1
        local fmt = fmt2 or "%.3f"
        numInput(f, string.format(fmt, val),
            function(s) local n = tonumber(s); if n then val = n; return string.format(fmt, val) end end,
            function() val = val - step; if callback then callback(val) end; return string.format(fmt, val) end,
            function() val = val + step; if callback then callback(val) end; return string.format(fmt, val) end,
            function()   if callback then callback(val) end end,
            label2
        )
        return self
    end

    -- ── Dropdown / Combo ──────────────────────────────────────────────────────
    function api:Dropdown(label2, items, defaultIdx, callback)
        local f = item()
        local selIdx = defaultIdx or 1
        local open = false
        local btn = Instance.new("TextButton")
        btn.Text = items[selIdx] or ""; btn.TextSize = T.FontSize; btn.Font = T.Font
        btn.TextColor3 = T.Text; btn.BackgroundColor3 = T.FrameBg
        btn.Size = UDim2.new(0.55,0,1,0); btn.BorderSizePixel = 0
        btn.TextXAlignment = Enum.TextXAlignment.Left; btn.Parent = f
        corner(btn, T.SmR); stroke(btn, T.Border)
        local bp = Instance.new("UIPadding"); bp.PaddingLeft = UDim.new(0,6); bp.Parent = btn
        local arr = Instance.new("TextLabel")
        arr.Text = "▾"; arr.TextSize = 10; arr.Font = T.Font; arr.TextColor3 = T.TextDim
        arr.BackgroundTransparency = 1; arr.Size = UDim2.new(0,14,1,0); arr.Position = UDim2.new(1,-16,0,0); arr.Parent = btn
        local l2 = Instance.new("TextLabel")
        l2.Text = label2; l2.TextSize = T.FontSize; l2.Font = T.Font; l2.TextColor3 = T.Text
        l2.BackgroundTransparency = 1; l2.Size = UDim2.new(0.44,0,1,0); l2.Position = UDim2.new(0.57,0,0,0)
        l2.TextXAlignment = Enum.TextXAlignment.Left; l2.Parent = f
        local pop = Instance.new("Frame")
        pop.BackgroundColor3 = T.PopupBg; pop.BorderSizePixel = 0
        pop.ZIndex = 20; pop.Visible = false; pop.ClipsDescendants = true; pop.Parent = rootFrame
        corner(pop, T.SmR); stroke(pop, T.Border)
        local popL = Instance.new("UIListLayout"); popL.SortOrder = Enum.SortOrder.LayoutOrder; popL.Parent = pop
        local popP = Instance.new("UIPadding"); popP.PaddingTop = UDim.new(0,3); popP.PaddingBottom = UDim.new(0,3); popP.Parent = pop
        local optBtns = {}
        for i, itm in ipairs(items) do
            local opt = Instance.new("TextButton")
            opt.Text = itm; opt.TextSize = T.FontSize; opt.Font = T.Font
            opt.TextColor3 = i == selIdx and T.Accent or T.Text
            opt.BackgroundTransparency = 1; opt.BorderSizePixel = 0
            opt.Size = UDim2.new(1,0,0,T.ItemH); opt.LayoutOrder = i; opt.ZIndex = 21
            opt.TextXAlignment = Enum.TextXAlignment.Left; opt.Parent = pop
            optBtns[i] = opt
            local op = Instance.new("UIPadding"); op.PaddingLeft = UDim.new(0,8); op.PaddingRight = UDim.new(0,8); op.Parent = opt
            opt.MouseEnter:Connect(function() opt.BackgroundTransparency = 0; opt.BackgroundColor3 = T.Header end)
            opt.MouseLeave:Connect(function() opt.BackgroundTransparency = 1 end)
            opt.MouseButton1Click:Connect(function()
                selIdx = i; btn.Text = itm; open = false; pop.Visible = false
                for j, ob in ipairs(optBtns) do ob.TextColor3 = j == i and T.Accent or T.Text end
                if callback then callback(i, itm) end
            end)
        end
        btn.MouseButton1Click:Connect(function()
            open = not open
            if open then
                local ab = btn.AbsolutePosition; local as = btn.AbsoluteSize; local rp = rootFrame.AbsolutePosition
                local dh = math.min(#items * T.ItemH + 6, 160)
                pop.Size = UDim2.new(0, as.X, 0, dh)
                pop.Position = UDim2.new(0, ab.X-rp.X, 0, ab.Y-rp.Y+as.Y+2)
            end
            pop.Visible = open
        end)
        btn.MouseEnter:Connect(function() tw(btn, {BackgroundColor3 = T.FrameBgHover}) end)
        btn.MouseLeave:Connect(function() tw(btn, {BackgroundColor3 = T.FrameBg}) end)
        return self
    end

    -- ── ProgressBar ───────────────────────────────────────────────────────────
    function api:ProgressBar(value, label2)
        local lh = label2 and 14 or 0
        local f = item(T.ItemH + lh)
        value = math.clamp(value or 0, 0, 1)
        if label2 then
            local l3 = Instance.new("TextLabel")
            l3.Text = label2; l3.TextSize = T.FontSize-1; l3.Font = T.Font; l3.TextColor3 = T.Text
            l3.BackgroundTransparency = 1; l3.Size = UDim2.new(1,0,0,14)
            l3.TextXAlignment = Enum.TextXAlignment.Left; l3.Parent = f
        end
        local track = Instance.new("Frame")
        track.Size = UDim2.new(1,0,0,T.ItemH-2); track.Position = UDim2.new(0,0,0,lh)
        track.BackgroundColor3 = T.FrameBg; track.BorderSizePixel = 0; track.Parent = f
        corner(track, T.SmR); stroke(track, T.Border)
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(value,0,1,0); fill.BackgroundColor3 = T.Accent
        fill.BorderSizePixel = 0; fill.Parent = track
        corner(fill, T.SmR)
        local pct = Instance.new("TextLabel")
        pct.Text = math.floor(value*100).."%"; pct.TextSize = T.FontSize-1; pct.Font = T.Font
        pct.TextColor3 = T.Text; pct.BackgroundTransparency = 1
        pct.Size = UDim2.new(1,0,1,0); pct.ZIndex = 2; pct.Parent = track
        return self
    end

    -- ── CollapsingHeader ──────────────────────────────────────────────────────
    function api:CollapsingHeader(text, callback, defaultOpen)
        orderRef[1] += 1
        local open = defaultOpen ~= false

        local container = Instance.new("Frame")
        container.Name = "CH_"..text
        container.AutomaticSize = Enum.AutomaticSize.Y
        container.Size = UDim2.new(1,0,0,0)
        container.BackgroundTransparency = 1; container.BorderSizePixel = 0
        container.LayoutOrder = orderRef[1]; container.Parent = contentParent

        local cList = Instance.new("UIListLayout")
        cList.SortOrder = Enum.SortOrder.LayoutOrder
        cList.Padding = UDim.new(0, T.Spacing)
        cList.Parent = container

        local hBtn = Instance.new("TextButton")
        hBtn.Text = ""; hBtn.Size = UDim2.new(1,0,0,T.ItemH)
        hBtn.BackgroundColor3 = open and T.HeaderOpen or T.Header
        hBtn.BorderSizePixel = 0; hBtn.LayoutOrder = 0; hBtn.Parent = container
        corner(hBtn, T.SmR)

        local arw = Instance.new("TextLabel")
        arw.Text = open and "▼" or "▶"; arw.TextSize = 10; arw.Font = T.Font
        arw.TextColor3 = T.Text; arw.BackgroundTransparency = 1
        arw.Size = UDim2.new(0,18,1,0); arw.Position = UDim2.new(0,4,0,0); arw.Parent = hBtn

        local htxt = Instance.new("TextLabel")
        htxt.Text = text; htxt.TextSize = T.FontSize; htxt.Font = T.FontBold
        htxt.TextColor3 = T.Text; htxt.BackgroundTransparency = 1
        htxt.Size = UDim2.new(1,-24,1,0); htxt.Position = UDim2.new(0,20,0,0)
        htxt.TextXAlignment = Enum.TextXAlignment.Left; htxt.Parent = hBtn

        local inner = Instance.new("Frame")
        inner.AutomaticSize = Enum.AutomaticSize.Y
        inner.Size = UDim2.new(1,0,0,0)
        inner.BackgroundTransparency = 1; inner.BorderSizePixel = 0
        inner.Visible = open; inner.LayoutOrder = 1; inner.Parent = container

        local iList = Instance.new("UIListLayout")
        iList.SortOrder = Enum.SortOrder.LayoutOrder
        iList.Padding = UDim.new(0, T.Spacing)
        iList.Parent = inner

        local iPad = Instance.new("UIPadding")
        iPad.PaddingLeft = UDim.new(0,14); iPad.Parent = inner

        local subOrder = {0}
        local subApi = makeWidgets(inner, subOrder, rootFrame)

        hBtn.MouseButton1Click:Connect(function()
            open = not open
            arw.Text = open and "▼" or "▶"
            inner.Visible = open
            tw(hBtn, {BackgroundColor3 = open and T.HeaderOpen or T.Header})
        end)
        hBtn.MouseEnter:Connect(function() tw(hBtn, {BackgroundColor3 = T.HeaderHover}) end)
        hBtn.MouseLeave:Connect(function() tw(hBtn, {BackgroundColor3 = open and T.HeaderOpen or T.Header}) end)

        if callback then callback(subApi) end
        return self
    end

    -- ── Color swatch ──────────────────────────────────────────────────────────
    function api:ColorDisplay(label2, color3)
        local f = item()
        local l2 = Instance.new("TextLabel")
        l2.Text = label2; l2.TextSize = T.FontSize; l2.Font = T.Font; l2.TextColor3 = T.Text
        l2.BackgroundTransparency = 1; l2.Size = UDim2.new(1,-38,1,0)
        l2.TextXAlignment = Enum.TextXAlignment.Left; l2.Parent = f
        local sw = Instance.new("Frame")
        sw.Size = UDim2.new(0,30,0,16); sw.Position = UDim2.new(0.57,0,0.5,-8)
        sw.BackgroundColor3 = color3 or Color3.new(1,1,1); sw.BorderSizePixel = 0; sw.Parent = f
        corner(sw, T.SmR); stroke(sw, T.Border)
        return self
    end

    return api
end

--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
local ImGuiRoblox = {}
ImGuiRoblox.__index = ImGuiRoblox

function ImGuiRoblox.new(parent)
    local self = setmetatable({}, ImGuiRoblox)
    local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    local gui = Instance.new("ScreenGui")
    gui.Name = "ImGuiRoblox"; gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; gui.IgnoreGuiInset = true
    gui.Parent = parent or playerGui
    self._gui = gui
    return self
end

function ImGuiRoblox:Window(title, opts)
    opts = opts or {}
    local pos      = opts.Position or UDim2.new(0, 80, 0, 80)
    local size     = opts.Size     or UDim2.new(0, 380, 0, 520)
    local closable = opts.Closable ~= false

    local root = Instance.new("Frame")
    root.Name = "ImGuiWin_"..title; root.Position = pos; root.Size = size
    root.BackgroundColor3 = T.WindowBg; root.BorderSizePixel = 0; root.ClipsDescendants = true
    root.Parent = self._gui
    corner(root, T.Rounding); stroke(root, T.Border)

    -- Title bar
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1,0,0,T.TitleH); bar.BackgroundColor3 = T.TitleBgActive
    bar.BorderSizePixel = 0; bar.ZIndex = 5; bar.Parent = root
    corner(bar, T.Rounding)
    local patch = Instance.new("Frame")
    patch.Size = UDim2.new(1,0,0,T.Rounding); patch.Position = UDim2.new(0,0,1,-T.Rounding)
    patch.BackgroundColor3 = T.TitleBgActive; patch.BorderSizePixel = 0; patch.ZIndex = 5; patch.Parent = bar

    local colArrow = Instance.new("TextLabel")
    colArrow.Text = "▼"; colArrow.TextSize = 9; colArrow.Font = T.Font
    colArrow.TextColor3 = T.Text; colArrow.BackgroundTransparency = 1
    colArrow.Size = UDim2.new(0,16,1,0); colArrow.Position = UDim2.new(0,4,0,0)
    colArrow.ZIndex = 6; colArrow.Parent = bar

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Text = title; titleLbl.TextSize = T.FontSize; titleLbl.Font = T.Font
    titleLbl.TextColor3 = T.Text; titleLbl.BackgroundTransparency = 1
    titleLbl.Position = UDim2.new(0,20,0,0)
    titleLbl.Size = UDim2.new(1, -(20 + T.Padding + (closable and 22 or 0)), 1, 0)
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left; titleLbl.ZIndex = 6; titleLbl.Parent = bar

    if closable then
        local cb = Instance.new("TextButton")
        cb.Text = "×"; cb.TextSize = 16; cb.Font = Enum.Font.GothamBold
        cb.TextColor3 = T.Text; cb.BackgroundColor3 = T.CloseBtn
        cb.Size = UDim2.new(0,16,0,16); cb.Position = UDim2.new(1,-20,0.5,-8)
        cb.BorderSizePixel = 0; cb.ZIndex = 7; cb.Parent = bar
        corner(cb, T.SmR)
        cb.MouseEnter:Connect(function() tw(cb, {BackgroundColor3 = T.CloseBtnHover}) end)
        cb.MouseLeave:Connect(function() tw(cb, {BackgroundColor3 = T.CloseBtn}) end)
        cb.MouseButton1Click:Connect(function() root:Destroy() end)
    end

    -- Menu bar
    local menuBarH = 0
    if opts.MenuBar then
        menuBarH = T.MenuBarH
        local menuBar = Instance.new("Frame")
        menuBar.Size = UDim2.new(1,0,0,menuBarH); menuBar.Position = UDim2.new(0,0,0,T.TitleH)
        menuBar.BackgroundColor3 = T.MenuBarBg; menuBar.BorderSizePixel = 0
        menuBar.ZIndex = 4; menuBar.Parent = root
        local mbL = Instance.new("UIListLayout")
        mbL.FillDirection = Enum.FillDirection.Horizontal
        mbL.VerticalAlignment = Enum.VerticalAlignment.Center
        mbL.SortOrder = Enum.SortOrder.LayoutOrder; mbL.Parent = menuBar
        local mbSep = Instance.new("Frame")
        mbSep.Size = UDim2.new(1,0,0,1); mbSep.Position = UDim2.new(0,0,1,-1)
        mbSep.BackgroundColor3 = T.Border; mbSep.BorderSizePixel = 0; mbSep.ZIndex = 4; mbSep.Parent = menuBar

        for i, menuDef in ipairs(opts.MenuBar) do
            local lbl3   = type(menuDef) == "table" and (menuDef.label or menuDef[1]) or tostring(menuDef)
            local mItems = type(menuDef) == "table" and (menuDef.items or menuDef[2]) or {}
            local mBtn   = Instance.new("TextButton")
            mBtn.Text = lbl3; mBtn.TextSize = T.FontSize; mBtn.Font = T.Font; mBtn.TextColor3 = T.Text
            mBtn.BackgroundTransparency = 1; mBtn.BorderSizePixel = 0
            mBtn.AutomaticSize = Enum.AutomaticSize.X; mBtn.Size = UDim2.new(0,0,1,0)
            mBtn.LayoutOrder = i; mBtn.ZIndex = 5; mBtn.Parent = menuBar
            local mbp = Instance.new("UIPadding"); mbp.PaddingLeft = UDim.new(0,8); mbp.PaddingRight = UDim.new(0,8); mbp.Parent = mBtn

            if mItems and #mItems > 0 then
                local pop = Instance.new("Frame")
                pop.BackgroundColor3 = T.PopupBg; pop.BorderSizePixel = 0
                pop.ZIndex = 30; pop.Visible = false; pop.Parent = root
                corner(pop, T.SmR); stroke(pop, T.Border)
                local popL = Instance.new("UIListLayout"); popL.SortOrder = Enum.SortOrder.LayoutOrder; popL.Parent = pop
                local popP = Instance.new("UIPadding"); popP.PaddingTop = UDim.new(0,3); popP.PaddingBottom = UDim.new(0,3); popP.Parent = pop

                for j, mi in ipairs(mItems) do
                    if mi == "---" then
                        local sep = Instance.new("Frame"); sep.Size = UDim2.new(1,0,0,8); sep.BackgroundTransparency = 1; sep.LayoutOrder = j; sep.Parent = pop
                        local sl2 = Instance.new("Frame"); sl2.Size = UDim2.new(1,-16,0,1); sl2.Position = UDim2.new(0,8,0.5,0); sl2.BackgroundColor3 = T.Border; sl2.BorderSizePixel = 0; sl2.Parent = sep
                    else
                        local ml = type(mi) == "table" and (mi.label or mi[1]) or tostring(mi)
                        local mc = type(mi) == "table" and (mi.callback or mi[2]) or nil
                        local opt = Instance.new("TextButton")
                        opt.Text = ml; opt.TextSize = T.FontSize; opt.Font = T.Font; opt.TextColor3 = T.Text
                        opt.BackgroundTransparency = 1; opt.BorderSizePixel = 0
                        opt.Size = UDim2.new(1,0,0,T.ItemH); opt.LayoutOrder = j; opt.ZIndex = 31
                        opt.TextXAlignment = Enum.TextXAlignment.Left; opt.Parent = pop
                        local op = Instance.new("UIPadding"); op.PaddingLeft = UDim.new(0,10); op.PaddingRight = UDim.new(0,10); op.Parent = opt
                        opt.MouseEnter:Connect(function() opt.BackgroundTransparency = 0; opt.BackgroundColor3 = T.Header end)
                        opt.MouseLeave:Connect(function() opt.BackgroundTransparency = 1 end)
                        opt.MouseButton1Click:Connect(function() pop.Visible = false; if mc then mc() end end)
                    end
                end

                local menuOpen = false
                mBtn.MouseButton1Click:Connect(function()
                    menuOpen = not menuOpen
                    if menuOpen then
                        local ab = mBtn.AbsolutePosition; local rp = root.AbsolutePosition
                        local dh = math.min(#mItems * T.ItemH + 6, 200)
                        pop.Size = UDim2.new(0,160,0,dh)
                        pop.Position = UDim2.new(0, ab.X-rp.X, 0, T.TitleH + menuBarH)
                    end
                    pop.Visible = menuOpen
                end)
            end
            mBtn.MouseEnter:Connect(function() mBtn.BackgroundTransparency = 0; mBtn.BackgroundColor3 = T.Header end)
            mBtn.MouseLeave:Connect(function() mBtn.BackgroundTransparency = 1 end)
        end
    end

    -- Double-click to collapse
    local collapsed = false; local lastClick = 0
    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            local now = tick()
            if now - lastClick < 0.3 then
                collapsed = not collapsed
                colArrow.Text = collapsed and "▶" or "▼"
                tw(root, {Size = collapsed
                    and UDim2.new(size.X.Scale, size.X.Offset, 0, T.TitleH + menuBarH)
                    or size}, 0.15)
            end
            lastClick = now
        end
    end)
    draggable(bar, root)

    -- Scroll content
    local contentTop = T.TitleH + menuBarH
    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "Content"; scroll.Position = UDim2.new(0,0,0,contentTop)
    scroll.Size = UDim2.new(1,0,1,-contentTop); scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0; scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = T.ScrollGrab
    scroll.CanvasSize = UDim2.new(0,0,0,0); scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = root
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Padding = UDim.new(0, T.Spacing); layout.Parent = scroll
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0,T.Padding); pad.PaddingRight = UDim.new(0,T.Padding)
    pad.PaddingTop = UDim.new(0,T.Padding); pad.PaddingBottom = UDim.new(0,T.Padding); pad.Parent = scroll

    local orderRef = {0}
    local winApi = makeWidgets(scroll, orderRef, root)
    winApi._root = root
    function winApi:Destroy()     root:Destroy() end
    function winApi:SetVisible(v) root.Visible = v end
    function winApi:GetRoot()     return root end

    return winApi
end

return ImGuiRoblox
