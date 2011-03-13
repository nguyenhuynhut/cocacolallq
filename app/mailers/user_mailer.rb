class UserMailer < ActionMailer::Base
  default :from => "benbo.nguyen@gmail.com"

  def forgot(recipient, subject, user, sent_at = Time.now)
    @user = user
    mail(:to => recipient, :subject => subject)
  end
  def bid(recipient, subject, user, message ,liquor_license, price ,sent_at = Time.now)
    @user = user
    @message = message
    @liquor_license = liquor_license
    @price = price
    mail(:to => recipient, :subject => subject)
  end
  def contact_us(recipient, subject, user, message,sent_at = Time.now)
    @user = user
    @message = message
    mail(:to => recipient, :subject => subject)
  end
  def criteria_activity(subject, user ,sent_at = Time.now)
    @user = user
    mail(:to => user.email, :subject => subject)
  end
  def bid_activity(subject, bid_activity ,sent_at = Time.now)
    @bid_activity = bid_activity
    mail(:to => User.find(bid_activity.user_id).email, :subject => subject)
  end
end
