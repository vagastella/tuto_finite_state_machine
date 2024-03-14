class_name Hero

extends CharacterBody3D

@export var speed: float = 85
@export var run_speed: float = 300
@export var camera: PlayerCamera

@onready var animation_state_machine: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]

func _physics_process(delta):
	var direction = Vector3.ZERO;
	
	if Input.is_action_pressed(Constants.MOVE_FORWARD):
		direction.z -= 1
	if Input.is_action_pressed(Constants.MOVE_BACKWARD):
		direction.z += 1
	if Input.is_action_pressed(Constants.MOVE_RIGHT):
		direction.x += 1
	if Input.is_action_pressed(Constants.MOVE_LEFT):
		direction.x -= 1
		
	var running = Input.is_action_pressed(Constants.RUN)
		
	direction = direction.rotated(Vector3.UP, camera.rotation.y).normalized()
	
	if running:
		velocity = direction * run_speed * delta
	else:
		velocity = direction * speed * delta
	
	if direction != Vector3.ZERO:
		look_at(position + direction, Vector3.UP)
		
	move_and_slide()
	
	if get_real_velocity().length() > 0:
		if running:
			animation_state_machine.travel("running")
		else:
			animation_state_machine.travel("walking")
	else:
		animation_state_machine.travel("idle")
