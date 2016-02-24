class RemoveFeedColumns < ActiveRecord::Migration
  def change
    remove_column :feeds, :text
    remove_column :feeds, :author
    remove_column :entries, :text
    add_column :entries, :body, :text
  end
end
