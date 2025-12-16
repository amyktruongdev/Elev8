extends Control

# =========================================================
# Level Select Screen
# =========================================================

const LEVEL_EDITOR_SCENE := "res://control.tscn"
const MAIN_MENU_SCENE := "res://MainMenu.tscn"

# Three save slots
const SAVE_SLOTS: Array[String] = [
	"user://level_slot_1.json",
	"user://level_slot_2.json",
	"user://level_slot_3.json"
]

@onready var grid: GridContainer = $MainVBox/GridContainer
@onready var title_label: Label = $MainVBox/Title
@onready var back_btn: Button = $MainVBox/BackButton


func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.653, 0.393, 0.054, 1.0) # dark gray
	bg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bg.size_flags_vertical = Control.SIZE_EXPAND_FILL

	add_child(bg)
	move_child(bg, 0) # send to back
	title_label.text = "Select Level to Load"
	title_label.custom_minimum_size.y = 100
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_color_override("font_color", Color.BLACK)
	grid.add_theme_constant_override("h_separation", 60)
	grid.add_theme_constant_override("v_separation", 40)
	_populate_slots()
	back_btn.pressed.connect(_on_back_pressed)


# =========================================================
# SLOT CREATION
# =========================================================
func _populate_slots() -> void:
	# Clear existing slots
	for child in grid.get_children():
		child.queue_free()

	for i in range(SAVE_SLOTS.size()):
		var slot_path := SAVE_SLOTS[i]

		var slot_vbox := VBoxContainer.new()
		slot_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		
		slot_vbox.add_theme_constant_override("separation", 20)
		# --- Preview Image ---
		var preview := TextureRect.new()
		preview.custom_minimum_size = Vector2(280, 160)
		preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

		# --- Label ---
		var label := Label.new()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

		# --- Button ---
		var button := Button.new()
		button.custom_minimum_size = Vector2(180, 40)

		if FileAccess.file_exists(slot_path):
			# Saved level
			preview.texture = load("res://sprites/Robo.png") # placeholder
			label.text = "Saved Level %d" % (i + 1)
			label.add_theme_color_override("font_color", Color.BLACK)
			button.text = "Load"
		else:
			# Empty slot
			preview.texture = load("res://sprites/rootguy.png") # placeholder
			label.text = "Empty Slot %d" % (i + 1)
			button.text = "New"

		button.pressed.connect(func(): _on_slot_pressed(i))

		slot_vbox.add_child(preview)
		slot_vbox.add_child(label)
		slot_vbox.add_child(button)
		grid.add_child(slot_vbox)


# =========================================================
# SLOT CLICK → ENTER EDITOR
# =========================================================
func _on_slot_pressed(slot_index: int) -> void:
	var slot_path := SAVE_SLOTS[slot_index]
	print("📂 Selected slot:", slot_path)

	# Store chosen slot globally
	GlobalState.save_path = slot_path

	# Let the editor load itself in _ready()
	get_tree().change_scene_to_file(LEVEL_EDITOR_SCENE)

# =========================================================
# BACK BUTTON
# =========================================================
func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
