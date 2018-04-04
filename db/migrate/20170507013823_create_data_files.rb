class CreateDataFiles < ActiveRecord::Migration
  def change
    create_table :data_files do |t|
      t.binary :upload_file
      t.string :upload_filename

      t.timestamps null: false
    end
  end
end
