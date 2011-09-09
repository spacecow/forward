class ErrorMailer < ActionMailer::Base
  default :from => "from@example.com"

  def filter_error(username, error)
    @class = error.class
    @error = error.message
    @username = username
    mail(:to => "jsveholm@fir.riec.tohoku.ac.jp",
         :subject => "Procmail:KeywordException")
  end
end
