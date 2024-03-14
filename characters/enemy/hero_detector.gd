class_name HeroDetector

extends Area3D

var hero_detected: bool

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D):
	hero_detected = body.owner.name == Constants.HERO_NAME

func _on_body_exited(body: Node3D):
	hero_detected = not body.owner.name == Constants.HERO_NAME
