class UserMailer < ActionMailer::Base
  default :from => "benbo.nguyen@gmail.com"

  def forgot(recipient, subject, user, sent_at = Time.now)
    @user = user
    mail(:to => recipient, :subject => subject)
  end
end
