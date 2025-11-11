extends Control

# =========================================================
# 1. DATA FOR SELECTOR TABS
# =========================================================
var SPRITE_DATA := [
	{"name": "Rootguy",    "tex": "res://sprites/rootguy.png"},
	{"name": "bearguy",    "tex": "res://sprites/bear.png"},
	{"name": "SlayyGirl",  "tex": "res://sprites/slaygirl.png"},
	{"name": "berryberry", "tex": "res://sprites/berryberry.png"},
]

var BLOCK_DATA := [
	{"name": "Brown Block", "tex": "res://sprites/brownblock.png"},
	{"name": "Rock",        "tex": "res://sprites/rockss.png"},
	{"name": "Water",       "tex": "res://sprites/waterblock.png"},
	{"name": "Tree",       "tex": "res://sprites/tree.png"},
]

var PLATFORM_DATA := [
	{"name": "Grass", "tex": "res://sprites/grass.png"},
	{"name": "Stone", "tex": "res://sprites/rockblock.png"},
	{"name": "Red",   "tex": "res://sprites/redplatform.png"},
	{"name": "Green",    "tex": "res://sprites/greenplatform.png"}
]

var ITEM_DATA := [
	{"name": "Coin",   "tex": "res://sprites/safe.png"},
	{"name": "Gun",    "tex": "res://sprites/gun.png"},
	{"name": "Sword",  "tex": "res://sprites/sword.png"},
	{"name": "Helmet", "tex": "res://sprites/helmet.png"},
]

var ENEMY_DATA := [
	{"name": "Spider",    "tex": "res://sprites/Spider.png"},
	{"name": "Redbeast", "tex": "res://sprites/evilguy.png"},
	{"name": "Robo",     "tex": "res://sprites/Robo.png"}, # your FS had capital R
]

# =========================================================
# 2. STATE TO REMEMBER
# =========================================================
var current_bg_path: String = ""
var current_music_path: String = ""
var current_bg_color: Color = Color.WHITE

var last_selected_name: String = ""
var last_selected_tex: Texture2D = null

# everything we DROP into workspace goes here so we can undo/clear
var placed_nodes: Array[Node] = []

# change these to your real files
const RED_FLAG_TEX  := "res://redflag.png"
const GOAL_FLAG_TEX := "res://checkeredflag.png"

# toast ui
var toast_label: Label
var toast_timer: Timer

# =========================================================
# 3. NODES (WITH mainVbox)
# =========================================================
# topbar
@export var SAVE_PATH: String = "user://saved_level.json"
@onready var sprite_btn     = $mainVbox/topbar/topbarhbox/sprite
@onready var blocks_btn     = $mainVbox/topbar/topbarhbox/blocks
@onready var platforms_btn  = $mainVbox/topbar/topbarhbox/platforms
@onready var items_btn      = $mainVbox/topbar/topbarhbox/items
@onready var enemies_btn    = $mainVbox/topbar/topbarhbox/enemies

# selector
@onready var selector_bar   = $mainVbox/selectorbar
@onready var selector_list  = $mainVbox/selectorbar/selectorScroll/selectList

# tool panel + workspace
@onready var image_btn      = $mainVbox/HSplitContainer/toolpanel/imageRow/imagebtn
@onready var image_options  = $mainVbox/HSplitContainer/toolpanel/imageRow/imageoptions

@onready var music_btn      = $mainVbox/HSplitContainer/toolpanel/musicRow/musicbtn
@onready var music_options  = $mainVbox/HSplitContainer/toolpanel/musicRow/musicoptions

@onready var redflag_btn    = $mainVbox/HSplitContainer/toolpanel/redflag
@onready var finish_btn     = $mainVbox/HSplitContainer/toolpanel/finishbtn

@onready var workspace      = $mainVbox/HSplitContainer/workspace

# bottom bar (guarded)
@onready var undo_btn       = get_node_or_null("mainVbox/bottombar/bottomhbox/undo")
@onready var clear_btn      = get_node_or_null("mainVbox/bottombar/bottomhbox/clear")

