extends StaticBody2D

var force = -600.0

func _on_detector_body_entered(body: Node2D) -> void:
	if "Player" in body.name:
		body.velocity.y = force
