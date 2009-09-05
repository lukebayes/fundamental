
class AddRoles < ActiveRecord::Migration

  def self.up
    create_table('roles') do |t|
      t.string 'label'
      t.string 'name'
    end

    add_index('roles', 'name', :unique => true)

    create_table('roles_users', :id => false) do |t|
      t.integer 'role_id'
      t.integer 'user_id'
    end

    # TODO: Figure out why tests trigger SQL exceptions
    # from this index:
    #add_index('roles_users', ['role_id', 'user_id'], :unique => true)
  end

  def self.down
    drop_table 'roles'
    drop_table 'roles_users'

    remove_index 'roles'
    remove_index 'roles_users'
  end
end
