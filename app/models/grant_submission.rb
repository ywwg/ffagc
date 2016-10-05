class GrantSubmission < ActiveRecord::Base
  mount_uploader :proposal, GrantProposalUploader

  validates :name, :presence => true, length: { minimum: 4 }
  validates :proposal, :presence => true

  validates :grant_id, :presence => true

  #temporary hack : needs to be based on selected grant, not hardcoded here
  validates :requested_funding_dollars, :presence => true, :numericality => {:greater_than => 0, :less_than => 1001, :only_integer => true}

  # This is supposed to check size before upload but I don't think it does.
  # It does validate after upload, though, so it's not DDOS-proof but it will
  # prevent randos from using the grants server as an ftp site
  validate :proposal_validation, :if => "proposal?"

  def proposal_validation
    if proposal.size > 100.megabytes
      logger.warn "rejecting large upload: #{proposal.inspect}"
      errors[:proposal] << "File must be less than 100MB"
    end
  end
end
