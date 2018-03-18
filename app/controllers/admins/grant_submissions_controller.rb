#
# Allows for Artist identities to be revealed and more fully featured
# order/scope options.
#
# Views here differ significantly from the non-admin versions.
#
class Admins::GrantSubmissionsController < ApplicationController
  load_and_authorize_resource

  before_filter :initialize_grants

  def initialize_grants
    @grants = Grant.all
  end

  def index
    @scope = params[:scope] || 'active'
    @grantscope = params[:grantscope] || 'all'
    @order = params[:order] || 'name'
    @show_scores = params[:scores] == 'true'

    if can? :reveal_identities, GrantSubmission
      @revealed = params[:reveal] == 'true'
    end

    if @scope == 'active'
      @grant_submissions = @grant_submissions.where(grant_id: active_vote_grants)
    end

    if @grantscope != 'all'
      @grant_submissions = @grant_submissions.joins(:grant).where("grants.name = ?", @grantscope)
    end

    @results = VoteResult.results(@grant_submissions)

    if @order == 'score'
      @grant_submissions = @grant_submissions.to_a.sort_by { |gs| [gs.grant_id, -gs.avg_score] }
    elsif @order == 'name'
      @grant_submissions = @grant_submissions.to_a.sort_by { |gs| gs.name }
    end
  end

  def send_fund_emails
    ids = params[:ids]&.split(',') || []
    @grant_submissions = GrantSubmission.where(id: ids)

    sent = 0
    @grant_submissions.each do |gs|
      if params[:send_email] == "true"
        artist = Artist.where(id: gs.artist_id).take
        grant = Grant.where(id: gs.grant_id).take
        begin
          if gs.granted_funding_dollars != nil && gs.granted_funding_dollars > 0
            UserMailer.grant_funded(gs, artist, grant, event_year).deliver
            logger.info "email: grant funded sent to #{artist.email}"
          else
            UserMailer.grant_not_funded(gs, artist, grant, event_year).deliver
            logger.info "email: grant not funded sent to #{artist.email}"
          end
        rescue
          flash[:warning] = "Error sending email (#{sent} sent)"
          redirect_to action: 'index'
          return
        end
        sent += 1
      end
      gs.funding_decision = true
      gs.save
    end

    flash[:info] = "#{sent} Funding Emails Sent"
    redirect_to action: 'index'
  end

  def send_question_emails
    @grant_submissions = GrantSubmission.where(grant_id: active_vote_grants)

    sent = 0
    @grant_submissions.each do |gs|
      if gs.questions != nil && gs.has_questions?
        artist = Artist.where(id: gs.artist_id).take
        grant = Grant.where(id: gs.grant_id).take
        begin
          UserMailer.notify_questions(gs, artist, grant, event_year).deliver
          logger.info "email: questions notification sent to #{artist.email}"
        rescue
          flash[:warning] = "Error sending emails (#{sent} sent)"
          redirect_to action: 'index'
          return
        end
        sent += 1
      end
    end

    flash[:info] = "#{sent} Question Notification Emails Sent"
    redirect_to action: 'index'
  end
end
