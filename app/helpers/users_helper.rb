module UsersHelper

  # Deal with arbitrary OpenID params that may come back and ensure
  # a semi-valid user object can be created with any values that are available:
  def get_options_from_open_id_params(params, identity_url)
    email = params['openid.ext1.value.ext0']
    email ||= params['openid.ext1.value.email']
    email ||= params['openid.sreg.email']

    name = params['openid.sreg.fullname'] || (email.split('@').first unless email.nil?)
    login = name_to_login(params[:nickname] || name)

    return {:identity_url => identity_url, :login => login, :email => email, :name => name}
  end

  def open_id_required_fields
    ['http://axschema.org/contact/email', 'email', 'nickname', 'fullname']
  end
end
