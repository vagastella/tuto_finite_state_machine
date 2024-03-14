class_name EnemyNoStateMachine

extends CharacterBody3D

@export var patrol_points: Array[Node3D]
@export var speed: float = 85
@export var run_speed: float = 200
@export var watch_time: float = 5

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var animation_state_machine: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
@onready var sight: Area3D = $Sight

var sighted_hero: Hero
var watch_time_left: float
var current_patrol_point: int

func _ready():
	sight.body_entered.connect(_on_body_entered)
	sight.body_exited.connect(_on_body_exited)
	
	_set_patrol_point(_get_nearest_patrol_point_index())
	
func _process(delta):
	var animation = "idle"
	if sighted_hero:
		navigation_agent.set_target_position(sighted_hero.global_position)
		move(true, delta)
		
		if get_real_velocity().length_squared() > 0.01:
			animation = "running"
		
	else:
		if watch_time_left > 0:
			watch_time_left -= delta
			if watch_time_left <= 0:
				_set_patrol_point(_next_patrol_point())
		else:
			if not navigation_agent.is_navigation_finished():
				_set_patrol_point(current_patrol_point)
				move(false, delta)
				animation = "walking"
			else:
				watch_time_left = watch_time
	
	animation_state_machine.travel(animation)
	
func _exit_tree():
	sight.body_exited.disconnect(_on_body_exited)
	sight.body_entered.disconnect(_on_body_entered)

func move(run, delta):
	var direction = (navigation_agent.get_next_path_position() - global_position).normalized()
	
	if direction != Vector3.ZERO:
		look_at(position + direction, Vector3.UP)
	
	if run:
		velocity = direction * run_speed * delta
	else:
		velocity = direction * speed * delta

	move_and_slide()

func _set_patrol_point(index):
	current_patrol_point = index
	navigation_agent.set_target_position(patrol_points[index].global_position)

func _next_patrol_point():
	return (current_patrol_point + 1) % patrol_points.size()

func _get_nearest_patrol_point_index():
	var index = 0
	var nearest_distance = Constants.INT32_MAX
	for i in patrol_points.size():
		var distance = (position - patrol_points[i].position).length_squared()
		if distance < nearest_distance:
			nearest_distance = distance
			index = i
		
	return index

func _on_body_entered(body: Node3D):
	if not body.name == Constants.HERO_NAME:
		return
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(position + basis.y, body.global_position + body.global_basis.y)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	
	if not result:
		return
	
	if result.collider.name == Constants.HERO_NAME:
		sighted_hero = body

func _on_body_exited(body: Node3D):
	if body.name != Constants.HERO_NAME:
		return
		
	sighted_hero = null
