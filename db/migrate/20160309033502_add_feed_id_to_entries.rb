class AddFeedIdToEntries < ActiveRecord::Migration
  def change
    add_column :entries, :feed_id, :integer
    add_index :entries, :feed_id
  end
end
