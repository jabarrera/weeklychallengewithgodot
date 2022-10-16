extends Button

var selected_week = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	disabled = true

func _on_comboBoxWeeks_week_selected(week_name):
	selected_week = week_name
	text = "Run" + " " + selected_week
	disabled = false


func _on_RunButton_pressed():
	get_tree().change_scene("res://challenges/" + selected_week + "/scenes/main.tscn")
