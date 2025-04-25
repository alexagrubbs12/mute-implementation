extends Area3D

@onready var speed_label = $Node3D/Label3D  # Adjust path if needed
var VAL: int
var SPEED_LIMIT = (VAL* 1.609) / 3.8  # Maximum allowed speed

var car_in_area = false
var car: BaseCar = null  # Reference to the car in the speed limit zone
var speeding = false  # Flag to track if the car is speeding

func _ready():
	randomize()
	VAL = randi_range(2,5)*10
	SPEED_LIMIT = (VAL* 1.609) / 3.8
	update_speed_limit_text()
	var car = get_tree().get_nodes_in_group("Cars").front()  # Assuming one car
	if car:
		car.car_reset.connect(randomize_speed_limit)
	
func randomize_speed_limit():
	VAL = randi_range(2, 5) * 10  # Randomize speed limit again
	update_speed_limit_text()
	SPEED_LIMIT = (VAL* 1.609) / 3.8
	print("New Speed Limit Set:", VAL)


func update_speed_limit_text():
	speed_label.text = str(VAL)

func _process(delta):
	if car_in_area and car != null:
		var car_speed = car.linear_velocity.length()
		print("Car Speed:", car_speed)

		if car_speed > SPEED_LIMIT:
			if not speeding:
				print("Speeding detected!")
				speeding = true
				car.apply_speeding_penalty()  # Apply penalty immediately
		else:
			if speeding:
				print("Car is within speed limit.")
				speeding = false
				car.successfully_maintained_speed()

func _on_body_entered(body):
	if body is BaseCar:
		car = body
		car_in_area = true
		speeding = false  # Reset flag on entry
		print("Car entered speed limit zone.")

func _on_body_exited(body):
	if body is BaseCar:
		car.successfully_maintained_speed()
		car_in_area = false
		car = null
