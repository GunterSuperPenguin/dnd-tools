if CLIENT then
    local mainText = "Ваше приключение началось..."
    local transpert = 0
    local showing = false

    surface.CreateFont( "BigMainFont", {
        font = "DermaDefault",
        size = 120,
        weight = 1000
    } )

    surface.CreateFont( "BigSubFont", {
        font = "DermaDefault",
        size = 36,
        weight = 800
    } )

    net.Receive( "DND_AdventureStart", function()
        itog = net.ReadString()
        transpert = 255
        showing = true
        surface.PlaySound( "ambient/levels/citadel/portal_beam_shoot5.wav" )
    end )

    hook.Add( "HUDPaint", "DND_AdventureHUD", function()
        if not showing then return end

        surface.SetFont( "BigMainFont" )
        local mw, mh = surface.GetTextSize( mainText )
        surface.SetFont( "BigSubFont" )
        local sw, sh = surface.GetTextSize( itog )

        local x = ScrW() / 2
        local y = ScrH() / 2 - (mh + sh) / 2

        draw.SimpleText( mainText, "BigMainFont", x + 2, y + 2, Color( 0, 0, 0, transpert ), TEXT_ALIGN_CENTER )
        draw.SimpleText( mainText, "BigMainFont", x, y, Color( 255, 255, 255, transpert ), TEXT_ALIGN_CENTER )

        draw.SimpleText( itog, "BigSubFont", x + 2, y + mh + 5 + 2, Color( 0, 0, 0, transpert ), TEXT_ALIGN_CENTER )
        draw.SimpleText( itog, "BigSubFont", x, y + mh + 5, Color( 255, 255, 255, transpert ), TEXT_ALIGN_CENTER )

        transpert = transpert - (25 * FrameTime())
        if transpert <= 0 then
            showing = false
            transpert = 0
        end
    end )
end
