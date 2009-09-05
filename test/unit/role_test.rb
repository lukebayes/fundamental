require File.dirname(__FILE__) + '/../test_helper'

class RoleTest < ActiveSupport::TestCase

  fixtures :roles

  should_validate_presence_of :name, :label
  should_validate_uniqueness_of :name

  context "with Role.web" do
    should "match fixture" do
      assert !Role.web.nil?
      assert_equal roles(:web), Role.web
    end
  end

  context "with Role.admin" do
    should "match fixture" do
      assert !Role.admin.nil?
      assert_equal roles(:admin), Role.admin
    end
  end

  context "with Role.api" do
    should "match fixture" do
      assert !Role.api.nil?
      assert_equal roles(:api), Role.api
    end
  end

end
