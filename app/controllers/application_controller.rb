class ApplicationController < ActionController::API
  protect_from_forgery
  before_filter :cors_preflight_check
  after_filter :cors_set_access_control_headers
  # before_action :authorized
  def encode_token(user_id)
    JWT.encode(user_id, ENV["hmac_secret"])
  end

  def auth_header
    request.headers["Authorization"]
  end

  # def decode_token(token)
  #   JWT.decode(token, ENV["hmac_secret"])[0]
  # end

  def decoded_token
    if auth_header
      token = auth_header.split(' ')[1] # headers: { 'Authorization': 'Bearer <token>' }
      begin
        JWT.decode(token, ENV["hmac_secret"], true, algorithm: 'HS256') # JWT.decode => [{ "beef"=>"steak" }, { "alg"=>"HS256" }]
      rescue JWT::DecodeError
        nil
      end
    end
  end

  def current_user
    if decoded_token
      user_id = decoded_token[0]['user_id']
    end
    @user = User.find_by(id: user_id)
  end

  def logged_in?
    !!current_user
  end

  def authorized
    render json: { message: 'Sign Up or Login to access dashboard'} #, status: :unauthorized unless logged_in?
  end

  # For all responses in this controller, return the CORS access control headers.

  def cors_set_access_control_headers
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
      headers['Access-Control-Allow-Headers'] = %w{Origin Accept Content-Type X-Requested-With auth_token X-CSRF-Token}.join(',')
      headers['Access-Control-Max-Age'] = "1728000"
  end

  def cors_preflight_check
    if request.method == "OPTIONS"
      headers['Access-Control-Allow-Origin'] = 'http://localhost'
      headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
      headers['Access-Control-Allow-Headers'] = %w{Origin Accept Content-Type X-Requested-With auth_token X-CSRF-Token}.join(',')
      headers['Access-Control-Max-Age'] = '1728000'
      render :text => '', :content_type => 'text/plain'
    end
  end

end
