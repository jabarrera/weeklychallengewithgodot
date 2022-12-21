extends Button

signal week_selected(week_name)


func _unhandled_input(event):
	if event is InputEventMouseButton:
		$WeekList.visible = false
		
func _ready():
	$WeekList.visible = !$WeekList.visible
	fillWeekList()

#Functions
func fillWeekList():
	var directories : Array
	
	var dir = Directory.new()
	dir.open("res://challenges")
	dir.list_dir_begin(true, true)
	
	var element = dir.get_next()
	
	while(element != ""):
		directories.append(element.get_basename())
		element = dir.get_next()
		
	if (not directories.empty()):
		directories.sort_custom(self, "custom_week_sort")
		for directory in directories:
			$WeekList.add_item(directory)

func custom_week_sort(directory_1 : String, directory_2 : String) -> bool:
	var number_directory_1 = directory_1.replace("week", "").to_int()
	var number_directory_2 = directory_2.replace("week", "").to_int()
	
	return number_directory_1 <= number_directory_2

#Connections
func _on_comboBoxWeeks_pressed():
	$WeekList.visible = !$WeekList.visible


func _on_WeekList_item_selected(index):
	text = $WeekList.get_item_text(index)
	$WeekList.hide()
	emit_signal("week_selected", text)
	
	
