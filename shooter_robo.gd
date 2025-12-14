extends CharacterBody2D

var projectile = load("res://Projectile.tscn")
var shooting = false
var firerate = 5

@onready var Spawnpoint = $Spawnpoint

func _ready():
	shooting = true
	shoot()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	move_and_slide()

func shoot():
	while shooting:
		var spawned_projectile = projectile.instantiate()
		spawned_projectile.direction = Spawnpoint.scale.x
		spawned_projectile.global_position = Spawnpoint.position
		add_child(spawned_projectile)
		await get_tree().create_timer(firerate).timeout


func _on_area_2d_body_entered(body: Node2D) -> void:
	if "Player" in body.name:
		body.damage_taken()
