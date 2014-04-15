class Settings < Settingslogic
    source "#{Rails.root}/config/settings.yml"
    namespace Rails.env

    # Default settings
    Settings['app_name'] ||= 'FFinances'

    # Security   
    Settings['security'] ||= Settingslogic.new({})
    Settings.security['session_lifetime'] = 1.hours
    Settings.security['persistent session_lifetime'] = 30.days

end