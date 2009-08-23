class AddEmailActivatedToUser < ActiveRecord::Migration

  def self.up
    add_column :users, :email_activated, :boolean
  end

  def self.down
    remove_column :users, :email_activated
  end
end
