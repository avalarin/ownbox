module SecurityHelper
  
  def captcha_valid?
    captcha_data = params.require(:captcha).permit(:code, :value)
    captcha = Captcha::Data.find captcha_data[:code]
    captcha && captcha.check(captcha_data[:value])
  end

end