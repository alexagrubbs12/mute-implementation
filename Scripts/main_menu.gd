extends Control

@onready var mute_button = $MuteButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mute_button.text = Global.mute_button_label
	if Global.music_muted:
		$MainMenu.stop()
	else:
		$MainMenu.play()

func _on_start_pressed() -> void:
	print("Start pressed")
	get_tree().change_scene_to_file("res://Scenes/user_interface_1.tscn")

func _on_instructions_pressed() -> void:
	print("Instructions pressed")
	get_tree().change_scene_to_file("res://Scenes/instructions.tscn")

func _on_mute_button_pressed() -> void:
	Global.music_muted = !Global.music_muted  # Toggle mute state

	if Global.music_muted:
		Global.mute_button_label = "Unmute"
		$MainMenu.stop()
	else:
		Global.mute_button_label = "Mute"
		$MainMenu.play()

	mute_button.text = Global.mute_button_label  # Update button text
