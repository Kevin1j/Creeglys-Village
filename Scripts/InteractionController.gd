extends RayCast3D

@onready var interact_prompt_label : Label = get_node("InteractionPrompt")
@onready var player: PlayerController = get_parent().get_parent()

func _process(delta):
	#run it only on the player who is looking
	if not is_multiplayer_authority():
		return
	
	var object = get_collider()
	interact_prompt_label.text = ""
	
	if object and object is InteractableObject:
		if object.can_interact == false:
			return
		interact_prompt_label.text = object.interact_prompt
		
		if Input.is_action_just_pressed("interact"):
			var authority = object.get_multiplayer_authority()
			object.rpc_id(authority, "_interact")
	
