namespace :grant_contracts do
  desc %q{Create 'golden' files for comparison}
  task create_golden: :environment do
    pdf_fixtures_path = File.join(Rails.root, 'spec', 'fixtures', 'pdfs')

    GrantContract.grant_names.map do |grant_name|
      pdf_file = File.join(pdf_fixtures_path, "#{grant_name}.pdf")
      golden_file = File.join(pdf_fixtures_path, "#{grant_name}.txt")

      puts "Generating golden file for #{grant_name} [#{golden_file}, #{pdf_file}]"

      pdf = GrantContract.new(
        grant_name,
        "SubmissionName",
        "ArtistName",
        "RequestedFundingDollars",
        Time.parse("2017-01-07 20:17:40")
      )

      # create golden_file from generated
      File.write(golden_file, full_text)

      # Also create reference pdf for human eval
      pdf.render_file pdf_file
    end
  end
end

