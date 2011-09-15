class ContactMailer < ActionMailer::Base
  default :from => "procmail@fir.riec.tohoku.ac.jp"

  def contact(message)
    @message = message
    mail(:to => "jsveholm@fir.riec.tohoku.ac.jp",
         :subject => message.subject)
  end
end
