class DropDataFiles < ActiveRecord::Migration
  def change
    drop_table :data_files
  end
end
