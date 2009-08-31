module UsersHelper

  # Deal with arbitrary OpenID params that may come back and ensure
  # a semi-valid user object can be created with any values that are available:
  def get_options_from_open_id_params(params, identity_url)
    email = email_from_open_id_params(params)
    name = name_from_open_id_params(params, email)
    return {:identity_url => identity_url, :email => email, :name => name}
  end

  def open_id_required_fields
    ['http://axschema.org/contact/email', 'email', 'nickname', 'fullname']
  end

  # Convert a string to a potentially valid login:
  def name_to_login(name)
    return nil if name.nil? || name == ''
    name = name.gsub(' ', '')
    name = name.downcase
    return name
  end

  def email_from_open_id_params(params)
    email = params['openid.ext1.value.ext0']
    email ||= params['openid.ext1.value.email']
    email ||= params['openid.sreg.email']
    email
  end

  def name_from_open_id_params(params, email=nil)
    name = params['openid.sreg.fullname'] || params[:nickname] || (email.split('@').first unless email.nil?)
  end
end