# dialogs at root
@onready var image_dialog   = $imagedialog
@onready var music_dialog   = $musicdialog
#@onready var color_picker   = $ColorPicker

@onready var save_btn = get_node_or_null("mainVbox/bottombar/bottomhbox/save")
@onready var load_btn = get_node_or_null("mainVbox/bottombar/bottomhbox/load")
@onready var back_btn = $mainVbox/topbar/topbarhbox/backbtn
@onready var sprite_layer: Node2D = $mainVbox/HSplitContainer/workspace/SpriteLayer

# we’ll grab these in _ready()
var image_upload_btn: TextureButton
var image_color_btn:  TextureButton
var music_upload_btn: TextureButton

# runtime nodes
var tab_buttons: Array[Button] = []
var bg_sprite: Sprite2D
var music_player: AudioStreamPlayer


func _ready() -> void:
	print("✅ UI ready (with mainVbox)")
	#make workspace pass mouse to children so sprite2d
	workspace.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# build toast ui (non-blocking message)
	_build_toast_ui()
	_show_hint("Show your creative side ✨")

	# selector visible
	selector_bar.visible = true
	selector_bar.custom_minimum_size = Vector2(0, 110)

	# collect top buttons
	tab_buttons = [
		sprite_btn,
		blocks_btn,
		platforms_btn,
		items_btn,
		enemies_btn,
	]

	# connect topbar
	sprite_btn.pressed.connect(func(): _on_tab_pressed("sprite", sprite_btn))
	blocks_btn.pressed.connect(func(): _on_tab_pressed("blocks", blocks_btn))
	platforms_btn.pressed.connect(func(): _on_tab_pressed("platforms", platforms_btn))
	items_btn.pressed.connect(func(): _on_tab_pressed("items", items_btn))
	enemies_btn.pressed.connect(func(): _on_tab_pressed("enemies", enemies_btn))

	# start tool rows hidden
	image_options.visible = false
	music_options.visible = false
	#color_picker.visible = false

	# tooltips on tool panel
	image_btn.tooltip_text = "Select a background image"
	music_btn.tooltip_text = "Select background music"
	redflag_btn.tooltip_text = "Place a checkpoint flag"
	finish_btn.tooltip_text = "Place the goal flag"

	# connect main tool buttons
	image_btn.pressed.connect(_on_image_tool_pressed)
	music_btn.pressed.connect(_on_music_tool_pressed)
	redflag_btn.pressed.connect(_on_red_flag_pressed)
	finish_btn.pressed.connect(_on_goal_flag_pressed)
	back_btn.pressed.connect(_on_back_pressed)

	# bottom bar
	if undo_btn:
		undo_btn.pressed.connect(_on_undo_pressed)
	if clear_btn:
		clear_btn.pressed.connect(_on_clear_pressed)

	# grab mini buttons
	image_upload_btn = get_node_or_null("mainVbox/HSplitContainer/toolpanel/imageRow/imageoptions/uploadBtn")
	image_color_btn  = get_node_or_null("mainVbox/HSplitContainer/toolpanel/imageRow/imageoptions/colorBtn")
	music_upload_btn = get_node_or_null("mainVbox/HSplitContainer/toolpanel/musicRow/musicoptions/musicUploadBtn")

	if image_upload_btn:
		image_upload_btn.pressed.connect(_on_image_upload_pressed)
	else:
		print("⚠ uploadBtn not found under imageoptions")

	# music: if no dedicated upload button, make all buttons in music row open the dialog
	if music_upload_btn:
		music_upload_btn.pressed.connect(_on_music_upload_pressed)
	else:
		print("⚠ musicUploadBtn not found – using all children as upload buttons")
		for child in music_options.get_children():
			if child is BaseButton:
				child.pressed.connect(_on_music_upload_pressed)

	# dialogs
	image_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	image_dialog.filters = ["*.png ; PNG", "*.jpg ; JPG", "*.jpeg ; JPEG", "*.webp ; WEBP"]
	image_dialog.file_selected.connect(_on_image_selected)

	music_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	music_dialog.filters = ["*.mp3 ; MP3", "*.wav ; WAV", "*.ogg ; OGG"]
	music_dialog.file_selected.connect(_on_music_selected)

	#color_picker.color_changed.connect(_on_color_picked)

	# runtime nodes
	bg_sprite = Sprite2D.new()
	workspace.add_child(bg_sprite)

	music_player = AudioStreamPlayer.new()
	add_child(music_player)

	# show first tab
	_on_tab_pressed("sprite", sprite_btn)

	# ✅ Add this here — load the save path from global state
	if GlobalState.save_path != "":
		SAVE_PATH = GlobalState.save_path
	else:
		SAVE_PATH = "user://saved_level.json"

	print("💾 Active SAVE_PATH on editor open:", SAVE_PATH)

	# finally, connect save button
	if save_btn:
		save_btn.pressed.connect(_on_save_pressed)

