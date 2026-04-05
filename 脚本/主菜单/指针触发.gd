extends Control

@export var 开始按钮 : Button
@export var 设置按钮 : Button
@export var 退出按钮 : Button
@onready var 选择指针 = $"选择指针"

func _ready():
	开始按钮.mouse_entered.connect(_on_按钮鼠标进入.bind(开始按钮, 选择指针.状态.开始游戏))
	设置按钮.mouse_entered.connect(_on_按钮鼠标进入.bind(设置按钮, 选择指针.状态.设置))
	退出按钮.mouse_entered.connect(_on_按钮鼠标进入.bind(退出按钮, 选择指针.当前状态))

func _on_按钮鼠标进入(按钮: Button, 目标状态: int):
	var 中心 = 按钮.global_position + 按钮.size / 2
	选择指针.移动到(中心, 目标状态, 按钮.size)
