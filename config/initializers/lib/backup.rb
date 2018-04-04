
require 'aws-sdk-v1'

def db_backup

  timestamp = Time.new.strftime("%Y%m%d_%H%M%S")
  backup_file = "db_backup_#{timestamp}.sql"
  backup_file_with_path = "#{Rails.root.to_s + '/tmp/backup/backup_file/' + backup_file}"

  system "./bin/mysqldump " +
    " -h #{BACKUP_DATABASE_HOST} " +
    " #{BACKUP_DATABASE} " +
    " -u #{BACKUP_DATABASE_USER} " +
    " -p#{BACKUP_DATABASE_PASSWORD} " +
    " > " + backup_file_with_path

  upload_dbbackup_s3(backup_file_with_path)

end

def upload_dbbackup_s3(file)

  AWS.config(
      :access_key_id => AMAZON_KEY_ID,
      :secret_access_key => AMAZON_ACCESS_KEY
  )

  bucket_name = AMAZON_BUCKET_NAME
  file_name = "#{file}"

  s3 = AWS::S3.new

  key = File.basename(file_name)
  s3.buckets[bucket_name].objects['database.backups/' + key].write(Pathname.new(file_name))

end
