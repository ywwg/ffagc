require 'test_helper'

# If this test fails, you probably updated the grant contracts and need
# to update the golden files in test/pdfs.  You can recreate the golden
# files by deleting all of them and rerunning rake.  The outputs will be
# generated automatically.  You should hand-inspect the pdf output to make
# sure it appears correct.

class GrantContractTest < ActionDispatch::IntegrationTest

  test "grant contract generation" do
    Dir["#{Rails.root}/app/assets/contract_templates/*.tmpl.erb"].each do |f|
      grant_name = /contract_templates\/(.*)\.tmpl/.match(f)[1]

      fake_now = Time.parse("2017-01-07 20:17:40")
      pdf = GrantContract.new(grant_name, "SubmissionName", "ArtistName",
          "RequestedFundingDollars", fake_now)
      text_analysis = PDF::Inspector::Text.analyze(pdf.render)
      full_text = text_analysis.strings.join("\n").strip

      golden_file = "#{Rails.root}/test/pdfs/#{grant_name}.txt"
      if !Pathname.new(golden_file).exist?
        puts "WARNING, golden file for #{grant_name} not found, generating"
        open(golden_file, "w") do |g|
          g.puts full_text
        end
        # Also create reference pdf for human eval
        pdf.render_file "#{Rails.root}/test/pdfs/#{grant_name}.pdf"
      else
        golden_output = File.open(golden_file, "rb").read.strip
        if golden_output != full_text
          puts "want:\n#{golden_output}\ngot:\n#{full_text}"
        end
        assert golden_output == full_text
      end
    end
  end

 end