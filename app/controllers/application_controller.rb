class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_categories, :retrieve_advertisement
  before_action :configure_permitted_parameters, if: :devise_controller?

  unless Rails.env.development?
    # Errors are checkd from bottom
    rescue_from StandardError, with: :render_500
    rescue_from ActionController::RoutingError, with: :render_404
    rescue_from ActiveRecord::RecordNotFound, with: :render_404
  end

  %w(404 500).each do |status_code|
    define_method("render_#{status_code}") do |exception = nil|
      logger.info "Rendering #{status_code} with exception: #{exception.message}" if exception
      render(
        file: Rails.root.join('public', "#{status_code}.html"),
        status: status_code.to_i, layout: false, content_type: 'text/html'
      )
    end
  end

  def after_sign_in_path_for(_resource)
    root_path
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) do |user_params|
      user_params.permit(:email, :password, :nickname)
    end
    devise_parameter_sanitizer.permit(:account_update) do |user_params|
      user_params.permit(:email, :password, :nickname, :password_confirmation, :current_password)
    end
  end

  private

  def set_categories
    @top_categories = Category.root.sort_by_display_order
  end

  def retrieve_advertisement
    @advertisements = Advertisement.active.where(path: request.path)
  end

  def clear_session_errors
    session[:errors] = []
  end
end
