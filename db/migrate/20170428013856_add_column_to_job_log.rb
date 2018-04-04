class AddColumnToJobLog < ActiveRecord::Migration
  def change
    add_column :job_logs, :date, :string
    add_column :job_logs, :start_time, :string
    add_column :job_logs, :end_time, :string
    add_column :job_logs, :title, :string
    add_column :job_logs, :spend_time, :float
    add_column :job_logs, :day_of_the_week, :string
  end
end