# =========================================================
# TOP TABS
# =========================================================
func _on_tab_pressed(tab: String, who: Button) -> void:
	for b in tab_buttons:
		b.button_pressed = (b == who)

	match tab:
		"sprite":
			_build_selector_list(SPRITE_DATA)
			_show_hint("Choose your character / sprite!")
		"blocks":
			_build_selector_list(BLOCK_DATA)
			_show_hint("Add ground or obstacles.")
		"platforms":
			_build_selector_list(PLATFORM_DATA)
			_show_hint("Floating platforms for your level.")
		"items":
			_build_selector_list(ITEM_DATA)
			_show_hint("Drop in items or collectibles.")
		"enemies":
			_build_selector_list(ENEMY_DATA)
			_show_hint("Pick an enemy for the player.")

func _build_selector_list(data_list: Array) -> void:
	for c in selector_list.get_children():
		c.queue_free()

	for data in data_list:
		var tex_btn := TextureButton.new()
		tex_btn.custom_minimum_size = Vector2(96, 96)

		var tex := load(data["tex"]) as Texture2D
		if tex:
			tex_btn.texture_normal = tex
		else:
			var fb := Button.new()
			fb.text = data["name"]
			fb.custom_minimum_size = Vector2(96, 96)
			fb.pressed.connect(Callable(self, "_on_selector_item_pressed").bind(data["name"]))
			selector_list.add_child(fb)
			continue

		tex_btn.tooltip_text = data["name"]
		tex_btn.pressed.connect(Callable(self, "_on_selector_item_pressed").bind(data["name"]))
		selector_list.add_child(tex_btn)

# user clicked an item in the selector → spawn and make draggable
func _on_selector_item_pressed(item_name: String) -> void:
	var tex := _get_texture_for_item(item_name)
	if tex == null:
		print("⚠ couldn't find texture for:", item_name)
		return

	last_selected_name = item_name
	last_selected_tex = tex

	var spr := _spawn_draggable_sprite(tex, workspace.size / 2)
	placed_nodes.append(spr)

	_show_hint("Placed: %s" % item_name, 1.6)


# =========================================================
# TOOL PANEL
# =========================================================
func _on_image_tool_pressed() -> void:
	image_options.visible = true
	music_options.visible = false
	#color_picker.visible = false
	_show_hint("Select a background image", 1.6)

func _on_music_tool_pressed() -> void:
	music_options.visible = true
	image_options.visible = false
	#color_picker.visible = false
	_show_hint("Select background music", 1.6)

func _on_image_upload_pressed() -> void:
	image_dialog.popup_centered()

func _on_music_upload_pressed() -> void:
	music_dialog.popup_centered()

func _on_image_selected(path: String) -> void:
	var tex := load(path)
	if tex:
		bg_sprite.texture = tex
		bg_sprite.position = workspace.size / 2
		current_bg_path = path

		# make background draggable too ✅
		var drag_script := load("res://DraggableSprite2D.gd")
		bg_sprite.set_script(drag_script)

		_show_hint("Background updated!", 1.4)

