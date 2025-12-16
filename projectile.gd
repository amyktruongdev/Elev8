extends Node2D

@onready var animation = $AnimationPlayer

var direction
var speed = 150.0


func _physics_process(delta: float) -> void:
	animation.play("newFlash")
	position.x += abs(speed * delta) * direction


func _on_area_2d_body_entered(body: Node2D) -> void:
	if "Player" in body.name:
		body.damage_taken()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
