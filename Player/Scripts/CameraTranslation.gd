extends Camera3D

@export var player_body:CharacterBody3D
var motion: float
var headbob_freq:float 
var headbob_amount: float 
var headbob_time: float = 0.0


func _ready() -> void:
	global_position = get_parent().global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	headbob_time += delta * player_body.velocity.length()
	var headbob_vector: Vector3 = Vector3(
		cos(headbob_time * headbob_freq * 0.5) * headbob_amount,
		sin(headbob_time * headbob_freq) * headbob_amount,
		0.0
	)
	var weight: float = motion * delta
	weight = clampf(weight, 0.0 , 1.0)
	global_transform = global_transform.interpolate_with(get_parent().global_transform, weight)
	if player_body.velocity.length() != 0:
		transform.origin = transform.origin + headbob_vector
	else:
		global_position = lerp(global_position, get_parent().global_position, 0.5)
		headbob_time = 0.0
