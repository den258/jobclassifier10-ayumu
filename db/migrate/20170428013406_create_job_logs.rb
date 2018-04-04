class CreateJobLogs < ActiveRecord::Migration
  def change
    create_table :job_logs do |t|

      t.timestamps null: false
    end
  end
end
