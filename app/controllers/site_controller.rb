class SiteController < ApplicationController

  before_filter :login_required, :only => 'index'

  def index
  end

  def about
  end

  def contact
  end

  def privacy
  end
end
