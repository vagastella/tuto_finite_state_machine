class_name PatrolState

extends State

var enemy: Enemy
var patrol_points: Array[Node3D]
var current_patrol_point: int
var continue_patrol: bool

func _init(_enemy: Enemy, _patrol_points: Array[Node3D]):
	enemy = _enemy
	patrol_points = _patrol_points

func enter():
	if continue_patrol:
		_set_patrol_point(_next_patrol_point())
	else:
		_set_patrol_point(_get_nearest_patrol_point_index())

func tick(delta):
	var direction = enemy.navigation_agent.get_next_path_position() - enemy.global_position
	enemy.move(direction.normalized(), false, delta)
	
	if enemy.get_real_velocity().length_squared() > 0:
		enemy.animation_state_machine.travel("walking")
	else:
		enemy.animation_state_machine.travel("idle")

func _set_patrol_point(index):
	current_patrol_point = index
	enemy.navigation_agent.set_target_position(patrol_points[index].global_position)

func _next_patrol_point():
	return (current_patrol_point + 1) % patrol_points.size()

func _get_nearest_patrol_point_index():
	var index = 0
	var nearest_distance = Constants.INT32_MAX
	for i in patrol_points.size():
		var distance = (enemy.position - patrol_points[i].position).length_squared()
		if distance < nearest_distance:
			nearest_distance = distance
			index = i
		
	return index
