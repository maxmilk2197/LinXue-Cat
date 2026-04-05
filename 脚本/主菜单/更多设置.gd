extends Control
@onready var camera = get_node("../Camera2D")

func _process(delta: float) -> void:
	pass


func _on_设置_返回_pressed() -> void:
		camera.change_state(camera.State.设置)
