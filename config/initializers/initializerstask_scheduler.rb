
require 'rubygems'
require 'rufus/scheduler'

## to start scheduler
scheduler = Rufus::Scheduler.start_new

## It will print message every i minute
scheduler.every("5m") do
  puts 'Check bid'
  puts User.check_bid
end
scheduler.every("5m") do
  puts "Check Criteria"
  puts User.check_criteria
end
scheduler.every("10m") do
  puts "Send Mail Criteria"
  puts User.sendmail_criteria_activity
end
scheduler.every("10m") do
  puts "Send Mail Bit"
  puts User.sendmail_bid_activity
end
scheduler.every("2m") do
  
  
  puts "Get Craigslist  "
  puts User.get_craigslist
  
  
end
scheduler.every("2h") do
  puts "Get state and city"
  #User.import_data
  puts 'End get sate and city'
end
