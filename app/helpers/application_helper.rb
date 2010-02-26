# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  # Sets the page title and outputs title if container is passed in.
  # eg. <%= title('Hello World', :h2) %> will return the following:
  # <h2>Hello World</h2> as well as setting the page title.
  def title(str, container = nil)
    @page_title = str
    content_tag(container, str) if container
  end

  # Outputs the corresponding flash message if any are set
  def flash_messages
    messages = []
    %w(error notice warning).each do |type|
      message = flash[type.to_sym]
      messages << render_flash_message(type, message) unless message.blank?
    end
    messages
  end
  
  def render_flash_message(type, message)
    "<div id='flash-#{type}' class='flash'><div>#{h(message)}</div></div>"
  end

  def openid_link_for(submit_path, provider_url, name, label)
    render :partial => 'shared/openid_provider', :locals => { :submit_path => submit_path, :provider_url => provider_url, :name => name, :label => label }
  end

end
