class VotersController < ApplicationController
  load_and_authorize_resource only: [:new, :show]

  before_filter :initialize_grants

  def show
  end

  def new
  end

  def create
    if Voter.exists?(email: voter_params[:email.downcase])
      flash[:warning] = "The email address #{voter_params[:email.downcase]} already exists in our system"
      render "signup_failure"
      return
    end

    @voter = Voter.new(voter_params)

    @voter.email = @voter.email.downcase

    if @voter.save
      # save survey
      voter_survey = VoterSurvey.new(voter_survey_params)
      voter_survey.voter_id = @voter.id
      voter_survey.save

      # save participation info
      meetings = collated_meetings

      voter_participation_params.each do |collated_id, can_do|
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
      rescue
        flash[:warning] = "Error sending email confirmation"
        render "signup_failure"
        return
      end

      render "signup_success"
    else
      render "signup_failure"
    end
  end

  def update
    # could allow for (timing based) Voter enumeration
    @voter = Voter.find(params[:id])

    unless can? :manage, GrantsVoter.new(voter: @voter)
      redirect_to '/'
      return
    end

    voter_participation_params.each do |grant_id, can_do|
      unless Grant.find(grant_id).present?
        next
      end

      if can_do == '0'
        if GrantsVoter.exists?(voter_id: @voter.id, grant_id: grant_id)
          GrantsVoter.find_by(voter_id: @voter.id, grant_id: grant_id).destroy
        end
      else
        if GrantsVoter.exists?(voter_id: @voter.id, grant_id: grant_id)
          next
        end

        grants_voter = GrantsVoter.create!(voter: @voter, grant_id: grant_id)
      end
    end

    redirect_to controller: 'admins', action: 'voters'
  end

  private

  def initialize_grants
    @grants = Grant.all
  end

  def voter_params
    params.require(:voter).permit(:name, :password_digest, :password, :password_confirmation, :email)
  end

  def voter_survey_params
    params.require(:survey).permit(:has_attended_firefly, :not_applying_this_year,
        :will_read, :will_meet, :has_been_voter, :has_participated_other,
        :has_received_grant, :has_received_other_grant, :how_many_fireflies,
        :signed_agreement)
  end

  def voter_participation_params
    params.require(:grants_voters)
  end
end
