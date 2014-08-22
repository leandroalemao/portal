class UserMailer < ActionMailer::Base
  default from: "leandro.costantini@claro.com.br", bcc: "leandro.costantini@claro.com.br"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.signup_confirmation.subject
  #
  def signup_confirmation(user)

    #mail to: "leandro.costantini@claro.com.br", subject: "Sign Up Confirmation"  

  end
end
