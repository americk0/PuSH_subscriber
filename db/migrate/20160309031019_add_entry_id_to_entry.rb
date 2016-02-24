class AddEntryIdToEntry < ActiveRecord::Migration
  def change
    add_column :entries, :entry_id, :integer
    add_index :entries, :entry_id
  end
end
