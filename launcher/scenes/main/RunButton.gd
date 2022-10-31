extends Button

signal option_selected(option)

var selected_week = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	disabled = true

func _on_comboBoxWeeks_week_selected(week_name):
	set_option(week_name)
	emit_signal("option_selected", week_name)
	disabled = false


func _on_RunButton_pressed():
	get_tree().change_scene("res://challenges/" + selected_week + "/scenes/main.tscn")


func set_option(week_name):
	selected_week = week_name
	text = "Run" + " " + selected_week
