module SearchHelper
  def result_from(array)
    array.offset_value + 1
  end

  def result_upto(array)
    if array.total_count < array.offset_value + 24
      array.total_count
    else
      array.offset_value + 24
    end
  end
end
