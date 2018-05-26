module ApplicationHelper
  def admin?
    params[:controller].start_with?('admin')
  end

  def sort_by(current_sort_by)
    { 'asc' => 'desc', 'desc' => 'asc' }[current_sort_by] || 'desc'
  end

  def sort_fa_class(target)
    return 'fa-minus-square' if params[:sort].blank?
    { 'desc' => 'fa-caret-down', 'asc' => 'fa-caret-up' }[params[:sort][target]] || 'fa-minus-square'
  end
end
