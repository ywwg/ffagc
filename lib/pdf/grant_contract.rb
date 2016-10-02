class GrantContract < Prawn::Document

  def initialize(grant, project, artist, amount)
    super()
	@grant = grant
	@project = project
	@artist = artist
	@amount = amount
	
	text "wow that was hard: #{@grant}, #{@project}, #{@artist}, #{@amount}"
  end
end
