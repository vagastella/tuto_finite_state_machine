class_name PlayerCamera

extends SpringArm3D

const MIN_X_ROTATION = -Constants.HALF_PI + Constants.SIXTH_PI
const MAX_X_ROTATION = Constants.SIXTH_PI * 0.9
const MAX_ZOOM = 4
const MIN_ZOOM = 2

@export var orbit_sensitivity: float = 1
@export var zoom_sensitivity: float = 5
@export var zoom_damp: float = 0.9
@export var follow_speed: float = 7
@export var target: Node3D

var mouse_motion_event
var zoom_direction

func _ready():
	mouse_motion_event = Vector2.ZERO
	zoom_direction = 0

func _input(event):
	if event is InputEventMouseMotion:
		mouse_motion_event = event.relative * orbit_sensitivity

func _physics_process(delta):
	zoom(delta)
	orbit(delta)
	follow(delta)

func zoom(delta):
	if Input.is_action_just_released(Constants.MOUSE_WHEEL_UP):
		zoom_direction = -zoom_sensitivity
	if Input.is_action_just_released(Constants.MOUSE_WHEEL_DOWN):
		zoom_direction = zoom_sensitivity
		
	if zoom_direction == 0:
		return
		
	spring_length = clamp(spring_length + zoom_direction * delta, MIN_ZOOM, MAX_ZOOM)
	
	zoom_direction *= zoom_damp
	if abs(zoom_direction) < Constants.EPSILON:
		zoom_direction = 0

func orbit(delta):
	if mouse_motion_event == Vector2.ZERO:
		return
	
	rotation.x -= mouse_motion_event.y * delta
	rotation.x = clamp(rotation.x, MIN_X_ROTATION, MAX_X_ROTATION)
	
	rotation.y -= mouse_motion_event.x * delta
	
	mouse_motion_event = Vector2.ZERO

func follow(delta):
	position = position.lerp(target.global_position, delta * follow_speed)
