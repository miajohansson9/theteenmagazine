class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  def new
    set_meta_tags title: 'Login',
                  image:
                    "https://www.theteenmagazine.com#{ActionController::Base.helpers.image_path('ttm.png')}",
                  description:
                    'The Teen Magazine is an online magazine covering all things wellness, student life, academics, lifestyle, relationships, beauty and more.',
                  fb: {
                    app_id: '1190455601051741'
                  },
                  og: {
                    image: {
                      url:
                        "https://www.theteenmagazine.com#{ActionController::Base.helpers.image_path('ttm.png')}",
                      alt: 'The Teen Magazine'
                    },
                    site_name: 'The Teen Magazine',
                    description:
                      'The Teen Magazine is an online magazine covering all things wellness, student life, academics, lifestyle, relationships, beauty and more.'
                  },
                  article: {
                    publisher: 'https://www.facebook.com/theteenmagazinee'
                  },
                  twitter: {
                    card: 'summary_large_image',
                    site: '@ttm_magazine',
                    title: 'The Teen Magazine',
                    description:
                      'The Teen Magazine is an online magazine covering all things wellness, student life, academics, lifestyle, relationships, beauty and more.',
                    image:
                      "https://www.theteenmagazine.com#{ActionController::Base.helpers.image_path('ttm.png')}",
                    domain: 'https://www.theteenmagazine.com/'
                  }
    super
  end

  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message(:notice, :signed_in)
    sign_in(resource_name, resource)
    if !session[:return_to].blank?
      redirect_to session[:return_to]
      session[:return_to] = nil
    else
      respond_with resource, location: after_sign_in_path_for(resource)
    end
  end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
