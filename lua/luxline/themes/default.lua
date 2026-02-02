local themes = require('luxline.themes')

themes.register('default', function()
    local lux_vesper = themes.get_theme('lux-vesper')
    if lux_vesper then
        return lux_vesper
    end

    local auto = require('luxline.themes.auto')
    return auto.generate()
end)
