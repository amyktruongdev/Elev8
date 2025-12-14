extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_demo_1_pressed() -> void:
	get_tree().change_scene_to_file("res://DemoLevel1.tscn")


func _on_demo_2_pressed() -> void:
	get_tree().change_scene_to_file("res://DemoLevel2.tscn")


func _on_demo_4_pressed() -> void:
	get_tree().change_scene_to_file("res://DemoLevel4.tscn")


func _on_demo_3_pressed() -> void:
	get_tree().change_scene_to_file("res://DemoLevel3.tscn")
