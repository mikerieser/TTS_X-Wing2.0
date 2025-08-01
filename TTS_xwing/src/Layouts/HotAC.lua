local Vect = require("TTS_Lib.Vector.Vector")

local hotac = {}
do
    hotac.name         = 'HotAC'
    hotac.tableImage   = 'https://github.com/JohnnyCheese/TTS_X-Wing2.0/blob/master/assets/HotAC/Table/table.jpg?raw=true'
    hotac.elements     = {
        ['Damage Decks']           = { pos = { 1.89 + 38, 1.06, -0.06 }, rot = { 0.00, 45.01, 0.00 }, scale = { 1.00, 0.95, 1.00 } },
        ['Huge Ship Damage Decks'] = { pos = { 2.49 + 38, 1.00, -1.95 }, rot = { 0.00, 45.01, 0.00 }, scale = { 0.44, 0.42, 0.44 } },
        ['Tractor Beam']           = { pos = { -1.36 + 38, 1.06, -12.2 }, rot = { 0.00, 180.00, 0.00 }, scale = { 0.95, 0.95, 0.95 } },
        ['Reinforce']              = { pos = { 1.36 + 38, 1.06, -9.56 }, rot = { 0.00, 180.00, 0.00 }, scale = { 0.95, 0.95, 0.95 } },
        ['Calculate']              = { pos = { -1.28 + 38, 1.06, -9.53 }, rot = { 0.00, 180.00, 0.00 }, scale = { 0.95, 0.95, 0.95 } },
        ['Ion']                    = { pos = { -1.40 + 38, 1.07, 8.12 }, rot = { 0.00, 180.03, 0.00 }, scale = { 1.08, 1.08, 1.08 } },
        ['Stress']                 = { pos = { -1.39 + 38, 1.07, 10.20 }, rot = { 0.00, 180.00, 0.00 }, scale = { 1.08, 1.08, 1.08 } },
        ['Deplete']                = { pos = { 1.45 + 38, 1.07, 5.87 }, rot = { 0.00, 180.00, 0.00 }, scale = { 1.08, 1.08, 1.08 } },
        ['Strain']                 = { pos = { 1.43 + 38, 1.07, 10.16 }, rot = { 0.00, 180.00, 0.00 }, scale = { 1.08, 1.08, 1.08 } },
        ['Evade']                  = { pos = { 1.40 + 38, 1.06, -7.02 }, rot = { 0.00, 180.00, 0.00 }, scale = { 0.95, 0.95, 0.95 } },
        ['X-Wing Attack Die']      = { pos = { 0.00 + 38, 1.08, -1.67 }, rot = { 0.00, 90.00, 90.00 }, scale = { 3.00, 3.00, 3.00 } },
        ['X-Wing Defense Die']     = { pos = { 0.00 + 38, 1.08, 1.53 }, rot = { 90.00, 90.00, 0.00 }, scale = { 3.00, 3.00, 3.00 } },
        ['Attack Dice changer']    = { pos = { 0.03 + 38, 1.01, -1.72 }, rot = { 0.00, 315.55, 0.00 }, scale = { 2.50, 0.10, 2.50 } },
        ['Defence Dice changer']   = { pos = { -0.03 + 38, 1.01, 1.49 }, rot = { 0.00, 137.13, 0.00 }, scale = { 2.50, 0.10, 2.50 } },
        ['Target Locks']           = { pos = { -1.93 + 38, 1.06, -0.06 }, rot = { 0.00, 180.00, 180.00 }, scale = { 0.95, 0.95, 0.95 } },
        ['Focus']                  = { pos = { -1.32 + 38, 1.06, -7.07 }, rot = { 0.00, 180.00, 0.00 }, scale = { 0.95, 0.95, 0.95 } },
        ['Shield']                 = { pos = { 1.46 + 38, 1.06, 3.81 }, rot = { 0.00, 0.00, 0.00 }, scale = { 0.95, 0.95, 0.95 } },
        ['Energy']                 = { pos = { 2.91 + 38, 1.01, 1.60 }, rot = { 0.00, 0.00, 0.00 }, scale = { 0.38, 0.38, 0.38 } },
        ['Force']                  = { pos = { -1.44 + 38, 1.06, 6.01 }, rot = { 0.00, 90.00, 0.00 }, scale = { 0.95, 0.95, 0.95 } },
        ['Charge']                 = { pos = { -1.45 + 38, 1.06, 3.81 }, rot = { 0.00, 90.00, 0.00 }, scale = { 0.95, 0.95, 0.95 } },
        ['Critical Hit']           = { pos = { 1.43 + 38, 1.07, 8.12 }, rot = { 0.00, 180.00, 0.00 }, scale = { 0.84, 1.08, 0.84 } },
        ['Cloak']                  = { pos = { 1.36 + 38, 1.07, -4.37 }, rot = { 0.00, 270.00, 0.00 }, scale = { 1.00, 1.00, 1.00 } },
        ['Fuse']                   = { pos = { -1.31 + 38, 1.05, -4.36 }, rot = { 0.00, 90.00, 0.00 }, scale = { 0.93, 0.93, 0.93 } },
        ['Disarm']                 = { pos = { 1.34 + 38, 1.06, -12.2 }, rot = { 0.00, 180.00, 0.00 }, scale = { 0.95, 0.95, 0.95 } },
        ['Jam']                    = { pos = { -0.14 + 38, 1.06, -14.66 }, rot = { 0.00, 180.00, 0.00 }, scale = { 0.95, 0.95, 0.95 } },
        ['All mines tokens']       = { pos = { 1.36 + 38, 0.96, 12.54 }, rot = { 0.00, 90.00, 0.00 }, scale = { 0.30, 0.92, 0.30 } },
        ['Bomb drop tokens']       = { pos = { 0.02 + 38, 1.05, 14.70 }, rot = { 0.00, 0.00, 0.00 }, scale = { 0.93, 1.19, 0.93 } },
        ['All bomb tokens']        = { pos = { -1.35 + 38, 0.96, 12.53 }, rot = { 0.00, 90.00, 0.00 }, scale = { 0.57, 0.83, 0.57 } },
        ['Remotes']                = { pos = { -2.39 + 38, 1.06, 15.55 }, rot = { 0.00, 270.00, 0.00 }, scale = { 0.95, 1.71, 0.95 } },
        ['Spare parts']            = { pos = { 2.35 + 38, 1.03, 15.59 }, rot = { 0.00, 180.00, 0.00 }, scale = { 0.80, 1.42, 0.80 } },
        ['1 Straight Templates']   = { pos = { -38.00, 0.96, -2.25 }, rot = { 0.00, 180.00, 0.00 }, scale = { 3.63, 3.63, 3.63 } },
        ['2 Straight Templates']   = { pos = { -40.00, 0.96, -3.00 }, rot = { 0.00, 0.00, 0.00 }, scale = { 3.63, 3.63, 3.63 } },
        ['3 Straight Templates']   = { pos = { -38.00, 0.96, 0.80 }, rot = { 0.00, 0.00, 0.00 }, scale = { 3.63, 3.63, 3.63 } },
        ['4 Straight Templates']   = { pos = { -40.00, 0.96, 1.50 }, rot = { 0.00, 0.00, 0.00 }, scale = { 3.63, 3.63, 3.63 } },
        ['5 Straight Templates']   = { pos = { -39.00, 0.96, 0.00 }, rot = { 0.00, 0.00, 0.00 }, scale = { 3.63, 3.63, 3.63 } },
        ['1 Bank Templates']       = { pos = { -39.50, 1.05, -7.50 }, rot = { 0.00, 270.00, 0.00 }, scale = { 3.63, 3.63, 3.63 } },
        ['2 Bank Templates']       = { pos = { -40.12, 1.05, -8.50 }, rot = { 0.00, 270.00, 0.00 }, scale = { 3.63, 3.63, 3.63 } },
        ['3 Bank Templates']       = { pos = { -40.75, 1.05, -9.50 }, rot = { 0.00, 270.00, 0.00 }, scale = { 3.63, 3.63, 3.63 } },
        ['1 Turn Templates']       = { pos = { -39.20, 0.96, 7.50 }, rot = { 0.00, 0.00, 0.00 }, scale = { 3.63, 3.63, 3.63 } },
        ['2 Turn Templates']       = { pos = { -39.70, 1.00, 8.50 }, rot = { 0.00, 0.00, 0.00 }, scale = { 3.63, 3.63, 3.63 } },
        ['3 Turn Templates']       = { pos = { -40.20, 0.96, 9.50 }, rot = { 0.00, 0.00, 0.00 }, scale = { 3.63, 3.63, 3.63 } },
        ['Core Set Asteroids']     = { pos = { -46.10, 0.99, -7.09 }, rot = { 0.00, 0.00, 0.00 }, scale = { 0.70, 0.53, 0.70 } },
        ['TFA Set Asteroids']      = { pos = { -45.97, 0.97, -4.02 }, rot = { 0.00, 0.00, 0.00 }, scale = { 0.38, 1.65, 0.38 } },
        ['Debris Fields']          = { pos = { -46.24, -0.27, -0.32 }, rot = { 0.00, 0.00, 0.00 }, scale = { 0.50, 1.90, 0.50 } },
        ['Gas Clouds']             = { pos = { -46.23, 0.96, 4.25 }, rot = { 0.00, 0.00, 0.00 }, scale = { 0.64, 1.14, 0.64 } },
        ['POM Set Obstacles']      = { pos = { -46.21, 0.97, 8.74 }, rot = { 0.00, 0.00, 0.00 }, scale = { 2.42, 1.14, 2.42 } },
        ['Range 1 Rulers']         = { pos = { -42.00, 1.00, -4.10 }, rot = { 0.00, 269.99, 0.00 }, scale = { 0.63, 0.63, 0.63 } },
        ['Range 1-2 Rulers']       = { pos = { -42.00, 1.00, 2.40 }, rot = { 0.00, 270.00, 180.00 }, scale = { 0.63, 0.63, 0.63 } },
        ['Range 1-3 Rulers']       = { pos = { -41.00, 1.00, 0.00 }, rot = { 0.00, 90.00, 0.00 }, scale = { 0.63, 0.63, 0.63 } },
        ['Range 1-5 Rulers']       = { pos = { -43.00, 1.00, 0.80 }, rot = { 0.00, 0.00, 180.00 }, scale = { 0.63, 0.63, 0.63 } },
        ['Deck Holder 1']          = { pos = { -38.50, 0.90, -14.50 }, rot = { 0.00, 0.00, 0.00 }, scale = { 0.65, 0.65, 0.65 } },
        ['Deck Holder 2']          = { pos = { -38.50, 0.90, 14.50 }, rot = { 0.00, 0.00, 0.00 }, scale = { 0.65, 0.65, 0.65 } },
        ['Mine Rules']             = { pos = { 50.00, 1.00, 34.50 }, rot = { 0.00, 180.00, 0.00 }, scale = { 3.58, 1.00, 3.58 } },
        ['Emplacement Rules 1']    = { pos = { 50.00, 1.00, 23.50 }, rot = { 0.00, 180.00, 0.00 }, scale = { 3.58, 1.00, 3.58 } },
        ['Emplacement Rules 2']    = { pos = { 50.00, 1.00, 12.50 }, rot = { 0.00, 180.00, 0.00 }, scale = { 3.58, 1.00, 3.58 } },
        ['Emplacement Rules 3']    = { pos = { 50.00, 1.00, 1.50 }, rot = { 0.00, 180.00, 0.00 }, scale = { 3.58, 1.00, 3.58 } },
        ['Other Rules']            = { pos = { 50.00, 1.00, -9.50 }, rot = { 0.00, 180.00, 0.00 }, scale = { 3.58, 1.00, 3.58 } },
        ['Obstacle Rules']         = { pos = { 50.00, 1.00, -20.50 }, rot = { 0.00, 180.00, 0.00 }, scale = { 3.58, 1.00, 3.58 } },
        ['Turn Tracker']           = { pos = { -2.00, 0.96, 27.00 }, rot = { 0.00, 180.00, 0.00 }, scale = { 0.655, 1.00, 0.80 } },
        ['Turn Marker']            = { pos = { -41.50, 1.12, 27.00 }, rot = { 0.00, 180.00, 0.00 }, scale = { 0.67, 1.00, 0.67 } },
        ['End Marker']             = { pos = { 37.00, 1.00, 27.00 }, rot = { 0.00, 180.00, 0.00 }, scale = { 0.97, 1.00, 0.97 } },
        ['Zone Extension 1']       = { pos = { -49.00, 0.65, 56.00 }, rot = { 0.00, 0.00, 180.00 }, scale = { 1.89, 0.5, 4.0 }, int = false },
        ['Zone Extension 2']       = { pos = { 20.25, 0.65, 56.00 }, rot = { 0.00, 0.00, 180.00 }, scale = { 1.89, 0.5, 4.0 }, int = false },
        ['Zone Extension 3']       = { pos = { -49.00, 0.65, -42.50 }, rot = { 0.00, 0.00, 180.00 }, scale = { 1.89, 0.5, 1.23 }, int = false },
        ['Zone Extension 4']       = { pos = { 20.25, 0.65, -42.50 }, rot = { 0.00, 0.00, 180.00 }, scale = { 1.89, 0.5, 1.23 }, int = false },
        ['Imp AI Sheet Bag']       = { pos = { 42.00, 0.78, 35.00 }, rot = { 0.00, 0.00, 0.00 }, scale = { 1.0, 1.0, 1.0 } },
        ['Rebel AI Sheet Bag']     = { pos = { 42.00, 0.78, 27.00 }, rot = { 0.00, 0.00, 0.00 }, scale = { 1.0, 1.0, 1.0 } },
        ['Scum AI Sheet Bag']      = { pos = { 42.00, 0.78, 19.00 }, rot = { 0.00, 0.00, 0.00 }, scale = { 1.0, 1.0, 1.0 } },
        ['Board Edge L']           = { pos = { -19.55, 0.8, 0.00 }, rot = { 0.00, 0.00, 0.00 }, scale = { 0.5, 0.5, 16.75 }, int = false },
        ['Board Edge R']           = { pos = { 13.55, 0.8, 0.00 }, rot = { 0.00, 0.00, 0.00 }, scale = { 0.5, 0.5, 16.75 }, int = false },
        ['Board Edge T']           = { pos = { -3.00, 0.8, 16.55 }, rot = { 0.00, 90.00, 0.00 }, scale = { 0.5, 0.5, 16.50 }, int = false },
        ['Board Edge B']           = { pos = { -3.00, 0.8, -16.55 }, rot = { 0.00, 90.00, 0.00 }, scale = { 0.5, 0.5, 16.50 }, int = false },
        ['IN 1']                   = { pos = { 42.50, 1.0, -15.00 }, rot = { 0.00, 180.00, 0.00 }, scale = { 0.95, 0.95, 0.95 } },
        ['IN 2']                   = { pos = { 42.50, 1.0, -13.00 }, rot = { 0.00, 180.00, 0.00 }, scale = { 0.95, 0.95, 0.95 } },
        ['IN 3']                   = { pos = { 42.50, 1.0, -11.00 }, rot = { 0.00, 180.00, 0.00 }, scale = { 0.95, 0.95, 0.95 } },
        ['IN 4']                   = { pos = { 42.50, 1.0, -9.00 }, rot = { 0.00, 180.00, 0.00 }, scale = { 0.95, 0.95, 0.95 } },
        ['IN 5']                   = { pos = { 42.50, 1.0, -7.00 }, rot = { 0.00, 180.00, 0.00 }, scale = { 0.95, 0.95, 0.95 } },
        ['IN 6']                   = { pos = { 42.50, 1.0, -5.00 }, rot = { 0.00, 180.00, 0.00 }, scale = { 0.95, 0.95, 0.95 } },
        ['IN 7']                   = { pos = { 42.50, 1.0, -3.00 }, rot = { 0.00, 180.00, 0.00 }, scale = { 0.95, 0.95, 0.95 } },
        ['Player 1 Seat']          = { pos = { -42.50, 0.97, -39.00 }, rot = { 0.00, 180.00, 0.00 }, scale = { 3.00, 1.00, 5.00 } },
        ['Player 2 Seat']          = { pos = { -25.50, 0.97, -39.00 }, rot = { 0.00, 180.00, 0.00 }, scale = { 3.00, 1.00, 5.00 } },
        ['Player 3 Seat']          = { pos = { -8.50, 0.97, -39.00 }, rot = { 0.00, 180.00, 0.00 }, scale = { 3.00, 1.00, 5.00 } },
        ['Player 4 Seat']          = { pos = { 8.50, 0.97, -39.00 }, rot = { 0.00, 180.00, 0.00 }, scale = { 3.00, 1.00, 5.00 } },
        ['Player 5 Seat']          = { pos = { 25.50, 0.97, -39.00 }, rot = { 0.00, 180.00, 0.00 }, scale = { 3.00, 1.00, 5.00 } },
        ['Player 6 Seat']          = { pos = { 42.50, 0.97, -39.00 }, rot = { 0.00, 180.00, 0.00 }, scale = { 3.00, 1.00, 5.00 } },
    }
    local zonePos      = { 5, 2.5, 32 }
    local zoneScale    = { 100, 4, 12 }
    local assignOffset = { -5, 1, 2 }
    local stuffCenter  = { 0, 0, 18.5 }
    local stuffSize    = { 108, 1, 37 }
    local function opposite(data)
        return Vect.ScaleEach(data, { 1, 1, -1 })
    end
    local function left(data)
        return Vect.ScaleEach(data, { -1, 1, 1 })
    end
    hotac.hands = {
        ['Purple'] = { pos = { 42.50, 5.00, -50.00 }, rot = { 0.00, 0.00, 0.00 }, scale = { 5.00, 5.00, 1.00 } },
        ['Green']  = { pos = { 8.50, 5.00, -50.00 }, rot = { 0.00, 0.00, 0.00 }, scale = { 5.00, 5.00, 1.00 } },
        ['Orange'] = { pos = { -25.50, 5.00, -50.00 }, rot = { 0.00, 0.00, 0.00 }, scale = { 5.00, 5.00, 1.00 } },
        ['Teal']   = { pos = { 80.00, 5.00, -15.00 }, rot = { 0.00, 270.00, 0.00 }, scale = { 5.00, 5.00, 1.00 } },
        ['Red']    = { pos = { -42.50, 5.00, -50.00 }, rot = { 0.00, 0.00, 0.00 }, scale = { 5.00, 5.00, 1.00 } },
        ['Blue']   = { pos = { 25.50, 5.00, -50.00 }, rot = { 0.00, 0.00, 0.00 }, scale = { 5.00, 5.00, 1.00 } },
        ['Yellow'] = { pos = { -8.50, 5.00, -50.00 }, rot = { 0.00, 0.00, 0.00 }, scale = { 5.01, 5.00, 1.00 } },
        ['Brown']  = { pos = { 80.00, 5.00, 15.00 }, rot = { 0.00, 270.00, 0.00 }, scale = { 5.00, 5.00, 1.00 } },
        ['Pink']   = { pos = { 80.00, 5.00, 5.00 }, rot = { 0.00, 270.00, 0.00 }, scale = { 5.00, 5.00, 1.00 } },
        ['White']  = { pos = { 80.00, 5.00, -5.00 }, rot = { 0.00, 270.00, 0.00 }, scale = { 5.00, 5.00, 1.00 } },
    }
    hotac.mats = {
        ['Main'] = { pos = { -3.00, 1, 0.00 }, rot = { 0.00, 180.00, 0.00 }, scale = { 1.63, 1.20, 1.63 }, int = false },
    }
    function HotacChangeMat()
        local mat = Layout.GetMats()[hotac.name].Main
        mat.call('NextImage')
    end

    function HotacChangeMatPrev()
        local mat = Layout.GetMats()[hotac.name].Main
        mat.call('PrevImage')
    end

    function HotacToggleRulers()
        local mat = Layout.GetMats()[hotac.name].Main
        mat.call('ToggleRulers')
    end

    function StandardLayout()
        Layout.Switch(1)
    end

    local bWidth = 2200
    local bHeight = 500
    local bFontSize = 230
    hotac.controls = {
        {
            position = { 50.5, 1, 2.5 },
            rotation = { 0, 90, 0 },
            click_function = 'HotacChangeMat',
            label = 'NEXT PLAYMAT'
        },
        {
            position = { 50.5, 1, -2.5 },
            rotation = { 0, 90, 0 },
            click_function = 'HotacChangeMatPrev',
            label = 'PREV PLAYMAT'
        },
        {
            position = { 49, 1, 0 },
            rotation = { 0, 90, 0 },
            click_function = 'HotacToggleRulers',
            label = 'TOGGLE RULERS'
        },
        {
            position = { 80, 1, -35 },
            rotation = { 0, 180, 0 },
            click_function = 'StandardLayout',
            label = 'STANDARD MODE'
        },
    }


    for _, button in ipairs(hotac.controls) do
        button.width = bWidth
        button.height = bHeight
        button.font_size = bFontSize
        button.function_owner = self
    end
end

return hotac
