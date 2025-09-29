extends InteractableObject

@export var creegly: RoleData
@export var survivor: RoleData

@onready var light_bulb = get_node("LightBulb")
@onready var is_on = false

func _ready() -> void:
	_apply_state(is_on)
	# Late joiners get the current truth from the server
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(func(id):
			rpc_id(id, "sync_state", is_on)
		)

func _apply_state(on: bool):
	is_on = on
	light_bulb.visible = on
	if on == true:
		interact_prompt = "[E] become survivor"
	else: 
		interact_prompt = "[E] become creegly"
	

@rpc("any_peer","call_local","reliable")
func _interact():
	if multiplayer.is_server() == false:
		return
	
	var sender_id := multiplayer.get_remote_sender_id()
	
	#flip truth on the server
	_apply_state(!is_on)
	#broadcast the new pedestal state to everyone
	rpc("sync_state", is_on)
	
	var role: RoleData
	if is_on == true:
		role = creegly
	else:
		role = survivor
	var data : Dictionary = {
		"role_name": role.role_name,
		"max_speed": role.max_speed,
		"acceleration": role.acceleration,
		"braking": role.braking,
		"air_acceleration": role.air_acceleration,
		"jump_force": role.jump_force,
		"max_run_speed": role.max_run_speed,
		"fog": role.fog,
	}
	
	var player := get_node_or_null("/root/Main/%d" % sender_id)
	if player:
		print(sender_id)
		player.rpc_id(sender_id, "apply_role", data)


# --- SERVER -> EVERYONE: apply pedestal visuals/state ---
@rpc("any_peer", "call_local", "reliable")
func sync_state(on: bool) -> void:
	_apply_state(on)
