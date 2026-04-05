extends NinePatchRect
@onready var camera = get_node("../../Camera2D")
func _ready() -> void:
	$"../../更多设置/更多设置_九宫格_音量".hide()
	$"../../更多设置/更多设置_九宫格_AI or Link".hide()
	$"../../更多设置/更多设置_九宫格_关于".hide()
	$"../../更多设置/测试选项".hide()

func _on_音量设置_pressed() -> void:
	$"../../更多设置/更多设置_九宫格_音量".show()
	$"../../更多设置/更多设置_九宫格_AI or Link".hide()
	$"../../更多设置/更多设置_九宫格_关于".hide()
	$"../../更多设置/测试选项".hide()
	camera.change_state(camera.State.更多设置)


func _on_ai_or_link_设置_pressed() -> void:
	$"../../更多设置/更多设置_九宫格_音量".hide()
	$"../../更多设置/更多设置_九宫格_AI or Link".show()
	$"../../更多设置/更多设置_九宫格_关于".hide()
	$"../../更多设置/测试选项".hide()
	camera.change_state(camera.State.更多设置)


func _on_关于_pressed() -> void:
	$"../../更多设置/更多设置_九宫格_音量".hide()
	$"../../更多设置/更多设置_九宫格_AI or Link".hide()
	$"../../更多设置/更多设置_九宫格_关于".show()
	$"../../更多设置/测试选项".hide()
	camera.change_state(camera.State.更多设置)


func _on_测试选项_pressed() -> void:
	$"../../更多设置/更多设置_九宫格_音量".hide()
	$"../../更多设置/更多设置_九宫格_AI or Link".hide()
	$"../../更多设置/更多设置_九宫格_关于".hide()
	$"../../更多设置/测试选项".show()
	camera.change_state(camera.State.更多设置) 
