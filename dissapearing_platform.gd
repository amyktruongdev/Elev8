extends StaticBody2D

@onready var animation = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	animation.play("flashing")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if "Player" in body.name:
		set_process(true)
		$DestructTimer.start(2.5)

func _on_destruct_timer_timeout() -> void:
	queue_free()
