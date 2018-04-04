require 'rufus-scheduler'

scheduler = Rufus::Scheduler.new

#Backup at 03:00 everyday
scheduler.cron '00 03 * * *' do
  db_backup
end
