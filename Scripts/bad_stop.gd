extends Control
@onready var player_a = $BadSound
@onready var player_b = $Instructor

func _ready():
	player_a.connect("finished", Callable(self, "_on_player_a_finished"))
	player_a.play()

func _on_player_a_finished():
	player_b.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	print("Next pressed")
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
	
