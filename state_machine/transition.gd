class_name Transition

extends Object

var from: State
var condition: Callable
var to: State

func do_transition():
	pass

func _init(_from: State, _condition: Callable, _to: State):
	from = _from
	condition = _condition
	to = _to
