extends CharacterBody2D

const JUMP_VELOCITY = -400.0
var jump_check = false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if jump_check and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_check = false

	move_and_slide()

func die():
	queue_free()

func _on_timer_timeout() -> void:
	jump_check = true


func _on_area_2d_body_entered(body: Node2D) -> void:
	if "Player" in body.name:
		if body.can_attack:
			body.play_kill_sound()
			die()
			body.disable_attack()
		else:
			body.damage_taken()
