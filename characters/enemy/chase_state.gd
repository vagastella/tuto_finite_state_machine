class_name ChaseState

extends State

var enemy: Enemy

func _init(_enemy: Enemy):
	enemy = _enemy

func tick(delta):
	enemy.navigation_agent.set_target_position(enemy.sighted_hero.global_position)
	
	var direction = enemy.navigation_agent.get_next_path_position() - enemy.global_position
	enemy.move(direction.normalized(), true, delta)
	
	
	if enemy.get_real_velocity().length_squared() > 0.01:
		enemy.animation_state_machine.travel("running")
	else:
		enemy.animation_state_machine.travel("idle")
