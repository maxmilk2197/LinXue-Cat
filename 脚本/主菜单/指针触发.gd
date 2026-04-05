extends Control

@export var 开始按钮 : Button
@export var 设置按钮 : Button
@export var 退出按钮 : Button
@onready var 选择指针 = $"选择指针"

func _ready():
	开始按钮.mouse_entered.connect(_on_button_mouse_entered.bind(开始按钮, 选择指针.State.开始游戏))
	设置按钮.mouse_entered.connect(_on_button_mouse_entered.bind(设置按钮, 选择指针.State.设置))
	退出按钮.mouse_entered.connect(_on_button_mouse_entered.bind(退出按钮, 选择指针.current_state))

func _on_button_mouse_entered(btn: Button, target_state: int):
	var center = btn.global_position + btn.size / 2
	选择指针.move_to(center, target_state)
