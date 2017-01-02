require 'erb'

class GrantContract < Prawn::Document

  def initialize(grant, project, artist, amount, date)
    super()
  	@grant = grant
  	@project = project
  	@artist = artist
  	@amount = amount
  	@date = date.strftime("%Y-%m-%d")

    # @year should probably come from the template_values yaml.
    @year = Rails.configuration.event_year

  	@values = YAML.load(File.open("#{Rails.root}/config/template_values.yml", "rb").read)

  	begin
  	  # XXX hardcoding alert! Template filename must be the same as the grant name,
  	  # except all lowercase.
  	  filename = "#{Rails.root}/app/assets/contract_templates/#{@grant.downcase}.tmpl.erb"
      template = File.open(filename, "rb").read
      template.each_line do |line|
        write_templated_line line
      end
  	rescue
  	  # TODO maybe actually handle errors
  	  return
  	end
  end

  def write_templated_line(line)
    # This is a super simple templating system based on ERB and keywords.
    # Leading spaces (including spaces after the comma following a token)
    # are converted to indentation.  More spaces, more indents.
    # Then, if a line begins with [[ (after any indentation) it's a formatting
    # token.  The supported keywords are in the if/else chain below.
    # A space must follow the token, and then the text follows, like this:
    # [[TITLE]] This Is My Title

    # Lines beginning with '#' are comments

    # Defaults:
    align = :left
    size = 12
    style = :normal
    indent_amount = 0

    # Comments.
    if line.start_with? "#"
      return
    end

    # Do indentation first
    while line.start_with? " "
      indent_amount += 5
      line = line[1..-1]
    end

    # Process token and strip it
    if line.start_with? "[["
      tok = line.split(" ", 2)
      if tok[0] == "[[TITLE]]"
        align = :center
        size = 16
        style = :bold
      elsif tok[0] == "[[HEADING]]"
        size = 14
        style = :bold
      elsif tok[0] == "[[SUBHEADING]]"
        size = 12
        style = :bold
      elsif tok[0] == "[[SIGNATURES]]"
        write_signatures
        return
      elsif tok[0] == "[[PAGEBREAK]]"
        start_new_page
        return
      end
      line = tok[1]
    end
    return if line == nil

    # Render the line
    template = ERB.new line
    font("Times-Roman") do
      indent(indent_amount) do
    	   text template.result(binding), :align => align, :size => size, :style => style, :indent_paragraphs => indent_amount
    	end
    end
  end

  def write_signatures()
    move_down 100
    font("Times-Roman") do
      float do
        bounding_box([50, cursor], :width => 200, :height => cursor) do
          stroke_horizontal_rule
          move_down 5
          text "#{@artist}"

          move_down 40
          stroke_horizontal_rule
          move_down 5
          text "Project Title"

          move_down 40
          stroke_horizontal_rule
          move_down 5
          text "Firefly Arts Collective Representative"
        end
      end

      bounding_box([300, cursor], :width => 200, :height => cursor) do
        stroke_horizontal_rule
        move_down 5
        text "Date"

        move_down 40
        stroke_horizontal_rule
        move_down 5
        text "Grant Amount"

        move_down 40
        stroke_horizontal_rule
        move_down 5
        text "Date"
      end
    end
  end
end
