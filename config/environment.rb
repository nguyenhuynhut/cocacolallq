# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Liquorlicensehq::Application.initialize!
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.content_type = "text/html"
ActionMailer::Base.smtp_settings = {
        :address => "smtp.gmail.com",
        :port => 587,
        :domain => "gmail.com",
        :authentication => 'plain',
        :user_name => "benbo.nguyen@gmail.com",
        :password => "hakimngoc",
        :enable_starttls_auto => true
}
