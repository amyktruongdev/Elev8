extends Node2D

var direction
var speed = 200.0

func _physics_process(delta: float) -> void:
	position.x += abs(speed * delta) * direction


func _on_area_2d_body_entered(_body: Node2D) -> void:
	queue_free()
