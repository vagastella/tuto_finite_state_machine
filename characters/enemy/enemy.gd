class_name Enemy

extends CharacterBody3D

@export var patrol_points: Array[Node3D]
@export var speed: float = 85
@export var run_speed: float = 200

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var animation_state_machine: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
@onready var sight: Area3D = $Sight

var state_machine: StateMachine
var sighted_hero: Hero

func _ready():
	sight.body_entered.connect(_on_body_entered)
	sight.body_exited.connect(_on_body_exited)
	
	state_machine = StateMachine.new()
	state_machine.enter()
	
	_setup_state_machine()

func _process(delta):
	state_machine.tick(delta)
	
func _exit_tree():
	state_machine.exit()
	state_machine = null
	
	sight.body_exited.disconnect(_on_body_exited)
	sight.body_entered.disconnect(_on_body_entered)

func move(direction, run, delta):
	if direction != Vector3.ZERO:
		look_at(position + direction, Vector3.UP)
	
	if run:
		velocity = direction * run_speed * delta
	else:
		velocity = direction * speed * delta

	move_and_slide()

func _setup_state_machine():
	var patrol_state = PatrolState.new(self, patrol_points)
	var watching_state = WatchingState.new(self)
	var chase_state = ChaseState.new(self)
		
	var any_to_patrol = Transition.new(null, func(): return state_machine.current_state == null, patrol_state)
	var patrol_to_watching = Transition.new(patrol_state, func(): return navigation_agent.is_navigation_finished(), watching_state)
	var watching_to_patrol = WatchingToPatrol.new(watching_state, func(): return watching_state.time_left < 0, patrol_state)
	var any_to_chase = Transition.new(null, func(): return sighted_hero, chase_state)
	var chase_to_patrol = ChaseToPatrol.new(chase_state, func(): return not sighted_hero, patrol_state)
	
	state_machine.add_transition(any_to_patrol)
	state_machine.add_transition(patrol_to_watching)
	state_machine.add_transition(watching_to_patrol)
	state_machine.add_transition(any_to_chase)
	state_machine.add_transition(chase_to_patrol)

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
