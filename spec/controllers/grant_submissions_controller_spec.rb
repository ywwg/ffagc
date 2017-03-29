describe GrantSubmissionsController do
  let!(:grant) { FactoryGirl.create(:grant)}
  let!(:artist) { FactoryGirl.create(:artist) }
  let!(:grant_submission) { FactoryGirl.create(:grant_submission, artist: artist, grant: grant) }

  describe '#discuss' do
    context 'artist signed in' do
      before { sign_in_artist(artist.id) }

      context 'with valid submission for artist' do
        render_views

        it 'shows discussion page' do
          get 'discuss', { id: grant_submission.id }
          expect(response).to render_template('grant_submissions/discuss')

          # this is an artist, so we can edit the answers but not questions
          assert_select 'textarea#grant_submission_questions[disabled=?]', 'disabled'

          # There has got to be an easier way to test for nonexistence of an attr.
          assert_select 'textarea#grant_submission_answers' do |e|
            e.each do |t|
              assert !t.attributes.has_key?('disabled')
            end
          end
        end
      end

      context 'with non-existent grant_submission id' do
        it 'redirects to /' do
          get 'discuss', { id: GrantSubmission.count + 1 }
          expect(response).to redirect_to('/')
        end
      end

      context 'with grant_submission id for another artist' do
        let!(:another_grant_submission) { FactoryGirl.create(:grant_submission) }

        it 'redirects to /' do
          get 'discuss', { id: another_grant_submission.id }
          expect(response).to redirect_to('/')
        end
      end
    end

    context 'voter signed in' do
      let(:voter) { FactoryGirl.create(:voter, :verified) }

      before { sign_in_voter(voter.id) }

      context 'with valid grant_submission' do
        render_views

        it 'shows discussion page' do
          get 'discuss', { id: grant_submission.id }
          expect(response).to render_template('grant_submissions/discuss')

          # this is a voter, can't edit either
          assert_select 'textarea#grant_submission_questions[disabled=?]', 'disabled'
          assert_select 'textarea#grant_submission_answers[disabled=?]', 'disabled'
        end
      end

      context 'with non-existent grant_submission id' do
        it 'redirects to /' do
          get 'discuss', { id: GrantSubmission.count + 1 }
          expect(response).to redirect_to('/')
        end
      end
    end

    context 'admin signed in' do
      let(:admin) { FactoryGirl.create(:admin, :activated) }

      before { sign_in_admin(admin.id) }

      context 'with valid grant_submission' do
        render_views

        it 'shows discussion page' do
          get 'discuss', { id: grant_submission.id }
          expect(response).to render_template('grant_submissions/discuss')

          # this is an admin, can edit both
          assert_select 'textarea#grant_submission_questions' do |e|
            e.each do |t|
              assert !t.attributes.has_key?('disabled')
            end
          end
          assert_select 'textarea#grant_submission_answers' do |e|
            e.each do |t|
              assert !t.attributes.has_key?('disabled')
            end
          end
        end
      end

      context 'with non-existent grant_submission id' do
        it 'redirects to /' do
          get 'discuss', { id: GrantSubmission.count + 1 }
          expect(response).to redirect_to('/')
        end
      end
    end
  end
end
