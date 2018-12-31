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

  def time_diff(time1, time2)
    return nil if time1.blank? || time2.blank?
    duration = ActiveSupport::Duration.build(time1 - time2)
    return '未更新' if duration < 0
    duration.parts.select.with_index { |(k, v), i| i.in?([0, 1]) }.map { |k, v|
      "#{v}#{k == :months ? k[0].upcase : k[0]}"
    }.join.presence || 0
  end

  def newyear?
    Time.current.between?("2019-01-01".in_time_zone, "2019-01-07".in_time_zone.end_of_day)
  end
end
