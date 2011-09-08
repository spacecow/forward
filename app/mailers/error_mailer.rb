class ErrorMailer < ActionMailer::Base
  default :from => "from@example.com"

  def keyword_error(username, error)
    @error = error
    @username = username
    mail(:to => "jsveholm@fir.riec.tohoku.ac.jp",
         :subject => "Procmail:KeywordException")
  end
end