func _on_music_selected(path: String) -> void:
	var stream := load(path)
	if stream:
		music_player.stream = stream
		music_player.play()
		current_music_path = path
		_show_hint("Music changed 🎵", 1.4)

func _on_color_picked(color: Color) -> void:
	workspace.modulate = color
	current_bg_color = color


func _on_red_flag_pressed() -> void:
	var flag_tex := load(RED_FLAG_TEX)
	if flag_tex:
		var sp := _spawn_draggable_sprite(flag_tex, workspace.size / 2)
		placed_nodes.append(sp)
		_show_hint("Checkpoint flag placed", 1.4)
	else:
		print("⚠ red flag texture not found at:", RED_FLAG_TEX)

func _on_goal_flag_pressed() -> void:
	var flag_tex := load(GOAL_FLAG_TEX)
	if flag_tex:
		var sp := _spawn_draggable_sprite(flag_tex, workspace.size / 2 + Vector2(64, 0))
		placed_nodes.append(sp)
		_show_hint("Goal flag placed", 1.4)
	else:
		print("⚠ goal flag texture not found at:", GOAL_FLAG_TEX)


# =========================================================
# UNDO / CLEAR
# =========================================================
func _on_undo_pressed() -> void:
	if placed_nodes.size() == 0:
		return
	var last: Node = placed_nodes.pop_back()
	if is_instance_valid(last):
		last.queue_free()
		_show_hint("Undo", 1.0)

func _on_clear_pressed() -> void:
	for n in placed_nodes:
		if is_instance_valid(n):
			n.queue_free()
	placed_nodes.clear()

	# also clear the background image
	bg_sprite.texture = null
	workspace.modulate = Color.WHITE
	current_bg_path = ""
	current_bg_color = Color.WHITE

	_show_hint("Workspace cleared", 1.4)


# =========================================================
# HELPERS
# =========================================================
func _build_toast_ui() -> void:
	toast_label = Label.new()
	toast_label.text = ""
	toast_label.modulate.a = 0.0
	toast_label.add_theme_color_override("font_color", Color.BLACK)
	toast_label.add_theme_color_override("font_outline_color", Color.WHITE)
	toast_label.add_theme_constant_override("outline_size", 2)
	toast_label.autowrap_mode = TextServer.AUTOWRAP_WORD

	# ⬇️ place near top, centered
	toast_label.anchor_left = 0.5
	toast_label.anchor_right = 0.5
	toast_label.anchor_top = 0.0
	toast_label.anchor_bottom = 0.0
	toast_label.offset_left = -220
	toast_label.offset_right = 220
	toast_label.offset_top = 50   # a little below the blue tab bar
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# make sure it's above other stuff
	toast_label.z_index = 999

	add_child(toast_label)

	toast_timer = Timer.new()
	toast_timer.one_shot = true
	toast_timer.wait_time = 2.2
	toast_timer.timeout.connect(func():
		toast_label.modulate.a = 0.0
	)
	add_child(toast_timer)


func _show_hint(text: String, duration: float = 2.2) -> void:
	toast_label.text = text
	toast_label.modulate.a = 1.0
	toast_timer.stop()
	toast_timer.wait_time = duration
	toast_timer.start()

# renamed param so it doesn’t shadow Node.name
func _get_texture_for_item(item_name: String) -> Texture2D:
	for data in SPRITE_DATA:
		if data["name"] == item_name:
			return load(data["tex"])
	for data in BLOCK_DATA:
		if data["name"] == item_name:
			return load(data["tex"])
	for data in PLATFORM_DATA:
		if data["name"] == item_name:
			return load(data["tex"])
	for data in ITEM_DATA:
		if data["name"] == item_name:
			return load(data["tex"])
	for data in ENEMY_DATA:
		if data["name"] == item_name:
			return load(data["tex"])
	return null

