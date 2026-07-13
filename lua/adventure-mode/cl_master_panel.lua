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

    local TabPanel = vgui.Create("DScrollPanel", content)
    TabPanel:Dock(FILL)
    TabPanel:SetVisible(false)
    TabPanel.Paint = function() end

    Tabs[id] = TabPanel

    Btn.DoClick = function()
        SwitchToTab(id)
    end

    return TabPanel
end

QueueListTable = QueueListTable or {}

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

    local BottomTogglePanel = vgui.Create("DPanel", LeftMenu)
    BottomTogglePanel:Dock(BOTTOM)
    BottomTogglePanel:SetHeight(37)
    BottomTogglePanel.Paint = function() end

    local function CreateConvarToggle(cvarName, iconOn, iconOff)
        local btn = vgui.Create("DButton", BottomTogglePanel)
        btn:Dock(LEFT)
        btn:SetWide(math.floor(150 / 4))
        btn:SetText("")

        local matOn = Material(iconOn)
        local matOff = Material(iconOff)

        btn.Paint = function(self, w, h)
            local cv = GetConVar(cvarName)
            local isOn = cv and cv:GetBool() or false

            if self:IsHovered() then
                draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255, 10))
            end

            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(isOn and matOn or matOff)
            surface.DrawTexturedRect((w - 16) / 2, (h - 16) / 2, 16, 16)
        end

        btn.DoClick = function()
            local cv = GetConVar(cvarName)
            if cv then
                local newState = not cv:GetBool()
                RunConsoleCommand(cvarName, newState and "1" or "0")
            end
        end
    end

    CreateConvarToggle("dndt_masterfullbright", "icon16/lightbulb_off.png", "icon16/lightbulb.png")
    CreateConvarToggle("dndt_masterfogskip", "icon16/weather_sun.png", "icon16/weather_clouds.png")
    CreateConvarToggle("dndt_masterhaloplayers", "icon16/status_offline.png", "icon16/status_online.png")
    CreateConvarToggle("dndt_masteralostatuseffects", "icon16/cup_delete.png", "icon16/cup_add.png")

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

    local LabelQueue = vgui.Create("DLabel", TabOchered)
    LabelQueue:SetText("Очередь")
    LabelQueue:SetPos(20, 150)
    LabelQueue:SizeToContents()


    local QueueListScroll = vgui.Create("DScrollPanel", TabOchered)
    QueueListScroll:SetSize(500, 150)
    QueueListScroll:SetPos(20, 170)

    local QueueList = vgui.Create("DListLayout", QueueListScroll)
    QueueList:Dock(TOP)
    QueueList:MakeDroppable("QueueSortableName", true)

    function QueueList:DropAction(options)
        return "move"
    end

    local function SyncQueueTable()
        if not IsValid(QueueList) then return end
        QueueListTable = {}

        for _, row in ipairs(QueueList:GetChildren()) do
            if IsValid(row) and row.Data then
                table.insert(QueueListTable, {
                    name = row.Data.name,
                    type = row.Data.type,
                    id = row.Data.id
                })
            end
        end
    end

    function QueueList:OnModified()
        SyncQueueTable()
    end

    local function AddQueueRow(name, typeText, id)
        local row = QueueList:Add("DPanel")
        row:SetHeight(30)
        row:DockMargin(0, 0, 0, 2)
        row:Droppable("QueueSortableName")

        function row:Paint(w, h)
            if self:IsHovered() or self:IsChildHovered() then
                draw.RoundedBox(0, 0, 0, w, h, Color(210, 235, 255, 255))
            else
                draw.RoundedBox(0, 0, 0, w, h, Color(245, 245, 245, 255))
            end
        end

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
        col3:SetPos(335, 5)
        col3:SetSize(200, 20)
        col3:SetTextColor(Color(0, 0, 0))

        row.Data = { name = name, type = typeText, id = id }

        local originalMousePressed = row.OnMousePressed
        function row:OnMousePressed(mousecode)
            if mousecode == MOUSE_RIGHT then
                return
            end

            if originalMousePressed then
                return originalMousePressed(self, mousecode)
            end
        end

        local originalMouseReleased = row.OnMouseReleased
        function row:OnMouseReleased(mousecode)
            if mousecode == MOUSE_RIGHT then
                local Menu = vgui.Create("DMenu")

                local deleteOption = Menu:AddOption("Удалить", function()
                    if IsValid(row) then
                        row:Remove()
                        timer.Simple(0, function()
                            if IsValid(QueueList) then
                                QueueList:InvalidateLayout()
                                SyncQueueTable()
                            end
                        end)
                    end
                end)
                deleteOption:SetIcon("icon16/delete.png")

                Menu:Open()
                return
            end

            if originalMouseReleased then
                return originalMouseReleased(self, mousecode)
            end
        end

        timer.Simple(0, function()
            if IsValid(QueueList) then
                QueueList:InvalidateLayout(true)
            end
        end)
    end

    for _, item in ipairs(QueueListTable) do
        AddQueueRow(item.name, item.type, item.id)
    end

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
                net.Start("queue_teleport")
                net.WriteInt(line.TargetEntIndex, 32)
                net.SendToServer()
            end
        end):SetIcon("icon16/arrow_right.png")

        Properties:AddOption("Добавить в очередь", function()
            if IsValid(line) and line.TargetEntIndex then
                local id = line:GetValue(3)
                local name = line:GetValue(1) or "Без названия"
                local typeText = line:GetValue(2) or "Неизвестно"
                for _, item in ipairs(QueueListTable) do
                    if tostring(item.name) == name or tostring(item.id) == id then
                        surface.PlaySound("buttons/button8.wav")
                        return
                    end
                end


                AddQueueRow(name, typeText, id)
                QueueList:InvalidateLayout(true)
                QueueListScroll:InvalidateLayout(true)
                SyncQueueTable()
            end
        end):SetIcon("icon16/add.png")
        Properties:Open()
    end

    EntityTable:Clear()

    EntityTable_Lines = EntityTable_Lines or {}

    local function ReloadEntityTable()
        if not IsValid(EntityTable) then
            return
        end
        EntityTable:Clear()
        EntityTable_Lines = {}

        for _, pl in ipairs(player.GetAll()) do
            if IsValid(pl) then
                local steamID = pl:SteamID()
                local name = pl:Nick()
                local entType = "Player"

                local line = EntityTable:AddLine(name, entType, steamID)
                line.TargetEntIndex = pl:EntIndex()
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

                EntityTable_Lines[entID] = line

                if not ent.DSE_NotifyRegistered then
                    ent:NetworkVarNotify("DSE_EntityName", function(entity, varName, oldVal, newVal)
                        if not IsValid(entity) then return end

                        if IsValid(EntityTable) then
                            local targetID = entity:EntIndex()
                            local activeLine = EntityTable_Lines[targetID]

                            if IsValid(activeLine) then
                                local displayName = newVal
                                if not displayName or displayName == "" then
                                    displayName = "Безымянный статус–эффект"
                                end
                                activeLine:SetValue(1, displayName)
                            end
                        end
                    end)
                    ent.DSE_NotifyRegistered = true
                end
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


    local ClearQueue = vgui.Create("DButton", TabOchered)
    ClearQueue:SetText("Очистить всё")
    ClearQueue:SetSize(150, 50)
    ClearQueue:SetPos(525, 170)
    ClearQueue:SizeToContents()
    ClearQueue.DoClick = function()
        if IsValid(QueueList) then
            QueueList:Clear()
            QueueList:InvalidateLayout(true)
        end

        QueueListTable = {}
    end


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

    -- Настройки тумана
    local FogTab = AddTab("FPSFog", "Настройки тумана", LeftMenu, ContentArea)

    local fogPresets = FogTab:Add("ControlPresets")
    fogPresets:Dock(TOP)
    fogPresets:DockMargin(10, 10, 10, 5)
    fogPresets:SetPreset("fpsfog_presets")

    fogPresets:AddConVar("fpsfog_active")
    fogPresets:AddConVar("fpsfog_skybox")
    fogPresets:AddConVar("fpsfog_distance")
    fogPresets:AddConVar("fpsfog_thickness")
    fogPresets:AddConVar("fpsfog_color_r")
    fogPresets:AddConVar("fpsfog_color_g")
    fogPresets:AddConVar("fpsfog_color_b")

    local fogenablevar = FogTab:Add("DCheckBoxLabel")
    fogenablevar:SetValue(GetConVar("fpsfog_active") and GetConVar("fpsfog_active"):GetFloat() or 0)
    fogenablevar:SetText("Включить туман")
    fogenablevar:Dock(TOP)
    fogenablevar:DockMargin(10, 10, 0, 0)
    fogenablevar:SetConVar("fpsfog_active")

    local fogskyboxvar = FogTab:Add("DCheckBoxLabel")
    fogskyboxvar:SetValue(GetConVar("fpsfog_skybox") and GetConVar("fpsfog_skybox"):GetFloat() or 0)
    fogskyboxvar:SetText("Включит Skybox")
    fogskyboxvar:Dock(TOP)
    fogskyboxvar:DockMargin(10, 10, 0, 0)
    fogskyboxvar:SetConVar("fpsfog_skybox")

    local fogendvar = FogTab:Add("DNumSlider")
    fogendvar:SetDecimals(0)
    fogendvar:SetValue(GetConVar("fpsfog_distance") and GetConVar("fpsfog_distance"):GetFloat() or 5000)
    fogendvar:SetMinMax(0, 20000)
    fogendvar:Dock(TOP)
    fogendvar:DockMargin(10, 10, 10, 0)
    fogendvar:SetText("Дистанция тумана")
    fogendvar:SetConVar("fpsfog_distance")

    local fogstartvar = FogTab:Add("DNumSlider")
    fogstartvar:SetDecimals(0)
    fogstartvar:SetValue(GetConVar("fpsfog_thickness") and GetConVar("fpsfog_thickness"):GetFloat() or 25)
    fogstartvar:SetMinMax(0, 100)
    fogstartvar:Dock(TOP)
    fogstartvar:DockMargin(10, 10, 10, 0)
    fogstartvar:SetText("Плотность тумана")
    fogstartvar:SetConVar("fpsfog_thickness")

    local fogcolorvar = FogTab:Add("DColorMixer")
    fogcolorvar:Dock(TOP)
    fogcolorvar:SetAlphaBar(false)
    fogcolorvar:DockMargin(10, 10, 10, 0)
    fogcolorvar:SetConVarR("fpsfog_color_r")
    fogcolorvar:SetConVarG("fpsfog_color_g")
    fogcolorvar:SetConVarB("fpsfog_color_b")


    -- Команды
    -- Переменные и сетевой код (лучше разместить в начале файла или перед созданием меню)
    local whitelist = whitelist or {}
    local should_updade_list = false

    net.Receive("Update cl whitelist", function()
        whitelist = net.ReadTable(true)
        should_updade_list = true
    end)

    hook.Add("OnSpawnMenuOpen", "Update list custom menu", function()
        if UpdateWhitelist then UpdateWhitelist() end
        timer.Simple(0.1, function()
            should_updade_list = true
        end)
    end)

    -- Твой существующий код создания вкладки
    local Commands = AddTab("Cmnds", "Команды", LeftMenu, ContentArea)
    local List = vgui.Create("DListLayout", Commands)
    List:SetPos(20, 20)
    List:SetSize(300, 400)

    local adventure_mode = vgui.Create("DCheckBoxLabel")
    adventure_mode:SetText("Режим приключений")
    adventure_mode:SetConVar("dndt_adventuremode")
    adventure_mode:SetSize(200, 30)
    List:Add(adventure_mode)

    local plCollision = vgui.Create("DCheckBoxLabel")
    plCollision:SetText("Столкновение между игроками")
    plCollision:SetConVar("dndt_playercollision")
    plCollision:SetSize(200, 30)
    List:Add(plCollision)

    local FlashlightCheckbox = vgui.Create("DCheckBoxLabel")
    FlashlightCheckbox:SetText("Работа фонарика у игроков")
    FlashlightCheckbox:SetConVar("dndt_enableflashlight")
    FlashlightCheckbox:SetSize(200, 30)
    List:Add(FlashlightCheckbox)
    FlashlightCheckbox:SizeToContents()

    -- =========================================================================
    -- ИНТЕГРАЦИЯ SANDBOX RIGHTS
    -- =========================================================================

    -- Заголовок–надпись перед началом настроек
    local srHeader = vgui.Create("DLabel")
    srHeader:SetText("Sandbox Rights")
    srHeader:SetFont("DermaDefaultBold")
    srHeader:SetSize(200, 25)
    List:Add(srHeader)

    -- Основные настройки прав
    local srActive = vgui.Create("DCheckBoxLabel")
    srActive:SetText("Активировать ограничения")
    srActive:SetConVar("sv_rights_active")
    srActive:SetSize(200, 30)
    List:Add(srActive)

    local srSuperadmins = vgui.Create("DCheckBoxLabel")
    srSuperadmins:SetText("superadmin")
    srSuperadmins:SetConVar("sv_rights_superadmins")
    srSuperadmins:SetSize(200, 30)
    List:Add(srSuperadmins)

    local srAdmins = vgui.Create("DCheckBoxLabel")
    srAdmins:SetText("admin")
    srAdmins:SetConVar("sv_rights_admins")
    srAdmins:SetSize(200, 30)
    List:Add(srAdmins)

    local srOperators = vgui.Create("DCheckBoxLabel")
    srOperators:SetText("operator")
    srOperators:SetConVar("sv_rights_operators")
    srOperators:SetSize(200, 30)
    List:Add(srOperators)

    -- Таблица вайтлиста (DListView)
    local list = vgui.Create("DListView")
    list:SetMultiSelect(false)
    list:AddColumn("Никнейм")
    list:AddColumn("SteamID")
    list:SetSize(300, 150)
    list.Think = function(self)
        if should_updade_list then
            should_updade_list = false
            self:Clear()
            for k, v in ipairs(whitelist) do
                local ply = FindBySteamID and FindBySteamID(v) or player.GetBySteamID(v)
                if ply and ply:IsValid() then
                    self:AddLine(ply:Nick(), v)
                else
                    self:AddLine("", v)
                end
            end
        end
    end
    list.OnRowRightClick = function(_, lineID)
        local line = list:GetLine(lineID)
        local steamid = line:GetValue(2)
        net.Start("Delete from whitelist")
        net.WriteString(steamid)
        net.SendToServer()
        list:ClearSelection()
        timer.Simple(0.1, function()
            should_updade_list = true
            notification.AddLegacy(steamid .. ' был удален из вайтлиста', 1, 4)
            surface.PlaySound("buttons/button15.wav")
        end)
    end
    List:Add(list)

    -- Выпадающий список для добавления игроков (DComboBox)
    local but = vgui.Create("DComboBox")
    but:SetValue("Выбрать игрока для вайтлиста")
    but:SetSize(300, 30)
    but:AddChoice('buf')
    but.DoClick = function()
        but.Choices = {}
        but.Data = {}
        but.ChoisesIcons = {}
        but.Spacers = {}
        but.selected = nil
        for k, v in player.Iterator() do
            if not v:IsListenServerHost() then
                but:AddChoice(v:Nick(), v:SteamID())
            end
        end
        if but:IsMenuOpen() then
            return but:CloseMenu()
        end
        but:OpenMenu()
    end
    but.OnSelect = function(_, val, data)
        local steamid = but.Data[val]
        if table.HasValue(whitelist, steamid) or steamid == "BOT" then return end
        net.Start("Add to whitelist")
        net.WriteString(steamid)
        net.SendToServer()
        timer.Simple(0.1, function()
            should_updade_list = true
            notification.AddLegacy(data .. ' был добавлен в вайтлист', 2, 4)
            surface.PlaySound("buttons/button15.wav")
        end)
        but:SetValue("Выбрать игрока для вайтлиста")
    end
    List:Add(but)

    -- Настройки ограничения скорости
    local maxVelocityEnabled = vgui.Create("DCheckBoxLabel")
    maxVelocityEnabled:SetText("Ограничение максимальной скорости")
    maxVelocityEnabled:SetConVar("sv_rights_maxvelocity_enabled")
    maxVelocityEnabled:SetSize(200, 30)
    List:Add(maxVelocityEnabled)

    local maxVelocitySlider = vgui.Create("DNumSlider")
    maxVelocitySlider:SetText("Макс. скорость")
    maxVelocitySlider:SetMin(0)
    maxVelocitySlider:SetMax(3500)
    maxVelocitySlider:SetDecimals(0)
    maxVelocitySlider:SetConVar("sv_rights_maxvelocity")
    maxVelocitySlider:SetSize(300, 30)
    List:Add(maxVelocitySlider)

    -- Чекбоксы запретов (Блокировки)
    local banSpawn = vgui.Create("DCheckBoxLabel")
    banSpawn:SetText("Запретить спавн–меню")
    banSpawn:SetConVar("sv_ban_spawn")
    banSpawn:SetSize(200, 30)
    List:Add(banSpawn)

    local banCMenu = vgui.Create("DCheckBoxLabel")
    banCMenu:SetText("Запретить контекстное меню")
    banCMenu:SetConVar("sv_ban_cmenu")
    banCMenu:SetSize(200, 30)
    List:Add(banCMenu)

    local banWeapons = vgui.Create("DCheckBoxLabel")
    banWeapons:SetText("Запретить спавн оружия")
    banWeapons:SetConVar("sv_ban_spawnweapon")
    banWeapons:SetSize(200, 30)
    List:Add(banWeapons)

    local banPhys = vgui.Create("DCheckBoxLabel")
    banPhys:SetText("Запретить Physgun")
    banPhys:SetConVar("sv_ban_physgun")
    banPhys:SetSize(200, 30)
    List:Add(banPhys)

    local banGrav = vgui.Create("DCheckBoxLabel")
    banGrav:SetText("Запретить Гравипушку")
    banGrav:SetConVar("sv_ban_gravgun")
    banGrav:SetSize(200, 30)
    List:Add(banGrav)

    local banTool = vgui.Create("DCheckBoxLabel")
    banTool:SetText("Запретить Toolgun")
    banTool:SetConVar("sv_ban_toolgun")
    banTool:SetSize(200, 30)
    List:Add(banTool)

    local banPickup = vgui.Create("DCheckBoxLabel")
    banPickup:SetText("Запретить поднятие предметов")
    banPickup:SetConVar("sv_ban_pickup")
    banPickup:SetSize(200, 30)
    List:Add(banPickup)

    local banBreak = vgui.Create("DCheckBoxLabel")
    banBreak:SetText("Запретить ломать предметы")
    banBreak:SetConVar("sv_ban_break")
    banBreak:SetSize(200, 30)
    List:Add(banBreak)

    local banNoclip = vgui.Create("DCheckBoxLabel")
    banNoclip:SetText("Запретить Noclip")
    banNoclip:SetConVar("sv_ban_noclip")
    banNoclip:SetSize(200, 30)
    List:Add(banNoclip)

    -- Первичный запрос вайтлиста при открытии/инициализации
    if UpdateWhitelist then UpdateWhitelist() end
    should_updade_list = true
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

