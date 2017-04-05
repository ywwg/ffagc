class VotersController < ApplicationController
  load_and_authorize_resource

  before_filter :initialize_grants

  def index
  end

  def show
  end

  def new
    @voter.voter_survey ||= @voter.build_voter_survey
  end

  def create
    @voter = Voter.new(voter_params)
    @voter.email = @voter.email.downcase

    if Voter.exists?(email: @voter.email)
      flash[:warning] = "The email address #{@voter.email} already exists in our system"
      render 'new'
      return
    end

    if @voter.save
      # save participation info
      meetings = collated_meetings

      params.require(:grants_voters).each do |collated_id, can_do|
        if can_do == "0"
          next
        end
        # We have to map from collated index to the list of grants.
        # This is a gross n*m walk through the lists, but we are talking very
        # small lists.
        meetings.each do |dates, data|
          if data['id'].to_s != collated_id
            next
          end
          data['grant_ids'].each do |gid|
            # sanity check that the grant id is real.
            if Grant.find(gid) == nil
              next
            end
            grants_voter = GrantsVoter.new
            grants_voter.voter_id = @voter.id
            grants_voter.grant_id = gid
            grants_voter.save
          end
        end
      end

      # Send email
      begin
        UserMailer.account_activation("voters", @voter).deliver_now
        logger.info "email: voter account activation sent to #{@voter.email}"

        render 'create_success'
        return
      rescue
        flash[:warning] = "Error sending email confirmation"
      end
    end

    render 'new'
  end

  def update
    process_grants_voter(@voter, params.require(:grants_voters))

    redirect_to after_update_path(@voter)
  end

  private

  def initialize_grants
    @grants = Grant.all
  end

  def voter_params
    params.require(:voter).permit(:name, :password, :password_confirmation, :email,
                                  voter_survey_attributes: voter_survey_attributes)
  end

  def voter_survey_attributes
    [
      :has_attended_firefly,
      :not_applying_this_year,
      :will_read,
      :will_meet,
      :has_been_voter,
      :has_participated_other,
      :has_received_grant,
      :has_received_other_grant,
      :how_many_fireflies,
      :signed_agreement
    ]
  end

  def after_update_path(voter)
    if can? :index, Voter
      voters_path
    elsif can? :show, voter
      voter_path(voter)
    else
      root_path
    end
  end

  def process_grants_voter(voter, grants_voters_params)
    grants_voters_params.each do |grant_id, can_do|
      grant = Grant.find(grant_id)
      next unless grant.present?

      if can_do == '0'
        if GrantsVoter.exists?(voter: voter, grant: grant)
          GrantsVoter.find_by(voter: voter, grant: grant).destroy
        end
      else
        GrantsVoter.first_or_create!(voter: voter, grant: grant)
      end
    end
  end
end
