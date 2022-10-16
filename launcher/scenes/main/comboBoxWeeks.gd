extends Button

signal week_selected(week_name)

func _ready():
	$WeekList.visible = !$WeekList.visible
	fillWeekList()



#Functions
func fillWeekList():
	var dir = Directory.new()
	dir.open("res://challenges")
	dir.list_dir_begin(true, true)
	
	var element = dir.get_next()
	
	while(element != ""):
		$WeekList.add_item(element.get_basename())
		element = dir.get_next()

#Connections
func _on_comboBoxWeeks_pressed():
	$WeekList.visible = !$WeekList.visible


func _on_WeekList_item_selected(index):
	text = $WeekList.get_item_text(index)
	$WeekList.hide()
	emit_signal("week_selected", text)
	
	
