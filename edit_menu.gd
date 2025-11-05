extends Control

@onready var sprites_button = $Sprites
@onready var blocks_button = $Blocks
@onready var platforms_button = $Platforms
@onready var items_button = $Items
@onready var enemies_button = $Enemies
@onready var popup = $PopupMenu
@onready var blocks_popup = $blocks_menu
@onready var platforms_popup = $platforms_menu
@onready var items_popup = $items_menu
@onready var enemies_popup = $enemies_menu

func _ready():
	# Add menu items to the popup
	popup.add_icon_item(load("res://bear.png"),"Bear",0)
	popup.add_icon_item(load("res://root_guy.png"),"Root Guy",0)
	
	platforms_popup.add_icon_item(load("res://GrassPLatform.png"),"Grass Platform",0)
	platforms_popup.add_icon_item(load("res://RockBlock.png"),"Rock Platform",0)

	# Connect the popup’s item selection signal
	popup.connect("id_pressed", Callable(self, "_on_menu_item_pressed"))
	

func _on_menu_item_pressed(id):
	match id:
		0:
			print("Add Sprite selected")
		1:
			print("Edit Sprite selected")
		2:
			print("Delete Sprite selected")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta: float) -> void:
#	pass


func _on_sprites_pressed() -> void:
	# Position popup just below the Sprites button
	var button_pos = sprites_button.get_global_position()
	var button_size = sprites_button.size
	popup.position = button_pos + Vector2(0, button_size.y)

	# Show the popup
	popup.popup()


#func _on_blocks_pressed() -> void:
#	pass # Replace with function body.


#func _on_platforms_pressed() -> void:
#	pass # Replace with function body.


#func _on_items_pressed() -> void:
#	pass # Replace with function body.


#func _on_enemies_pressed() -> void:
	#pass # Replace with function body.
