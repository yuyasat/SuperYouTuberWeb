module ApplicationHelper
  def admin?
    params[:controller].start_with?('admin')
  end
end
