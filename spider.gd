extends CharacterBody2D


var speed = -100.0
var facing_right = false

@onready var ray_cast_wall = $RayCastWall

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if !$RayCast2D.is_colliding() && is_on_floor():
		flip()
	if ray_cast_wall.is_colliding() && is_on_floor():
		flip()
	
	velocity.x = speed
	move_and_slide()

func flip():
	facing_right = !facing_right
	
	scale.x = abs(scale.x) * -1
	if facing_right:
		speed = abs(speed)
	else:
		speed = abs(speed) * -1
	


func _on_area_2d_body_entered(body: Node2D) -> void:
	if "Player" in body.name:
		get_tree().change_scene_to_file.call_deferred("res://DeathScreen.tscn")
