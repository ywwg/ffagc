class Proposal < ActiveRecord::Base
  belongs_to :grant_submission

  mount_uploader :file, GrantProposalUploader

  validates :file, presence: true

  validates :grant_submission, presence: true

  # This is supposed to check size before upload but I don't think it does.
  # It does validate after upload, though, so it's not DDOS-proof but it will
  # prevent randos from using the grants server as an ftp site
  validate :file_validation, if: :file?

  def file_validation
    if file.size > 100.megabytes
      logger.warn "rejecting large upload: #{file.inspect}"
      errors[:file] << "File must be less than 100MB"
    end
  end
end
