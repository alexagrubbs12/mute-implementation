extends VehicleBody3D
class_name BaseCar

@onready var feedback_label = $UI/FeedbackLabel  # Reference to feedback message
@onready var siren_sound = %SirenSound           # Reference to siren sound
@onready var pluspoint = %pluspoint
@onready var minuspoint = %minuspoint
@onready var end_popup = $UI/EndPopup            # End pop-up UI
@onready var end_message = $UI/EndPopup/Message  # Pop-up text
@onready var close_button = $UI/EndPopup/CloseButton  # Close button
@onready var score_label = %Hud/ScoreLabel    # On-screen score display
@onready var bgm_player = %BGMPLayer
@onready var end_music_player = %EndMusicPlayer


@export var STEER_SPEED = 1.5
@export var STEER_LIMIT = 0.6
var steer_target = 0
@export var engine_force_value = 40
var init_transform : Transform3D  # Store initial position

var game_paused = false  # Track if the game is paused
var fwd_mps : float
var speed: float
var score: int = 0 


func _ready():
	init_transform = transform
	bgm_player.play()  # Save the starting position
	# Debugging node existence
	print("Looking for FeedbackLabel...")

	if has_node("UI/FeedbackLabel"):
		feedback_label = get_node("UI/FeedbackLabel")
		print("FeedbackLabel found!")
	else:
		print("Error: FeedbackLabel not found!")
		
	if has_node("pluspoint"):
		pluspoint = get_node("pluspoint")
		print("pluspoint found!")
	else:
		print("Error: pluspoint not found!")
	
	if has_node("minuspoint"):
		minuspoint = get_node("minuspoint")
		print("minuspoint found!")
	else:
		print("Error: minuspoint not found!")

func _physics_process(delta):
	speed = linear_velocity.length()*Engine.get_frames_per_second()*delta
	fwd_mps = transform.basis.x.x
	traction(speed)
	process_accel(delta)
	process_steer(delta)
	process_brake(delta)
	%Hud/speed.text=str(round(speed*3.8 / 1.609))+"  MPH"

func process_accel(delta):
	var speed_mph = speed * 3.8 / 1.609
	var max_speed_mph = 100
	var speed_factor = max(0, (max_speed_mph - speed_mph) / max_speed_mph) 

	if Input.is_action_pressed("ui_up"):
		if fwd_mps >= -1:
			engine_force = clamp(
				engine_force_value * (1.0 / (1.0 + speed * 0.02)) * speed_factor, 
				0, 
				300
			)
		return
	
	if Input.is_action_pressed("ui_down"):
	# Increase engine force at low speeds to make the initial acceleration faster.
		if speed < 20 and speed != 0:
			engine_force = -clamp(engine_force_value * 3 / speed, 0, 300)
		else:
			engine_force = -engine_force_value
		return
	
	engine_force = 0
	brake = 0	

func process_steer(delta):
	steer_target = Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right")
	steer_target *= STEER_LIMIT
	steering = move_toward(steering, steer_target, STEER_SPEED * delta)

func process_brake(delta):
	if Input.is_action_pressed("ui_select"):
		brake = 1.0
		$wheel_rear_left.wheel_friction_slip=2
		$wheel_rear_right.wheel_friction_slip=2
	else:
		$wheel_rear_left.wheel_friction_slip=2.9
		$wheel_rear_right.wheel_friction_slip=2.9


func traction(speed):
	apply_central_force(Vector3.DOWN*speed)


#func _on_area_3d_body_entered(body: Node3D) -> void:
	#if body.is_in_group("Trees"):  # Ensure your trees are in the "trees" group
		#reset_car()
		
func _on_area_3d_body_entered(body: Node3D) -> void:
	print("Collision detected with:", body.name)
	var message = ""

	if body.is_in_group("Buildings"):
		get_tree().change_scene_to_file("res://Scenes/bad_buildings_and_trees.tscn")
		reset_score()
		
	elif body.is_in_group("Trees"):
		get_tree().change_scene_to_file("res://Scenes/bad_buildings_and_trees.tscn")
		reset_score()
		
	elif body.is_in_group("StopSigns"):
		get_tree().change_scene_to_file("res://Scenes/bad_stop.tscn")  # Load the "Bad Stop" scene 
		reset_score()
		
	elif body.is_in_group("OncomingLane"):
		get_tree().change_scene_to_file("res://Scenes/bad_oncoming_traffic.tscn")
		reset_score()
		
	elif body.is_in_group("EndBarrier"):
		display_end_message()
		return  # Prevent normal collision behavior

	if message != "":
		display_feedback(message)

	
	
func reset_car():
	feedback_label.visible = false  # Hide the message
	PhysicsServer3D.body_set_state(
		get_rid(),
		PhysicsServer3D.BODY_STATE_TRANSFORM,
		init_transform
	)
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO

func display_feedback(message: String):
	feedback_label.text = message  # Set the message text
	feedback_label.visible = true  # Show the message
	siren_sound.play()  # Play the police siren sound

	await get_tree().create_timer(2.0).timeout  # Wait for 3 seconds

	reset_car()  # Reset the car after the delay

func apply_stop_sign_penalty():
	get_tree().change_scene_to_file("res://Scenes/bad_stop.tscn")  # Load the "Bad Stop" scene
	reset_score()

func successfully_stopped_at_stop_sign():
	score += 15  # Award points
	update_score_display()
	pluspoint.play()
	
func apply_speeding_penalty():
	feedback_label.text = "Slow down! Watch your speed!"  # Set the message text
	feedback_label.visible = true
	score -= 5
	update_score_display()
	minuspoint.play()
	
func successfully_maintained_speed():
	feedback_label.visible = false
	
func reset_score():
	score = 0
	update_score_display()

func update_score_display():
	if score_label:
		score_label.text = "Score: " + str(score)




# End barrier pop-up display
func display_end_message():
	game_paused = true
	Engine.time_scale = 0  # Freeze the game

	feedback_label.visible = false
	end_popup.visible = true
	
	bgm_player.stop()
	end_music_player.play()

	end_message.clear()  # Clear any existing text

	var message_text = "[center]🏁 Final Score: " + str(score)+ "\n\n\n\n\n"
	message_text += "🚦 Quick Traffic Tips for the Real World:\n\n\n\n\n"
	message_text += "- 🛑 Stop signs = full stop, look around, go when safe.\n\n\n\n\n"
	message_text += "- ⚠️ Speed limits = max speed allowed, not a suggestion!\n\n\n\n\n"
	message_text += "Drive smart out there! Hit X to Play Again![/center]"

	end_message.parse_bbcode(message_text)


# Close pop-up and restart game
func close_end_popup():
	game_paused = false
	Engine.time_scale = 1  # Resume normal speed

	end_popup.visible = false  # Hide pop-up
	reset_score()
	reset_car()  # Reset the car position
	
	end_music_player.stop()
	bgm_player.play()

func _on_oncoming_lane_entered(body: Node3D):
	get_tree().change_scene_to_file("res://Scenes/bad_oncoming_traffic.tscn")
	reset_score()
	
