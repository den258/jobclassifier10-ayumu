# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

=begin
1.upto(5).each do | index |
	user = User.new
	user.account_no = ("000" + index.to_s)[-3, 3]
	user.name = "佐藤 順 001"
	user.tel = "090-0000-0000"
	user.mail = "email@gmail.com"
	user.save!
end

log = JobLog.new
log.date = "2017-04-28"
log.start_time = "10:00"
log.end_time = "11:15"
log.title = "作業日報の記録"
log.spend_time = 1.25
log.day_of_the_week = "Friday"
log.save!

log = JobLog.new
log.date = "2017-04-28"
log.start_time = "11:15"
log.end_time = "12:00"
log.title = "コーディング"
log.spend_time = 0.25
log.day_of_the_week = "Friday"
log.save!
=end
