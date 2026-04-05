extends Control
@onready var camera = get_node("../Camera2D")



func _on_退出_返回_pressed() -> void:
	camera.change_state(camera.State.主菜单)


func _on_退出_确认_pressed() -> void:
	var color_rect = $ColorRect
	color_rect.modulate = Color(0,0,0,0)   # 纯黑透明
	color_rect.show()
	var tween = create_tween().bind_node(color_rect)
	tween.tween_property(color_rect, "modulate", Color.BLACK, 0.2)
	await tween.finished
	get_tree().quit()
