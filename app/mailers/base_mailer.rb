class BaseMailer < ActionMailer::Base
  default from: Settings.mailer.from

end
