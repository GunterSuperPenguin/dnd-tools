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
        MasterFrame:MakePopup()
        return
    end

    Tabs = {}
    ActiveTab = nil

    MasterFrame = vgui.Create("DFrame")
    MasterFrame:SetSize(800, 500)
    MasterFrame:SetTitle("Меню мастера")
    MasterFrame:Center()
    MasterFrame:MakePopup()

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
    EntityTable:SetSize(500, 200)
    EntityTable:SetPos(20, 40)
    EntityTable:AddColumn("Наименование")
    EntityTable:AddColumn("Тип")
    EntityTable:AddColumn("ID")
    function EntityTable:OnRowRightClick(lineID, line)
        local Properties = DermaMenu()
        Properties:AddOption("Телепортироваться к сущности", function()
            local name = line:GetValue(1)
            RunConsoleCommand("ulx", "goto", name)
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
                EntityTable:AddLine(name, entType, steamID)
            end
        end

        local statusEffects = ents.FindByClass("dnd_status_effects")

        for _, ent in ipairs(statusEffects) do
            if IsValid(ent) then
                local name = ent:GetDSE_EntityName()

                if not name or name == "" then
                    name = "Безымянный статус-эффект"
                end

                local entType = "NPC"
                local entID = ent:EntIndex()
                EntityTable:AddLine(name, entType, tostring(entID))
            end
        end
    end
    ReloadEntityTable()

    local ReloadButton = vgui.Create("DButton", TabOchered)
    ReloadButton:SetText("Обновить")
    ReloadButton:SetSize(100, 30)
    ReloadButton:SetPos(525, 40)
    ReloadButton:SizeToContents()
    ReloadButton.DoClick = function()
        ReloadEntityTable()
    end

    local DHori = vgui.Create("DHorizontalDivider", TabOchered)
    DHori:SetPos(0, 200)

    -- Начачальная надпись
    local StartSign = AddTab("test", "Начачальная надпись", LeftMenu, ContentArea)
    local CreateSing = vgui.Create("DButton", StartSign)
    CreateSing:SetText("Создать надпись")
    CreateSing:SetSize(100, 30)
    CreateSing:SetPos(20, 20)
    CreateSing:SizeToContents()
    CreateSing.DoClick = function()
        net.Start("DND_RequestStartSign")
        net.SendToServer()
    end


    SwitchToTab("ochered")
end

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
