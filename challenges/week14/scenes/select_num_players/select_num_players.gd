extends Node2D

signal num_players_selected(num_players)


func _on_HSlider_drag_ended(value_changed):
	$Panel/text_num_player.text = str($Panel/num_player_slider.value)


func _on_Button_button_up():
	emit_signal("num_players_selected", $Panel/num_player_slider.value)
