class Settings < Settingslogic
    source "#{Rails.root}/config/settings.yml"
    namespace Rails.env

    # Настройки по умолчанию
    Settings['app_name'] ||= 'Ownbox'

    # Папка для хранения пользовательских данных
    Settings['home_directories_path'] ||= 'data'
    unless File.directory?(Settings['home_directories_path'])
      raise 'Directory ' + File.expand_path(Settings['home_directories_path']) + ' not found'
    end
    
    # Настройки безопасности   
    Settings['security'] ||= Settingslogic.new({})
    Settings.security['session_lifetime'] ||= 1.hours
    Settings.security['persistent_session_lifetime'] ||= 30.days

    # Настройки отправки почты
    Settings['mailer'] ||= Settingslogic.new({})
    Settings.mailer['from'] ||= 'ownbox@example.com'

end