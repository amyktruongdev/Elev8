extends Control

@onready var load_button: Button = $VBoxContainer/Load
const LEVEL_SELECTOR_SCENE: String = "res://LevelSelector.tscn"

func _ready() -> void:
	load_button.pressed.connect(_on_load_pressed)

func _on_demo_pressed() -> void:
<<<<<<< HEAD
	get_tree().change_scene_to_file("res://DemoLevel1.tscn")

func _on_load_pressed() -> void:
	print("🎮 Opening Level Selector...")
	var level_selector_scene: PackedScene = load(LEVEL_SELECTOR_SCENE)
	if level_selector_scene == null:
		print("⚠ Could not load LevelSelector scene!")
		return
	get_tree().change_scene_to_packed(level_selector_scene)
=======
	get_tree().change_scene_to_file("res://DemoLevelSelect.tscn")
>>>>>>> master
