extends CharacterBody2D

const SPEED = 400.0
const JUMP_VELOCITY = -550.0

@onready var sprite_2d = $Sprite2D
@onready var jump_sound = $AudioStreamPlayer
@onready var kill_sound = $AudioStreamPlayer2
@onready var item_get_sound = $AudioStreamPlayer3
@onready var hit_sound = $AudioStreamPlayer4
@onready var dash_sound = $AudioStreamPlayer5
@onready var iframetimer: Timer = $IFrameTimer
@onready var invincibletimer: Timer = $InvincibleTimer
@onready var timer1: Timer = $DurationTimer
@onready var timer2: Timer = $CooldownTimer

var is_dashing = false
var can_dash = false
var dash_speed = 3
var health = 0
var can_take_damage = true
var is_invincible = false
var can_attack = false

func play_kill_sound():
	kill_sound.play()

func play_item_get_sound():
	item_get_sound.play()

func enable_attack():
	can_attack = true
	sprite_2d.modulate = Color.GREEN

func disable_attack():
	can_attack = false
	sprite_2d.modulate = Color.WHITE

func activate_dash():
	can_dash = true

func become_invincible():
	is_invincible = true
	sprite_2d.modulate = Color.YELLOW
	invincibletimer.start()

func health_increase():
	health += 1

func damage_taken():
	if can_take_damage && is_invincible == false:
		if health <= 0:
			get_tree().change_scene_to_file.call_deferred("res://DeathScreen.tscn")
		else:
			can_take_damage = false
			health -= 1
			hit_sound.play()
			sprite_2d.modulate = Color.RED
			iframetimer.start()

func _ready():
	health = 0
	can_take_damage = true
	is_invincible = false
	can_attack = false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		

	# Handle jump.
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		jump_sound.play()
		velocity.y = JUMP_VELOCITY
		
	if (Input.is_action_just_pressed("ui_accept") and can_dash):
		is_dashing = true
		can_dash = false
		dash_sound.play()
		timer1.start()
		timer2.start()

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if direction != 0:
		sprite_2d.flip_h = direction > 0
		
	if is_dashing:
		velocity.x = direction * SPEED * dash_speed

	move_and_slide()
	

func _on_i_frame_timer_timeout() -> void:
	can_take_damage = true
	sprite_2d.modulate = Color.WHITE

func _on_invincible_timer_timeout() -> void:
	is_invincible = false
	sprite_2d.modulate = Color.WHITE

func _on_duration_timer_timeout() -> void:
	is_dashing = false

func _on_cooldown_timer_timeout() -> void:
	can_dash = true
