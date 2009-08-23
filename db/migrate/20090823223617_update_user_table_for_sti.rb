class UpdateUserTableForSti < ActiveRecord::Migration

  def self.up
    rename_column :users, :activation_code, :email_activation_code
    rename_column :users, :activated_at, :email_activated_at

    add_column    :users, :type, :string
    remove_column :users, :login
  end

  def self.down
    rename_column :users, :email_activation_code, :activation_code
    rename_column :users, :email_activated_at, :activated_at

    remove_column :users, :type
    add_column    :users, :login, :string
  end
end
