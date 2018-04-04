class AddColumnToMemo < ActiveRecord::Migration
  def change
    add_column :memos, :time, :string
  end
end
