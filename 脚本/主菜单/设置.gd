extends Control
@onready var camera = get_node("../Camera2D")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_设置_返回_pressed() -> void:
		camera.change_state(camera.State.主菜单)
