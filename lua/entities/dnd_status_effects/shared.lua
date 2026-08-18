ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.IconOverride = "spawnmenu_icon.jpg"

ENT.Category = "DND"
ENT.PrintName = "Статус эффекты"
ENT.Author = "Gunter"
ENT.Spawnable = true
ENT.Editable = true


function ENT:SetupDataTables()
    -- Внешний вид
    self:NetworkVar( "Vector", 0, "DSE_TopColor", {
        KeyName = "dse_topcolor",
        Edit = {
            type = "VectorColor",
            category = "Внешний вид",
            title = "Цвет",
            order = 0,
        }
    } )
    self:NetworkVar( "String", 0, "DSE_EntityName", {
        KeyName = "dse_entityname",
        Edit = {
            type = "Generic",
            category = "Внешний вид",
            title = "Имя",
            order = 1,
        }
    } )
    self:NetworkVar( "Int", 0, "DSE_MaxHP", {
        KeyName = "dse_maxhp",
        Edit = {
            type = "Int",
            category = "Внешний вид",
            title = "Максимальное ХП",
            min = 1,
            max = 100000,
            order = 2,
        }
    } )
    self:NetworkVar( "Int", 1, "DSE_CurrentHP", {
        KeyName = "dse_curhp",
        Edit = {
            type = "Int",
            category = "Внешний вид",
            title = "Текущее ХП",
            min = -100000,
            max = 100000,
            order = 3,
        }
    } )
    self:NetworkVar( "Bool", 0, "DSE_NameDisplay", {
        KeyName = "dse_namedisplay",
        Edit = {
            type = "Boolean",
            category = "Внешний вид",
            title = "Скрыть всё",
            order = 4,
        }
    } )
    self:NetworkVar( "Bool", 1, "DSE_HPDisplay", {
        KeyName = "dse_hpdisplay",
        Edit = {
            type = "Boolean",
            category = "Внешний вид",
            title = "Скрыть ХП",
            order = 5,
        }
    } )
    self:NetworkVar( "Int", 2, "DSE_y_Position", {
        KeyName = "dse_yposition",
        Edit = {
            type = "Int",
            category = "Внешний вид",
            title = "Y",
            min = -1000,
            max = 1000,
            order = 6,
        }
    } )
    self:NetworkVar( "Int", 3, "DSE_x_Position", {
        KeyName = "dse_xposition",
        Edit = {
            type = "Int",
            category = "Внешний вид",
            title = "X",
            min = -1000,
            max = 1000,
            order = 7,
        }
    } )
    self:NetworkVar( "Int", 4, "DSE_z_Position", {
        KeyName = "dse_zposition",
        Edit = {
            type = "Int",
            category = "Внешний вид",
            title = "Z",
            min = -1000,
            max = 1000,
            order = 8,
        }
    } )
    self:NetworkVar( "Int", 5, "DSE_Size", {
        KeyName = "dse_size",
        Edit = {
            type = "Int",
            category = "Внешний вид",
            title = "Размер",
            min = 0,
            max = 200,
            order = 9,
        }
    } )

    -- Статус-эффекты
    self:NetworkVar( "Int", 6, "DSE_blood", {
        KeyName = "dse_blood",
        Edit = {
            type = "Int",
            category = "Статус-эффекты",
            title = "Кровотичение",
            min = 0,
            max = 9,
            order = 10
        }
    } )
    self:NetworkVar( "Int", 7, "DSE_stunning", {
        KeyName = "dse_stunning",
        Edit = {
            type = "Int",
            category = "Статус-эффекты",
            title = "Оглушение",
            min = 0,
            max = 5,
            order = 11
        }
    } )
    self:NetworkVar( "Int", 8, "DSE_fire", {
        KeyName = "dse_fire",
        Edit = {
            type = "Int",
            category = "Статус-эффекты",
            title = "Горение",
            min = 0,
            max = 4,
            order = 12
        }
    } )
    self:NetworkVar( "Int", 9, "DSE_ice", {
        KeyName = "dse_ice",
        Edit = {
            type = "Int",
            category = "Статус-эффекты",
            title = "Обморожение",
            min = 0,
            max = 6,
            order = 13
        }
    } )
    self:NetworkVar( "Int", 10, "DSE_electricity", {
        KeyName = "dse_electricity",
        Edit = {
            type = "Int",
            category = "Статус-эффекты",
            title = "Шок",
            min = 0,
            max = 5,
            order = 14
        }
    } )
    self:NetworkVar( "Int", 11, "DSE_madness", {
        KeyName = "dse_madness",
        Edit = {
            type = "Int",
            category = "Статус-эффекты",
            title = "Безумие",
            min = 0,
            max = 6,
            order = 15
        }
    } )
    self:NetworkVar( "Int", 12, "DSE_sleep", {
        KeyName = "dse_sleep",
        Edit = {
            type = "Int",
            category = "Статус-эффекты",
            title = "Усталость",
            min = 0,
            max = 6,
            order = 16
        }
    } )
    self:NetworkVar( "Int", 13, "DSE_toxic", {
        KeyName = "dse_toxic",
        Edit = {
            type = "Int",
            category = "Статус-эффекты",
            title = "Яд",
            min = 0,
            max = 5,
            order = 17
        }
    } )
    self:NetworkVar( "Int", 14, "DSE_acid", {
        KeyName = "dse_acid",
        Edit = {
            type = "Int",
            category = "Статус-эффекты",
            title = "Растворение",
            min = 0,
            max = 3,
            order = 18
        }
    } )

    self:NetworkVar( "Int", 15, "DSE_fear", {
        KeyName = "dse_fear",
        Edit = {
            type = "Int",
            category = "Статус-эффекты",
            title = "Страх",
            min = 0,
            max = 3,
            order = 19
        }
    } )

    self:NetworkVar( "Int", 16, "DSE_shocked", {
        KeyName = "dse_shocked",
        Edit = {
            type = "Int",
            category = "Статус-эффекты",
            title = "Ошоломление",
            min = 0,
            max = 3,
            order = 20
        }
    } )

    self:NetworkVar( "Int", 17, "DSE_weight", {
        KeyName = "dse_weight",
        Edit = {
            type = "Int",
            category = "Статус-эффекты",
            title = "Перевес",
            min = 0,
            max = 1,
            order = 25
        }
    } )

    -- Бонусы к ролам
    self:NetworkVar( "Int", 18, "DSE_attack", {
        KeyName = "dse_attack",
        Edit = {
            type = "Int",
            category = "Бонусы к ролам",
            title = "Атака",
            -- readonly = true,
            min = -30,
            max = 30,
            order = 30
        }
    } )
    self:NetworkVar( "Int", 19, "DSE_block", {
        KeyName = "dse_block",
        Edit = {
            type = "Int",
            category = "Бонусы к ролам",
            title = "Блок",
            min = -30,
            max = 30,
            order = 31
        }
    } )
    self:NetworkVar( "Int", 20, "DSE_dodge", {
        KeyName = "dse_dodge",
        Edit = {
            type = "Int",
            category = "Бонусы к ролам",
            title = "Уворот",
            min = -30,
            max = 30,
            order = 32
        }
    } )
    self:NetworkVar( "Int", 21, "DSE_counter", {
        KeyName = "dse_counter",
        Edit = {
            type = "Int",
            category = "Бонусы к ролам",
            title = "Контрдействие",
            min = -30,
            max = 30,
            order = 33
        }
    } )
    self:NetworkVar( "Int", 22, "DSE_fists", {
        KeyName = "dse_fists",
        Edit = {
            type = "Int",
            category = "Бонусы к ролам",
            title = "Удары кулаков",
            min = -30,
            max = 30,
            order = 34
        }
    } )
    self:NetworkVar( "Int", 23, "DSE_crossbow", {
        KeyName = "dse_crossbow",
        Edit = {
            type = "Int",
            category = "Бонусы к ролам",
            title = "Дальнобойное",
            min = -30,
            max = 30,
            order = 35
        }
    } )
    self:NetworkVar( "Int", 24, "DSE_other", {
        KeyName = "dse_other",
        Edit = {
            type = "Int",
            category = "Бонусы к ролам",
            title = "Другие",
            min = -30,
            max = 30,
            order = 36
        }
    } )
end
