namespace :grant_contracts do
  desc "Create 'golden' files for comparison"
  task create_golden: :environment do
    pdf_fixtures_path = File.join(Rails.root, 'spec', 'fixtures', 'pdfs')

    GrantContract.template_names.map do |template_name|
      pdf_file = File.join(pdf_fixtures_path, "#{template_name}.pdf")
      golden_file = File.join(pdf_fixtures_path, "#{template_name}.txt")

      puts "Generating golden file for #{template_name} [#{golden_file}, #{pdf_file}]"

      pdf = GrantContract.new(
        template_name,
        'SubmissionName',
        'ArtistName',
        'RequestedFundingDollars',
        Time.parse('2017-01-07 20:17:40')
      )
      text_analysis = PDF::Inspector::Text.analyze(pdf.render)
      full_text = text_analysis.strings.join("\n").strip

      # create golden_file from generated
      File.write(golden_file, full_text)

      # Also create reference pdf for human eval
      pdf.render_file pdf_file
    end
  end
end
