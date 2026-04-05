extends Control

var center_global : Vector2

func _on_开始_button_down() -> void:
	center_global = $"../主界面/开始".global_position + $"../主界面/开始".size / 2
	开始移动()
func _on_开始_button_up() -> void:
	center_global = $"../主界面/开始".global_position + $"../主界面/开始".size / 2
	开始移动()

func _on_设置_button_down() -> void:
	center_global = $"../主界面/设置".global_position + $"../主界面/设置".size / 2
	开始移动()
func _on_设置_button_up() -> void:
	center_global = $"../主界面/设置".global_position + $"../主界面/设置".size / 2
	开始移动()


func _on_退出_button_up() -> void:
	center_global = $"../主界面/退出".global_position + $"../主界面/退出".size / 2
	开始移动()
func _on_退出_button_down() -> void:
	center_global = $"../主界面/退出".global_position + $"../主界面/退出".size / 2
	开始移动()


func 开始移动 ():
	print("移动指针-中心点：", center_global)
