class ApplicationController < ActionController::Base
  http_basic_authenticate_with name: ENV['USER'], password: ENV['PASS'] if Rails.env.production?

  before_action :set_categories
  before_action :configure_permitted_parameters, if: :devise_controller?

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

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

  def clear_session_errors
    session[:errors] = []
  end
end
