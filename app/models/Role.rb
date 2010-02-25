
class Role < ActiveRecord::Base
  
  has_and_belongs_to_many :users

  validates_presence_of :name, :label
  validates_uniqueness_of :name

  def self.web
    Role.find_by_name('web')
  end

  def self.api
    Role.find_by_name('api')
  end

  def self.admin
    Role.find_by_name('admin')
  end

end
