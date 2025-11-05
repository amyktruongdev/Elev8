extends Control

# ====== DATA ======
var SPRITE_DATA := [
	{"name": "bearguy",    "tex": "res://sprites/bear.png"},
	{"name": "SlayyGirl",  "tex": "res://sprites/slaygirl.png"},
	{"name": "berryberry", "tex": "res://sprites/berryberry.png"},
]

var BLOCK_DATA := [
	{"name": "Brown Block", "tex": "res://sprites/brownblock.png"},
	{"name": "Rock",        "tex": "res://sprites/rockss.png"},
	{"name": "Water",       "tex": "res://sprites/waterblock.png"},
]

var PLATFORM_DATA := [
	{"name": "Grass", "tex": "res://sprites/grass.png"},
	{"name": "Stone", "tex": "res://sprites/rockblock.png"},
	{"name": "Red",   "tex": "res://sprites/redplatform.png"},
]

var ITEM_DATA := [
	{"name": "safe",   "tex": "res://sprites/safe.png"},
	{"name": "sword",  "tex": "res://sprites/sword.png"},
	{"name": "helmet", "tex": "res://sprites/helmet.png"},
]

var ENEMY_DATA := [
	{"name": "redbeast", "tex": "res://sprites/evilguy.png"},
	{"name": "robo",     "tex": "res://sprites/robo.png"},
]


# ====== NODES
@onready var sprite_btn    := $mainVbox/topbar/topbarhbox/sprite
@onready var blocks_btn    := $mainVbox/topbar/topbarhbox/blocks
@onready var platforms_btn := $mainVbox/topbar/topbarhbox/platforms
@onready var items_btn     := $mainVbox/topbar/topbarhbox/items
@onready var enemies_btn   := $mainVbox/topbar/topbarhbox/enemies

@onready var selector_bar  := $mainVbox/selectorbar
@onready var selector_list := $mainVbox/selectorbar/selectorScroll/selectList

var tab_buttons: Array[Button] = []


func _ready() -> void:
	print("✅ UI connected, starting...")

	# make sure bar exists
	if selector_bar == null:
		push_error("selectorbar NOT found at mainVbox/selectorbar")
		return
	if selector_list == null:
		push_error("selectList NOT found at mainVbox/selectorbar/selectorScroll/selectList")
		return

	selector_bar.visible = true
	selector_bar.custom_minimum_size = Vector2(0, 110)

	tab_buttons = [
		sprite_btn,
		blocks_btn,
		platforms_btn,
		items_btn,
		enemies_btn,
	]

	# connect top buttons
	sprite_btn.pressed.connect(func(): _on_tab_pressed("sprite", sprite_btn))
	blocks_btn.pressed.connect(func(): _on_tab_pressed("blocks", blocks_btn))
	platforms_btn.pressed.connect(func(): _on_tab_pressed("platforms", platforms_btn))
	items_btn.pressed.connect(func(): _on_tab_pressed("items", items_btn))
	enemies_btn.pressed.connect(func(): _on_tab_pressed("enemies", enemies_btn))

	# show first tab
	_on_tab_pressed("sprite", sprite_btn)


func _on_tab_pressed(tab: String, who: Button) -> void:
	# highlight current
	for b in tab_buttons:
		b.button_pressed = (b == who)

	match tab:
		"sprite":
			_build_selector_list(SPRITE_DATA)
		"blocks":
			_build_selector_list(BLOCK_DATA)
		"platforms":
			_build_selector_list(PLATFORM_DATA)
		"items":
			_build_selector_list(ITEM_DATA)
		"enemies":
			_build_selector_list(ENEMY_DATA)


func _build_selector_list(data_list: Array) -> void:
	# clear previous icons
	for c in selector_list.get_children():
		c.queue_free()

	for data in data_list:
		var tex_btn := TextureButton.new()
		tex_btn.custom_minimum_size = Vector2(96, 96)

		var tex := load(data["tex"]) as Texture2D
		if tex:
			tex_btn.texture_normal = tex
		else:
			print("⚠ Missing texture:", data["tex"])
			var fallback := Button.new()
			fallback.text = data["name"]
			fallback.custom_minimum_size = Vector2(96, 96)
			fallback.pressed.connect(Callable(self, "_on_sprite_chosen").bind(data["name"]))
			selector_list.add_child(fallback)
			continue

		tex_btn.tooltip_text = data["name"]
		tex_btn.pressed.connect(Callable(self, "_on_sprite_chosen").bind(data["name"]))
		selector_list.add_child(tex_btn)


func _on_sprite_chosen(sprite_name: String) -> void:
	print("🎨 You picked sprite:", sprite_name)
