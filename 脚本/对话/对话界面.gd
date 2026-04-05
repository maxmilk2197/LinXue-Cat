extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var color_rect = $ColorRect
	color_rect.modulate = Color.BLACK
	color_rect.show()           # 确保可见
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate", Color(0, 0, 0, 0), 0.2)
	await tween.finished
	color_rect.hide()
func _process(delta: float) -> void:
	pass