surface.CreateFont("Lock_Animated", { font = "Arial", size = 80, weight = 800, shadow = true })

local currentIdx = 1
local visualIdx = 1

local function GetCyclicItem(targetIdx)
    local count = #QueueListTable
    if count == 0 then return nil end

    local cyclicIdx = (math.floor(targetIdx) - 1) % count + 1
    return QueueListTable[cyclicIdx]
end

local function AdvanceQueue(step)
    step = step or 1
    local count = #QueueListTable
    if count == 0 then return end

    local oldIdx = currentIdx
    currentIdx = (currentIdx + step - 1) % count + 1

    if step > 0 and currentIdx < oldIdx then
        visualIdx = visualIdx - count
    elseif step < 0 and currentIdx > oldIdx then
        visualIdx = visualIdx + count
    end
end

local function QueueHUD()
    if not QueueListTable or #QueueListTable == 0 then return end

    local centerX = ScrW() / 2
    local centerY = ScrH() / 2

    visualIdx = Lerp(FrameTime() * 12, visualIdx, currentIdx)

    local stepHeight = 85

    local lineWidth = 250
    local lineSpacing = 45
    surface.SetDrawColor(255, 255, 255, 255)
    surface.DrawLine(centerX - lineWidth / 2, centerY - lineSpacing, centerX + lineWidth / 2, centerY - lineSpacing)
    surface.DrawLine(centerX - lineWidth / 2, centerY + lineSpacing, centerX + lineWidth / 2, centerY + lineSpacing)

    for offset = -3, 3 do
        local targetIdx = visualIdx + offset
        local item = GetCyclicItem(targetIdx)

        local dynamicY = (offset - (visualIdx % 1)) * stepHeight
        local distanceFromCenter = math.abs(dynamicY)

        if distanceFromCenter > stepHeight * 2.5 then continue end

        local alpha = math.Clamp(255 - (distanceFromCenter * 1.3), 0, 255)

        local scale = math.Remap(distanceFromCenter, 0, stepHeight * 2, 1.0, 0.5)
        scale = math.Clamp(scale, 0.5, 1.0)

        local text = (item and item.name) and item.name or "---"
        local textColor = Color(255, 255, 255, alpha)

        local m = Matrix()
        m:Translate(Vector(centerX, centerY + dynamicY, 0))
        m:Scale(Vector(scale, scale, 1))
        m:Translate(Vector(-centerX, -(centerY + dynamicY), 0))

        cam.PushModelMatrix(m)
            draw.SimpleText(
                text,
                "Lock_Animated",
                centerX,
                centerY + dynamicY,
                textColor,
                TEXT_ALIGN_CENTER,
                TEXT_ALIGN_CENTER
            )
        cam.PopModelMatrix()
    end
end

hook.Add("HUDPaint", "MyCustomText", function()
    QueueHUD()
end)

-- Управление для теста
hook.Add("PlayerButtonDown", "TestQueueControls", function(ply, button)
    if button == KEY_UP then
        AdvanceQueue(1)
    elseif button == KEY_DOWN then
        AdvanceQueue(-1)
    end
end)

local master_panel = "DnDTools:MasterPanel"

list.Set("DesktopWindows", master_panel, {
    title = "Мастер",
    icon = "icon16/eye.png",
    init = function(icon, window)
        MasterPanel()
    end
})


hook.Add("ContextMenuOpened", master_panel, function()
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
        if pnl ~= nil and pnl:IsValid() and pnl.WidgetClass == master_panel then
            panel = pnl
            break
        end
    end

    if panel == nil then return end

    hook.Add("Tick", master_panel, function()
        if not panel:IsValid() then
            hook.Remove("Tick", master_panel)
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
