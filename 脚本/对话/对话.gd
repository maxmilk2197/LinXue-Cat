extends Control
@export var system_content: String = "你是一只可爱的小猫娘，但说话时不用使用表情包"
# ==================== 节点引用 ====================
@onready var camera = get_node("../Camera2D")
@onready var 输入 = $"输入"
@onready var 对话列表 = $"../更多信息/历史对话"
@onready var 对话回复 = $"对话"          # 假设这是一个 Label 或 RichTextLabel
@onready var http_request = $HTTPRequest
@onready var error_dialog = $AcceptDialog

# ==================== 内部状态 ====================
var _config = {}                # 缓存配置
var _is_waiting = false         # 是否正在等待AI回复
var _temp_item_index = -1       # 临时“正在输入”条目的索引

func _ready():
	# 连接信号
	http_request.request_completed.connect(_on_request_completed)
	# 设置超时（秒）
	http_request.timeout = 15

# 加载配置文件到 _config
func _load_config():
	var config = ConfigFile.new()
	var err = config.load("user://config.cfg")
	if err != OK:
		_config = {}  # 清空表示无效
		return
	_config = {
		"api_key": config.get_value("AI设置","API密钥", ""),
		"model": config.get_value("AI设置","AI模型", "deepseek-chat"),
		"base_url": config.get_value("AI设置","API地址", "https://api.deepseek.com/v1/chat/completions")
	}


func send_to_ai(prompt: String):
	# 再次检查等待状态（安全起见）
	if _is_waiting:
		return

	# 检查配置是否有效
	if _config.is_empty() or _config.get("api_key", "") == "":
		# 尝试重新加载配置（可能用户刚创建了文件）
		_load_config()
		if _config.is_empty() or _config.get("api_key", "") == "":
			_show_error("未找到有效的API配置，请先在设置界面配置 user://config.cfg 文件。")
			return


	# 添加临时“正在输入”提示，并记录索引
	对话列表.add_item("猫娘" + "：正在输入...")
	_temp_item_index = 对话列表.item_count - 1

	# 更新UI状态：禁用输入框，标记等待
	输入.editable = false
	_is_waiting = true

	# 动态构建系统提示词
	var system_prompt = system_content

	# 构建请求头
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + _config["api_key"]
	]

	# 构建请求体
	var body = JSON.stringify({
		"model": _config["model"],
		"messages": [
			{"role": "system", "content": system_content},
			{"role": "user", "content": prompt}
		],
		"stream": false
	})

	# 发送POST请求
	var error = http_request.request(_config["base_url"], headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		# 请求发送失败，恢复UI并移除临时条目
		_is_waiting = false
		输入.editable = true
		if _temp_item_index != -1:
			对话列表.remove_item(_temp_item_index)
			_temp_item_index = -1
		_show_error("请求发送失败，错误码：" + str(error))

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	# 无论结果如何，先恢复UI
	_is_waiting = false
	输入.editable = true

	# 移除临时“正在输入”条目
	if _temp_item_index != -1:
		对话列表.remove_item(_temp_item_index)
		_temp_item_index = -1

	# 检查网络请求是否成功
	if result != HTTPRequest.RESULT_SUCCESS:
		var msg = _get_friendly_error(result)
		对话列表.add_item("[系统] " + msg)
		_show_error(msg)
		return

	# 检查HTTP状态码
	if response_code != 200:
		var error_body = body.get_string_from_utf8()
		var msg = _get_http_error_message(response_code, error_body)
		对话列表.add_item("[系统] " + msg)
		_show_error(msg)
		return

	# 解析JSON响应
	var response_body = body.get_string_from_utf8()
	var json = JSON.new()
	var parse_result = json.parse(response_body)
	if parse_result != OK:
		var msg = "无法解析API返回的数据。"
		对话列表.add_item("[系统] " + msg)
		_show_error(msg)
		return

	var data = json.data
	# 安全提取AI回复
	var ai_message = _extract_ai_message(data)
	if ai_message != null:
		对话列表.add_item("猫娘" + "：" + ai_message)
		# ===== 新增：将最新回复显示到对话回复控件 =====
		if 对话回复:
			对话回复.text = ai_message
	else:
		var msg = "API返回格式异常，缺少预期字段。"
		对话列表.add_item("[系统] " + msg)
		_show_error(msg)

# 从解析后的数据中安全提取AI消息，返回 String 或 null
func _extract_ai_message(data) -> Variant:
	if typeof(data) != TYPE_DICTIONARY:
		return null
	if not data.has("choices") or not (data.choices is Array):
		return null
	if data.choices.size() == 0:
		return null
	var choice = data.choices[0]
	if typeof(choice) != TYPE_DICTIONARY:
		return null
	if not choice.has("message") or typeof(choice.message) != TYPE_DICTIONARY:
		return null
	if not choice.message.has("content") or typeof(choice.message.content) != TYPE_STRING:
		return null
	return choice.message.content

# 显示错误弹窗（避免重复弹出）
func _show_error(message: String):
	if error_dialog and is_instance_valid(error_dialog):
		# 如果弹窗已经可见，直接更新文本并保持打开
		if error_dialog.visible:
			error_dialog.dialog_text = message
		else:
			error_dialog.dialog_text = message
			error_dialog.popup_centered()

# 将HTTPRequest的错误码转换为友好消息
func _get_friendly_error(result: int) -> String:
	match result:
		HTTPRequest.RESULT_TIMEOUT:
			return "请求超时，请检查网络后重试。"
		HTTPRequest.RESULT_CONNECTION_ERROR:
			return "网络连接错误，请检查网络。"
		HTTPRequest.RESULT_TLS_HANDSHAKE_ERROR:
			return "TLS/SSL握手失败，可能是服务器证书问题。"
		_:
			return "网络请求失败，错误码：" + str(result)

# 将HTTP状态码转换为友好消息
func _get_http_error_message(code: int, body: String) -> String:
	match code:
		401:
			return "API密钥无效或已过期，请检查配置。"
		403:
			return "禁止访问，请检查API权限。"
		404:
			return "API地址不存在，请检查配置中的URL。"
		429:
			return "请求过于频繁，请稍后再试。"
		500, 502, 503, 504:
			return "服务器暂时不可用，请稍后重试。"
		_:
			return "API返回错误 (代码 " + str(code) + ")：\n" + body


func _on_输入_text_submitted(new_text: String):
	if _is_waiting:
		error_dialog.dialog_text = "正在处理上一个请求，请稍候..."
		error_dialog.popup_centered()
		return

	# 显示用户输入
	对话列表.add_item("你：" + new_text)
	输入.clear()
	# 发送给AI
	send_to_ai(new_text)


func _on_更多_pressed() -> void:
	camera.change_state(camera.State.更多信息)
