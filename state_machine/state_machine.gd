class_name StateMachine

extends Node

var transitions: Dictionary
var current_state: State
var next_transitions: Array[Transition]
var any_transitions: Array[Transition]

func enter():
	pass
	
func add_transition(transition: Transition):
	if transition.from == null:
		any_transitions.append(transition)
		return
	
	var from_transitions = []
	if transitions.has(transition.from):
		from_transitions = transitions[transition.from]
	
	from_transitions.append(transition)
	transitions[transition.from] = from_transitions

func tick(delta):
	var next_transition = null
	
	for transition in any_transitions:
		if transition.to == current_state:
			continue
			
		if not transition.condition.call():
			continue
			
		next_transition = transition
		break
	
	if not next_transition:
		for transition in next_transitions:
			if not transition.condition.call():
				continue
			
			next_transition = transition
			break
	
	if next_transition:
		do_transition(next_transition)
	
	current_state.tick(delta)

func do_transition(transition: Transition):
	var exit_state = current_state
	current_state = transition.to
	
	transition.do_transition()
	
	next_transitions = []
	if transitions.has(current_state):
		next_transitions.append_array(transitions[current_state])
	
	if exit_state:
		exit_state.exit()
		
	current_state.enter()

func exit():
	transitions.clear()
	next_transitions.clear()
	any_transitions.clear()
	
	current_state.exit()
	current_state = null
