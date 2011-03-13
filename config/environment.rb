# Load the rails application
require File.expand_path('../application', __FILE__)
require 'mini_magick'



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
#ENV['RECAPTCHA_PUBLIC_KEY'] = '	6Lc-VMISAAAAAA0l49ccCug3i2R2KOflOQbd-ca4 '
#ENV['RECAPTCHA_PRIVATE_KEY'] = '6Lc-VMISAAAAALJOMLVKKRoXuFAbiyxJvfkC1-jL '
ENV['RECAPTCHA_PUBLIC_KEY'] = '6LenbsISAAAAAIIHxs6lrS-BmvysURpDqijUVzpJ'
ENV['RECAPTCHA_PRIVATE_KEY'] = '6LenbsISAAAAALv1X8BUCuHM_tGzREGAfOr36zTf '