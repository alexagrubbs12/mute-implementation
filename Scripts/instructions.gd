extends Control

# Function triggered when the back button is pressed
func _on_BackButton_pressed() -> void:
	print("Returning to Main Menu")
	
	if Global.music_muted:
		if $Instructions:
			$Instructions.stop()
	
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
