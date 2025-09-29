extends CharacterBody3D
class_name PlayerController

@export_group("Movement")
@export var role_name : String = "Survivor"
@export var max_speed : float = 3.0
@export var acceleration : float = 15.0
@export var braking : float = 15.0
@export var air_acceleration : float = 4.0
@export var jump_force : float = 5.0
@export var max_run_speed : float = 6.0

@export var gravity_modifier : float = 1.5
var is_running : bool = false

@export_group("Camera")
@export var look_sensitivity : float = 0.005
var camera_look_input : Vector2

@onready var camera : Camera3D = $Camera3D #get_node("Camera3D")
@onready var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity") * gravity_modifier

#Multiplayer set authority
func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _ready():
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = is_multiplayer_authority()
	if is_multiplayer_authority():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta: float) -> void:
	#Multiplayer 
	if !is_multiplayer_authority(): return #don't let other players control other characters
	
	
	#Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	#Jumping
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = jump_force
	
	#Movement
	var move_input = Input.get_vector("move_left","move_right","move_forward","move_back")
	var move_dir = (transform.basis * Vector3(move_input.x, 0, move_input.y)).normalized()
	
	is_running = Input.is_action_pressed("sprint")
	var target_speed = max_speed
	if is_running:
		target_speed = max_run_speed
		var run_dot = -move_dir.dot(transform.basis.z)
		run_dot = clamp(run_dot, 0.8, 1.0)
		move_dir *= run_dot
	
	var current_smoothing = acceleration
	if not is_on_floor():
		current_smoothing = air_acceleration
	elif not move_dir:
		current_smoothing = braking
		
	var target_vel = move_dir * target_speed
	
	velocity.x = lerp(velocity.x, target_vel.x, current_smoothing * delta)
	velocity.z = lerp(velocity.z, target_vel.z, current_smoothing * delta)
	
	move_and_slide()
	
	#Camera_Look
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-camera_look_input.x * look_sensitivity)
		camera.rotate_x(-camera_look_input.y * look_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -1.5, 1.5)
		camera_look_input = Vector2.ZERO
	
	#Mouse
	if Input.is_action_just_pressed("lock_cursor"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Input.is_action_just_pressed("quit"):
		$"../".exit_game(name.to_int())
		get_tree().quit()

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		camera_look_input = event.relative

@rpc("any_peer", "call_local", "reliable")
func apply_role(data : Dictionary):
	if data.has("role_name"): role_name = data["role_name"]
	if data.has("max_speed"): max_speed = data["max_speed"]
	if data.has("acceleration"): acceleration = data["acceleration"]
	if data.has("braking"): braking = data["braking"]
	if data.has("air_acceleration"): air_acceleration = data["air_acceleration"]
	if data.has("jump_force"): jump_force = data["jump_force"]
	if data.has("max_run_speed"): max_run_speed = data["max_run_speed"]
