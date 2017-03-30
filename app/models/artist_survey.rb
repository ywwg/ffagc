class ArtistSurvey < ActiveRecord::Base
  belongs_to :artist

  # TODO: does this need any validation?
end
