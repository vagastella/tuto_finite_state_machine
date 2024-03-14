extends Node

@onready var inhabitant: Enemy = $Enemy

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(_event):
	if Input.is_action_pressed(Constants.QUIT):
		get_tree().quit()
