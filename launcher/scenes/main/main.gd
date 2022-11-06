extends Node2D


############ signals
func _on_comboBoxWeeks_week_selected(week_name):
	set_screenshot(week_name)
	set_description(week_name)

############

############ methods
func set_screenshot(week_name : String):
	var screenshot_image = load("res://challenges/" + week_name + "/" + week_name + ".jpg")
	$screenCapture.texture = screenshot_image
	
func set_description(week_name : String):
	var description_text = read_file_content("res://challenges/" + week_name + "/" + week_name + ".desc")
	$RichTextLabel.bbcode_text = description_text
	
func read_file_content(fileUri : String):
	var file : File = File.new()
	var description : String = ""
	
	if file.file_exists(fileUri):
		file.open(fileUri, File.READ)
		description = file.get_as_text()
	
	return description
############
