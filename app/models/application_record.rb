class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  scope :new_order, -> { order("#{self.table_name}.id desc") }

  def customized_error_full_messages
    return '' if errors.blank?
    errors.full_messages.join('<br>')
  end

  def self.latest
    order(:id).last
  end
end
