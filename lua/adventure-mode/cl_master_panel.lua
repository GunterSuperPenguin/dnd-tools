local Tabs = {}
local ActiveTab = nil
local MasterFrame = nil

local function SwitchToTab(tabID)
    if ActiveTab and Tabs[ActiveTab] then
        Tabs[ActiveTab]:SetVisible(false)
    end

    if Tabs[tabID] then
        Tabs[tabID]:SetVisible(true)
        ActiveTab = tabID
    end
end


local function AddTab(id, name, menu, content)
    local Btn = vgui.Create("DButton", menu)
    Btn:SetText(name)
    Btn:SetHeight(40)
    Btn:Dock(TOP)
    Btn:DockMargin(0, 0, 0, 2)

    local TabPanel = vgui.Create("DPanel", content)
    TabPanel:Dock(FILL)
    TabPanel:SetVisible(false)
    TabPanel.Paint = function() end

    Tabs[id] = TabPanel

    Btn.DoClick = function()
        SwitchToTab(id)
    end

    return TabPanel
end


function MasterPanel()
    if IsValid(MasterFrame) then
        gui.EnableScreenClicker(true)
        MasterFrame.ClickerEnabled = true
        return
    end

    Tabs = {}
    ActiveTab = nil

    MasterFrame = vgui.Create("DFrame")
    MasterFrame:SetSize(800, 500)
    MasterFrame:SetTitle("Меню мастера")
    MasterFrame:Center()
    MasterFrame:SetMouseInputEnabled(true)
    MasterFrame:SetKeyboardInputEnabled(false)
    gui.EnableScreenClicker(true)
    MasterFrame.ClickerEnabled = true

    local function IsMenuPanel(pnl)
        if not IsValid(pnl) then return false end
        if pnl == MasterFrame then return true end

        local parent = pnl:GetParent()
        while IsValid(parent) do
            if parent == MasterFrame then return true end
            parent = parent:GetParent()
        end

        local className = tostring(pnl.ClassName or "")
        if string.find(string.lower(className), "menu") then return true end

        return false
    end

    MasterFrame.PrevLeftPressed = false
    local baseThink = MasterFrame.Think

    function MasterFrame:Think()
        if baseThink then baseThink(self) end
        local isLeftPressed = input.IsMouseDown(MOUSE_LEFT)

        if isLeftPressed and not self.PrevLeftPressed then
            if self.ClickerEnabled then
                local hovered = vgui.GetHoveredPanel()

                if not IsMenuPanel(hovered) then
                    gui.EnableScreenClicker(false)
                    self.ClickerEnabled = false
                end
            end
        end

        self.PrevLeftPressed = isLeftPressed
    end

    function MasterFrame:OnClose()
        gui.EnableScreenClicker(false)
        self.ClickerEnabled = false
    end

    local LeftMenu = vgui.Create("DPanel", MasterFrame)
    LeftMenu:SetWidth(150)
    LeftMenu:Dock(LEFT)
    LeftMenu:DockMargin(0, 0, 5, 0)
    LeftMenu.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50))
    end

    local ContentArea = vgui.Create("DPanel", MasterFrame)
    ContentArea:Dock(FILL)
    ContentArea.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(80, 80, 80))
    end

    -- Очередь
    local TabOchered = AddTab("ochered", "Очередь", LeftMenu, ContentArea)
    local Label1 = vgui.Create("DLabel", TabOchered)
    Label1:SetText("Сущности")
    Label1:SetPos(20, 20)
    Label1:SizeToContents()

    local EntityTable = vgui.Create("DListView", TabOchered)
    EntityTable:SetSize(500, 100)
    EntityTable:SetPos(20, 40)
    EntityTable:AddColumn("Наименование")
    EntityTable:AddColumn("Тип")
    EntityTable:AddColumn("ID")

    function EntityTable:OnRowRightClick(lineID, line)
        local Properties = DermaMenu()
        Properties:AddOption("Телепортироваться к сущности", function()
            if line.TargetEntIndex then
                net.Start("MasterMenu_Teleport")
                net.WriteInt(line.TargetEntIndex, 32)
                net.SendToServer()
            end
        end):SetIcon("icon16/arrow_right.png")
        Properties:Open()
    end

    EntityTable:Clear()
    local function ReloadEntityTable()
        EntityTable:Clear()

        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) then
                local steamID = ply:SteamID()
                local name = ply:Nick()
                local entType = "Player"

                local line = EntityTable:AddLine(name, entType, steamID)
                line.TargetEntIndex = ply:EntIndex()
            end
        end

        local statusEffects = ents.FindByClass("dnd_status_effects")
        for _, ent in ipairs(statusEffects) do
            if IsValid(ent) then
                local name = ent:GetDSE_EntityName()

                if not name or name == "" then
                    name = "Безымянный статус–эффект"
                end

                local entType = "NPC"
                local entID = ent:EntIndex()

                local line = EntityTable:AddLine(name, entType, tostring(entID))
                line.TargetEntIndex = entID
            end
        end
    end
    ReloadEntityTable()
    hook.Add("OnEntityCreated", "AutoReloadEntityTable", function(ent)
        if IsValid(ent) and (ent:IsPlayer() or ent:GetClass() == "dnd_status_effects") then
            timer.Simple(0.2, function()
                ReloadEntityTable()
            end)
        end
    end)
    hook.Add("EntityRemoved", "AutoReloadEntityTableRemove", function(ent)
        if IsValid(ent) and (ent:IsPlayer() or ent:GetClass() == "dnd_status_effects") then
            timer.Simple(0.1, function()
                ReloadEntityTable()
            end)
        end
    end)

    local ReloadButton = vgui.Create("DButton", TabOchered)
    ReloadButton:SetText("Обновить")
    ReloadButton:SetSize(150, 50)
    ReloadButton:SetPos(525, 40)
    ReloadButton:SizeToContents()
    ReloadButton.DoClick = function()
        ReloadEntityTable()
    end

    local LabelQueue = vgui.Create("DLabel", TabOchered)
    LabelQueue:SetText("Очередь")
    LabelQueue:SetPos(20, 150)
    LabelQueue:SizeToContents()

    local QueueListScroll = vgui.Create("DScrollPanel", TabOchered)
    QueueListScroll:SetSize(500, 150)
    QueueListScroll:SetPos(20, 170)

    local QueueList = vgui.Create("DListLayout", QueueListScroll)
    QueueList:Dock(FILL)
    QueueList:MakeDroppable("QueueSortableName", true)

    function QueueList:DropAction(options)
        return "move"
    end

    local function AddQueueRow(name, typeText, id)
        local row = QueueList:Add("DPanel")
        row:SetHeight(30)
        row:DockMargin(0, 0, 0, 2)
        row:Droppable("QueueSortableName")

        local col1 = vgui.Create("DLabel", row)
        col1:SetText(name)
        col1:SetPos(10, 5)
        col1:SetSize(200, 20)
        col1:SetTextColor(Color(0, 0, 0))

        local col2 = vgui.Create("DLabel", row)
        col2:SetText(typeText)
        col2:SetPos(220, 5)
        col2:SetSize(150, 20)
        col2:SetTextColor(Color(0, 0, 0))

        local col3 = vgui.Create("DLabel", row)
        col3:SetText(id)
        col3:SetPos(380, 5)
        col3:SetSize(100, 20)
        col3:SetTextColor(Color(0, 0, 0))

        row.Data = { name = name, type = typeText, id = id }

        function row:DoRightClick()
            local Menu = vgui.Create("DMenu")


            local deleteOption = Menu:AddOption("Удалить", function()
                if IsValid(row) then
                    row:Remove()
                    QueueList:InvalidateLayout()
                end
            end)
            deleteOption:SetIcon("icon16/delete.png")
            Menu:Open()
        end
    end


    -- Тест
    AddQueueRow("Предмет 1", "Оружие", "101")
    AddQueueRow("Предмет 2", "Патроны", "102")
    AddQueueRow("Предмет 3", "Аптечка", "103")
    AddQueueRow("Предмет 4", "Аптечка", "103")
    AddQueueRow("Предмет 5", "Аптечка", "105")
    AddQueueRow("Предмет 6", "Аптечка", "106")
    AddQueueRow("Предмет 7", "Аптечка", "107")





    -- Начальная надпись
    local StartSign = AddTab("Signs", "Начальная надпись", LeftMenu, ContentArea)
    local CreateSing = vgui.Create("DButton", StartSign)
    CreateSing:SetText("Создать надпись")
    CreateSing:SetSize(100, 30)
    CreateSing:SetPos(20, 20)
    CreateSing:SizeToContents()
    CreateSing.DoClick = function()
        net.Start("DND_RequestStartSign")
        net.SendToServer()
    end

    -- Команды
    local Commands = AddTab("Cmnds", "Команды", LeftMenu, ContentArea)
    local List = vgui.Create("DListLayout", Commands)
    List:SetPos(20, 20)
    List:SetSize(300, 400)

    local PlyCollision = vgui.Create("DCheckBoxLabel")
    PlyCollision:SetText("Столкновение между игроками")
    PlyCollision:SetSize(200, 30)
    List:Add(PlyCollision)

    local AnotherCheckbox = vgui.Create("DCheckBoxLabel")
    AnotherCheckbox:SetText("Другая настройка")
    AnotherCheckbox:SetSize(200, 30)
    List:Add(AnotherCheckbox)
    PlyCollision:SizeToContents()

    SwitchToTab("ochered")
