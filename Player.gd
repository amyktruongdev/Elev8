extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -550.0

@onready var sprite_2d = $Sprite2D

var health = 0

func damage_taken():
	if (health <= 0):
		get_tree().change_scene_to_file.call_deferred("res://DeathScreen.tscn")
	else:
		health -= 1


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if direction != 0:
		sprite_2d.flip_h = direction > 0

	move_and_slide()
