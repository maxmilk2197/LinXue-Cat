extends Control
@onready var camera = get_node("../Camera2D")

func _on_存档_返回_pressed() -> void:
		camera.change_state(camera.State.主菜单)
