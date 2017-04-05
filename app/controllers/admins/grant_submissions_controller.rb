#
# Allows for Artist identities to be revealed and more fully featured
# order/scope options.
#
# Views here differ significantly from the non-admin versions.
#
class Admins::GrantSubmissionsController < ApplicationController
  load_and_authorize_resource

  before_filter :verify_admin

  def index
    @scope = params[:scope] || 'active'
    @order = params[:order] || 'name'
    @show_scores = params[:scores] == 'true'

    if can? :reveal_identities, GrantSubmission
      @revealed = params[:reveal] == 'true'
    end

    if @scope == 'active'
      @grant_submissions = @grant_submissions.where(grant_id: active_vote_grants)
    end

    @results = VoteResult.results(@grant_submissions)

    if @order == 'score'
      @grant_submissions = @grant_submissions.to_a.sort_by { |gs| [gs.grant_id, -gs.avg_score] }
    elsif @order == 'name'
      @grant_submissions = @grant_submissions.to_a.sort_by { |gs| gs.name }
    end
  end
end