# spawn + make draggable, return the node
func _spawn_draggable_sprite(tex: Texture2D, pos: Vector2) -> Sprite2D:
	var spr := Sprite2D.new()
	spr.texture = tex
	spr.position = pos
	spr.z_index = 10  # ensures it draws above the background

	var drag_script := load("res://DraggableSprite2D.gd")
	spr.set_script(drag_script)

	sprite_layer.add_child(spr)  # ✅ attach to Node2D layer, not Control
	return spr
# =========================================================
# SAVE / LOAD SYSTEM (Strict-Typed for Godot 4.5)
# =========================================================

# Default save path (can be replaced by LevelSelector)


func set_save_path(new_path: String) -> void:
	SAVE_PATH = new_path
	print("💾 [Editor] Save path set to:", SAVE_PATH)

func get_save_path() -> String:
	return SAVE_PATH

# Convert placed_nodes into savable dictionaries
func _serialize_level() -> Array[Dictionary]:
	var data: Array[Dictionary] = []
	for node: Node in placed_nodes:
		if not (node is Sprite2D):
			continue
		var sprite: Sprite2D = node
		var tex_path: String = ""
		if sprite.texture != null and sprite.texture.resource_path != "":
			tex_path = sprite.texture.resource_path
		data.append({
			"texture": tex_path,
			"position": {"x": sprite.global_position.x, "y": sprite.global_position.y}
		})
	return data


func _on_save_pressed() -> void:
	var level_data: Dictionary = {
		"background": current_bg_path,
		"music": current_music_path,
		"objects": _serialize_level()
	}

	print("🧠 Current SAVE_PATH before writing:", SAVE_PATH)

	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		_show_hint("⚠ Failed to save level!", 1.8)
		return

	var json_text := JSON.stringify(level_data, "\t")
	print("📁 Saving level to:", SAVE_PATH)
	print("🧾 Data:", json_text)

	file.store_string(json_text)
	file.close()
	_show_hint("Level saved locally ✅", 1.8)

func _on_load_pressed() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		_show_hint("⚠ No saved level found!", 1.8)
		return

	print("📂 Loading saved level directly in editor...")
	load_level_from_file(SAVE_PATH)
	_show_hint("Level loaded 🎮", 1.8)

# =========================================================
# EXTERNAL LOAD ENTRYPOINT (used by Main Menu)
# =========================================================
func load_level_from_file(path: String = "user://saved_level.json") -> void:
	if not FileAccess.file_exists(path):
		_show_hint("⚠ No saved level found!", 1.8)
		return

	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		_show_hint("⚠ Unable to open save file!", 1.8)
		return

	var text: String = file.get_as_text()
	file.close()

	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		_show_hint("⚠ Invalid save format", 1.8)
		return

	var data: Dictionary = parsed
	_on_clear_pressed()

	# Restore background
	if data.has("background") and data["background"] != "":
		var bg: Texture2D = load(data["background"])
		if bg != null:
			bg_sprite.texture = bg
			current_bg_path = data["background"]

	# Restore music
	if data.has("music") and data["music"] != "":
		var music: AudioStream = load(data["music"])
		if music != null:
			music_player.stream = music
			music_player.play()
			current_music_path = data["music"]

	if data.has("objects"):
		var objs: Array = data["objects"]
		for obj: Variant in objs:
			if typeof(obj) == TYPE_DICTIONARY:
				var d: Dictionary = obj
				if d.has("texture") and d["texture"] != "":
					var tex: Texture2D = load(d["texture"])
					if tex != null and d.has("position"):
						var pos_dict: Dictionary = d["position"]
						var pos := Vector2(float(pos_dict["x"]), float(pos_dict["y"]))  # ✅ convert properly
						var spr: Sprite2D = _spawn_draggable_sprite(tex, pos)
						spr.global_position = pos   # ensures exact placement
						placed_nodes.append(spr)

	_show_hint("Level loaded from Main Menu 🎮", 1.8)
	
func _on_back_pressed() -> void:
	_show_hint("Returning to Main Menu...", 1.0)
	await get_tree().create_timer(1.0).timeout  # short delay so hint can show
	get_tree().change_scene_to_file("res://MainMenu.tscn")  # ✅ use your main menu path
