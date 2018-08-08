class Memo < ApplicationRecord
  belongs_to :target, polymorphic: true
end
