class_name WatchingState

extends State

var enemy: Enemy
var watch_time: float = 5
var time_left: float

func _init(_enemy: Enemy):
	enemy = _enemy

func enter():
	time_left = watch_time
	enemy.animation_state_machine.travel("idle")

func tick(delta):
	time_left -= delta
