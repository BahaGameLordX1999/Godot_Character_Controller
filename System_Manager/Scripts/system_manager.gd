extends Control

@export var Character: CharacterBody3D
@onready var fpslabel: Label = $Panel/Monitor/FPSLABEL
@onready var ray_label: Label = $Panel/Monitor/RayLabel
@onready var head_collision_label: Label = $Panel/Monitor/HeadCollisionLabel
@onready var speed_label: Label = $Panel/Monitor/SpeedLabel
var fps_value: String 
var collsion_ray 
var head_collsion: bool = false
var character_speed: float

func _process(_delta: float) -> void:
	fps_value = str(Engine.get_frames_per_second())
	character_speed = Character.speed
	collsion_ray = Character.headray.get_collider()
	fpslabel.text = fps_value
	head_collsion = Character._is_colliding
	head_collision_label.text = str(head_collsion)
	speed_label.text = str(character_speed)
	if Character:
		if Character.headray.is_colliding():
			ray_label.text = str(collsion_ray.name)
	else:
		get_tree().quit()
