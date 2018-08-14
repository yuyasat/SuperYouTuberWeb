class MovieRegistrationDefinition < ApplicationRecord
  belongs_to :video_artist
  belongs_to :category
end
