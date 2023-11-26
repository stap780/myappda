Recaptcha.configure do |config|
    if Rails.env.development?
        config.site_key = "6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI"
        config.secret_key = "6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe"    
    else
        config.site_key = Rails.application.credentials.recaptcha_site_key_v2
        config.secret_key = Rails.application.credentials.recaptcha_secret_key_v2
    end
end