extends Node3D

var peer = ENetMultiplayerPeer.new()
@export var player_scene : PackedScene

func _on_server_pressed() -> void:
	peer.create_server(1027)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(add_player)
	add_player()
	$Join.hide()


func _on_client_pressed() -> void:
	peer.create_client("127.0.0.1",1027)
	multiplayer.multiplayer_peer = peer
	$Join.hide()


func add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	player.set_multiplayer_authority(id)
	call_deferred("add_child", player)
	#Place at spawn
	var m := get_node("Spawn") as Marker3D
	if player is CharacterBody3D:
		player.velocity = Vector3.ZERO
	
	
	await get_tree().create_timer(1.0).timeout
	player.global_transform = m.global_transform
	

func exit_game(id):
	multiplayer.peer_disconnected.connect(del_player)
	del_player(id)

func del_player(id):
	rpc("_del_player", id)
	
	
@rpc("any_peer", "call_local")
func _del_player(id):
	get_node(str(id)).queue_free()
	
