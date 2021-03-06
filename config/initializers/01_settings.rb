class Settings < Settingslogic
    source "#{Rails.root}/config/settings.yml"
    namespace Rails.env

    # Настройки по умолчанию
    Settings[:app_name] ||= 'Ownbox'

    # Папка для хранения пользовательских данных
    Settings[:home_directories_path] ||= 'data/users/'
    unless File.directory?(Settings[:home_directories_path])
      raise 'Directory ' + File.expand_path(Settings[:home_directories_path]) + ' not found'
    end
    
    Settings[:previews] ||= Settingslogic.new({})
    Settings.previews[:sizes] ||= [ '24x24' ]
    Settings.previews[:directory] ||= 'data/previews/'
    unless File.directory?(Settings.previews[:directory])
      raise 'Directory ' + File.expand_path(Settings.previews[:directory]) + ' not found'
    end

    # Папка для хранения сгенерированных zip архивов
    Settings[:zip_storage_path] ||= 'tmp/zip'
    
    # Настройки безопасности   
    Settings[:security] ||= Settingslogic.new({})
    Settings.security[:session_lifetime] ||= 1.hours
    Settings.security[:persistent_session_lifetime] ||= 30.days
    Settings.security[:registration_mode] = Settings.security[:registration_mode] ? 
        Settings.security[:registration_mode].to_sym : :free

    unless [:free, :invites, :disabled].include? Settings.security[:registration_mode]
        raise "Unknown registration mode " + Settings.security[:registration_mode].to_s
    end

    # Настройки отправки почты
    Settings[:mailer] ||= Settingslogic.new({})
    Settings.mailer[:from] ||= 'ownbox@avalarin.net'

    Settings[:admin] ||= Settingslogic.new({}) 
    Settings.admin[:page_size] ||= 12
end