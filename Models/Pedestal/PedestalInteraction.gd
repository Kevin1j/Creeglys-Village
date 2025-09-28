extends InteractableObject

@onready var light_bulb = get_node("LightBulb")
@onready var is_on = false

func _interact():
	if is_on == false:
		interact_prompt = "Turn Off"
		light_bulb.visible = true
		is_on = true
	else:
		interact_prompt = "Turn On"
		light_bulb.visible = false
		is_on = false
	
