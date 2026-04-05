extends NinePatchRect
@export var API密钥 : LineEdit
@export var AI模型 : LineEdit
@export var API地址 : LineEdit

func _ready():
	var config = ConfigFile.new()
	var result = config.load("user://config.cfg")
	if result == OK :
		API密钥.text = config.get_value("AI设置","API密钥")
		AI模型.text = config.get_value("AI设置","AI模型")
		API地址.text = config.get_value("AI设置","API地址")
	else:
		printerr("AI配置读取错误")

func _on_设置_返回_pressed() -> void:
	if visible:
		var config = ConfigFile.new()
		config.set_value("AI设置","API密钥",API密钥.text)
		config.set_value("AI设置","AI模型",AI模型.text)
		config.set_value("AI设置","API地址",API地址.text)
		config.save("user://config.cfg")
		print("成功保存AI配置")
