extends CharacterBody3D

#Character Movement Settings
@export_group("Movement Settings")
@export var walk_speed: float = 4.0
@export var run_speed: float = 6.0
@export var jump_velocity: float = 1.0
@export var fall_speed: float = 1.0
@export var can_double_jump: bool
@export var crouch_speed:float = 2.0
#Stairs and Slop Settings
@export_group("Stairs and Slop Settings")
@export var steps_height: float = 0.3
#Camera Settings
@export_group("Camera Settings")
@export var mouse_senstivity: float = 500.0
@export_range(-100.0, -10.0) var xclamp_min: float = -90
@export_range(10.0, 100.0) var xclamp_max: float = 90
@export var mouse_captured: bool = true
@export var camholder: Node3D
#AimDot Settings
@export_group("AimDot Settings")
@export var aimdot: AimDot
@export var circle_raduis: float = 5.0
@export var circle_color: Color = Color.DARK_GRAY
@export var outline_raduis: float = 5.5
@export var outline_color: Color = Color.GHOST_WHITE
@export var filled: bool = true
@export var circle_width: float = 1.0
@export var antialiass: bool = true
#Head Ray Settings
@export_group("Head Ray Settings")
@export var headray: RayCast3D
@export var raylenght: Vector3
@export var exparent: bool = true
#Head Collision Settings
@export_group("Head ShapeCast3D Settings")
@export var headshape3d: ShapeCast3D
@export var excludeparent: bool  = true
var _is_colliding: bool = false
#Animation Settings
@export_group("Animation Settings")
@export var animation_player: AnimationPlayer
@export var blend_speed: float = 1.0
@export var animation_speed: float = 1.0
#Flashlight Settings
@export_group("FlashLigh Settings")
@export var flashlight:SpotLight3D
@export var fashlight_power: float = 1.0
@export var flashlight_stat: bool = false
@export var flashlight_battery: float = 100
#incode variables
var speed: float
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") 
var mouse_motion: Vector2 = Vector2.ZERO
var jump_direction: Vector3
var direction: Vector3
var headray_colliding: bool 
var jumping: bool 
var crouch:bool
var is_run: bool
var joystickmotion:Vector2

func _ready() -> void:
	if aimdot:
		aimdot.circle_raduis = circle_raduis
		aimdot.circle_color = circle_color
		aimdot.outline_raduis = outline_raduis
		aimdot.outline_color = outline_color
		aimdot.filled = filled
		aimdot.circle_width = circle_width
		aimdot.antialiass = antialiass
	flashlight.visible = false
	flashlight_stat = false
	speed = walk_speed
	if mouse_captured:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	#Animation starter state
	blend_speed = blend_speed * -1

	#crouch starter state
	crouch = false

	#headray properties
	headray.target_position = raylenght
	headray.exclude_parent = exparent

	#headshape3d properties
	headshape3d.exclude_parent = excludeparent


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_motion = -event.relative / mouse_senstivity
	if event is InputEventJoypadMotion:
		print(event.axis_value)
	if Input.is_action_just_pressed("escape"):
		get_tree().quit()

	if Input.is_action_pressed("speed") and is_on_floor() and !crouch:
		is_run = true
	else:
		is_run = false

	if Input.is_action_just_pressed("crouch"):
		if !crouch:
			animation_player.play("Crouch" , blend_speed, animation_speed, false)
			speed = crouch_speed
			crouch = true
		elif crouch == true and !_is_colliding:
			animation_player.play("Crouch" , blend_speed, -animation_speed, true)
			speed = walk_speed
			crouch = false
	if Input.is_action_just_pressed("flashlight"):
		if flashlight_stat == false:
			flashlight_stat = true
			flashlight.visible = true
		else:
			flashlight_stat = false
			flashlight.visible = false

func _movement_speed() -> void:
	if is_on_floor():
		if is_run and !crouch:
			speed = run_speed
		elif !is_run and !crouch:
			speed = walk_speed
		else:
			speed = crouch_speed


func _character_control() -> void:
	rotate_y(mouse_motion.x)
	camholder.rotate_x(mouse_motion.y)
	camholder.rotation_degrees.x = clampf(camholder.rotation_degrees.x, xclamp_min, xclamp_max)
	mouse_motion = Vector2.ZERO


func double_jump() -> void:
	pass


func _physics_process(delta: float) -> void:
	_movement_speed()
	_is_colliding = headshape3d.is_colliding()
	headray_colliding = headray.is_colliding()
	_character_control()
	# Add the gravity.
	if not is_on_floor():
		if velocity.y >= 0:
			velocity.y -= gravity * delta
		elif velocity.y <= 0:
			velocity.y -= gravity * delta * fall_speed

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		if crouch and !_is_colliding:
			animation_player.play("Crouch" , blend_speed, -animation_speed, true)
			crouch = false
		elif !crouch and _is_colliding or crouch and _is_colliding:
			print("cant jump here")
		else:
			velocity.y = sqrt(jump_velocity * 2 * gravity)
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("leftward", "rightward", "forward", "backward")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
