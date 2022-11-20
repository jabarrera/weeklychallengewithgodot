extends Node2D


signal language_selected(language)



func _on_SpanishButton_button_up():
	emit_signal("language_selected", "es")
	
func _on_EnglishButton_button_up():
	emit_signal("language_selected", "en")
