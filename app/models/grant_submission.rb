class GrantSubmission < ActiveRecord::Base
  belongs_to :grant
  belongs_to :artist

  has_many :proposals
  has_many :votes
  has_many :voter_submission_assignments

  delegate :max_funding_dollars, to: :grant

  mount_uploader :proposal, GrantProposalUploader

  validates :name, presence: true, length: { minimum: 4 }
  # Can't require proposal because modification might not change the proposal.
  # validates :proposal, :presence => true

  validates :grant, presence: true

  # Max value depends on the grant
  validates :requested_funding_dollars, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: :max_funding_dollars, only_integer: true }

  # This is supposed to check size before upload but I don't think it does.
  # It does validate after upload, though, so it's not DDOS-proof but it will
  # prevent randos from using the grants server as an ftp site
  validate :proposal_validation, if: :proposal?

  def proposal_validation
    return unless proposal.size > 100.megabytes

    logger.warn "rejecting large upload: #{proposal.inspect}"
    errors[:proposal] << 'File must be less than 100MB'
  end
end
