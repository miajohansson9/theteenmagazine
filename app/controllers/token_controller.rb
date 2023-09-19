class TokenController < ApplicationController
  require 'jwt'
  def generate
    environment_id = ENV['CKBOX_ENVIRONMENT_ID']
    key = ENV['CKBOX_KEY']

    role = 'reader';
    if current_user.admin? || current_user.image_admin?
        role = 'admin';
    end

    if current_user.id.eql? 1
      role = 'superadmin';
    end

    # Define payload for the token
    payload = {
      "aud": environment_id, # Environment ID
      "sub": current_user.slug, # User ID
      "iat": Time.now.to_i, # Issued at time (in seconds)
      "auth": {
        "ckbox": {
            "role": role,
        }
      },
    }

    # Generate the JWT token
    token = JWT.encode(payload, key, 'HS256')

    render json: token
  end
end
