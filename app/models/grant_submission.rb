class GrantSubmission < ActiveRecord::Base
  belongs_to :grant
  belongs_to :artist
  has_many :submission_tag

  scope :funded, -> { where('granted_funding_dollars > ?', 0).where(funding_decision: true) }

  has_many :proposals, inverse_of: :grant_submission
  has_many :votes
  has_many :voter_submission_assignments
  has_many :voters, through: :voter_submission_assignments

  delegate :max_funding_dollars, to: :grant

  accepts_nested_attributes_for :proposals

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

  before_save :update_question_and_answer_dates

  def proposal_validation
    return unless proposal.size > 100.megabytes

    logger.warn "rejecting large upload: #{proposal.inspect}"
    errors[:proposal] << 'File must be less than 100MB'
  end

  def funded?
    funding_decision && (granted_funding_dollars || 0) > 0
  end

  def has_questions?
    questions.present?
  end

  def has_answers?
    answers.present?
  end

  def has_other_submissions?
    GrantSubmission.where(artist_id: artist_id).count > 1
  end

  def max_voters
    3
  end

  def num_voters_to_assign
    [max_voters - voter_submission_assignments.count, 0].max
  end

  # Returns a list of strings for each tag on the grant submission.
  def tags(can_view_hidden)
    if !can_view_hidden
      Tag.joins(:submission_tag)
        .where(hidden: false,
              :submission_tags => {:grant_submission_id => id})
        .map(&:name)
    else
      Tag.joins(:submission_tag)
        .where(:submission_tags => {:grant_submission_id => id})
        .map(&:name)
    end
  end

  # Sum up granted dollars for the provided grant ids (for filtering) and
  # by query (for further filtering).
  def self.granted_funding_dollars_total(id_list, query)
    grant_submissions = GrantSubmission.where(id: id_list).where(query).sum(:granted_funding_dollars)
  end

  private

  def update_question_and_answer_dates
    # TODO: is there a nice way to have this be the same as the new updated_at

    if questions_changed?
      self.questions_updated_at = Time.zone.now
    end

    if answers_changed?
      self.answers_updated_at = Time.zone.now
    end
  end
end
