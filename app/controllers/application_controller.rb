class ApplicationController < ActionController::Base
  include ApplicationHelper

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  unless Rails.env.development?
    # Errors are checkd from bottom
    rescue_from StandardError, with: :render_500
    rescue_from ActionController::RoutingError, with: :render_404
    rescue_from ActiveRecord::RecordNotFound, with: :render_404
  end

  %w(404 500).each do |status_code|
    define_method("render_#{status_code}") do |exception = nil|
      logger.info "Rendering #{status_code} with exception: #{exception.message}" if exception

      notify_bugsnag(exception) if status_code == '500'

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

  private

  def clear_session_errors
    session[:errors] = []
  end

  def notify_bugsnag(exception)
    Bugsnag.notify(exception, false) do |report|
      report.severity = 'error'
      report.severity_reason = { type: 'unhandledException' }
    end
  end
end
