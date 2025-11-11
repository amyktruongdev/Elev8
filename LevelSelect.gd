extends Control

# =========================================================
# Level Select Screen – Uses the editor’s own save/load system
# =========================================================
const LEVEL_EDITOR_SCENE := "res://control.tscn"
const MAIN_MENU_SCENE := "res://MainMenu.tscn"

# Three slots to represent separate save files
const SAVE_SLOTS: Array[String] = [
	"user://level_slot_1.json",
	"user://level_slot_2.json",
	"user://level_slot_3.json"
]

@onready var grid: GridContainer = $MainVBox/GridContainer
@onready var title_label: Label = $MainVBox/Title
@onready var back_btn: Button = $MainVBox/BackButton

func _ready() -> void:
	title_label.text = "Select Level to Load"
	title_label.add_theme_color_override("font_color", Color.BLACK)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_populate_slots()
	back_btn.pressed.connect(_on_back_pressed)


# =========================================================
# SLOT SETUP
# =========================================================
func _populate_slots() -> void:
	for c in grid.get_children():
		c.queue_free()

	for i in range(SAVE_SLOTS.size()):
		var slot_path: String = SAVE_SLOTS[i]
		var slot_vbox := VBoxContainer.new()
		slot_vbox.alignment = BoxContainer.ALIGNMENT_CENTER

		var preview := TextureRect.new()
		preview.custom_minimum_size = Vector2(280, 160)
		preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

		var label := Label.new()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

		if FileAccess.file_exists(slot_path):
			preview.texture = load("res://sprites/Robo.png")
			label.text = "Saved Level %d" % (i + 1)
		else:
			preview.texture = load("res://sprites/rootguy.png")
			label.text = "Empty Slot %d" % (i + 1)

		var btn := Button.new()
		btn.text = "Load" if FileAccess.file_exists(slot_path) else "New"
		btn.custom_minimum_size = Vector2(180, 40)
		btn.pressed.connect(func(): _on_slot_pressed(i))

		slot_vbox.add_child(preview)
		slot_vbox.add_child(label)
		slot_vbox.add_child(btn)
		grid.add_child(slot_vbox)


# =========================================================
# OPEN SLOT → ENTER EDITOR
# =========================================================
func _on_slot_pressed(slot_index: int) -> void:
	var slot_path: String = SAVE_SLOTS[slot_index]
	print("📂 Opening slot:", slot_path)

	# ✅ tell the global autoload which slot we’re using
	if Engine.has_singleton("GlobalState"):
		GlobalState.save_path = slot_path
	else:
		print("⚠ GlobalState autoload not found!")

	var editor_scene := load(LEVEL_EDITOR_SCENE)
	if editor_scene == null:
		push_error("❌ Could not load Level Editor scene!")
		return

	var editor_instance = editor_scene.instantiate()
	get_tree().root.add_child(editor_instance)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = editor_instance

	await get_tree().process_frame

	if editor_instance.has_method("set_save_path"):
		editor_instance.call("set_save_path", slot_path)
	if editor_instance.has_method("load_level_from_file"):
		editor_instance.call("load_level_from_file", slot_path)

# =========================================================
# BACK BUTTON
# =========================================================
func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
