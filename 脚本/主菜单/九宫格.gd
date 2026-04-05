extends NinePatchRect

@onready var camera = get_node("../Camera2D")

func _on_开始_pressed() -> void:
	camera.change_state(camera.State.游戏存档)
func _on_开始_button_up() -> void:
	camera.change_state(camera.State.游戏存档)
	
func _on_设置_button_up() -> void:
	camera.change_state(camera.State.设置)
func _on_设置_pressed() -> void:
	camera.change_state(camera.State.设置)

func _on_退出_button_up() -> void:
	camera.change_state(camera.State.退出)
func _on_退出_pressed() -> void:
	camera.change_state(camera.State.退出)