end

hook.Add("Think", "MasterMenu_RestoreCursor", function()
    if IsValid(MasterFrame) and not MasterFrame.ClickerEnabled then
        if input.IsKeyDown(KEY_C) then
            gui.EnableScreenClicker(true)
            MasterFrame.ClickerEnabled = true
        end
    end
end)


local button_name = "AdventureMode:DesktopWindows"

list.Set("DesktopWindows", button_name, {
    title = "Мастер",
    icon = "icon16/eye.png",
    init = function(icon, window)
        MasterPanel()
    end
})


hook.Add("ContextMenuOpened", button_name, function()
    ---@type Panel
    local context_menu = _G.g_ContextMenu
    if context_menu == nil or not context_menu:IsValid() then return end

    ---@type DIconLayout
    ---@diagnostic disable-next-line: undefined-field
    local widgets = context_menu.DesktopWidgets
    if widgets == nil or not widgets:IsValid() then return end

    local children = widgets:GetChildren()

    ---@type DButton
    local panel

    for i = 1, #children, 1 do
        local pnl = children[i]
        if pnl ~= nil and pnl:IsValid() and pnl.WidgetClass == button_name then
            panel = pnl
            break
        end
    end

    if panel == nil then return end

    hook.Add("Tick", button_name, function()
        if not panel:IsValid() then
            hook.Remove("Tick", button_name)
            return
        end

        local pl = LocalPlayer()
        if pl == nil or not pl:IsValid() then
            return
        end

        -- Условие

        pl:SetNWBool("m_bIsDNDMaster", true) -- server-side code

        if pl:GetNWBool("m_bIsDNDMaster", false) then
            if panel:IsVisible() then return end
            panel:SetVisible(true)
        elseif panel:IsVisible() then
            panel:SetVisible(false)
        end
    end)
end)
