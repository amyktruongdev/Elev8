extends Sprite2D

var dragging := false
var drag_offset := Vector2.ZERO

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and get_global_rect().has_point(event.position):
				dragging = true
				drag_offset = global_position - event.position
				get_viewport().set_input_as_handled()
			elif not event.pressed:
				dragging = false
	elif event is InputEventMouseMotion and dragging:
		global_position = event.position + drag_offset

func get_global_rect() -> Rect2:
	if texture:
		var size = texture.get_size() * scale
		return Rect2(global_position - size / 2.0, size)
	return Rect2(global_position, Vector2.ZERO)
