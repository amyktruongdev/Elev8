extends CharacterBody2D


var speed = 100.0
var facing_right = true

func _physics_process(_delta: float) -> void:
	
	velocity.x = speed
	move_and_slide()

func flip():
	facing_right = !facing_right
	
	scale.x = abs(scale.x) * -1
	if facing_right:
		speed = abs(speed)
	else:
		speed = abs(speed) * -1

func _on_timer_timeout() -> void:
	flip()
