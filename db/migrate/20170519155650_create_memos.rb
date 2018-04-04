class CreateMemos < ActiveRecord::Migration
  def change
    create_table :memos do |t|
      t.string :date
      t.text :text

      t.timestamps null: false
    end
  end
end
