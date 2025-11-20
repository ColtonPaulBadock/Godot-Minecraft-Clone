#Test script, used to figure out which block the player is standing on, or a block in the fragment

extends Node


func _process(delta):
	
	#Vector holds the players position in the world
	#var playerPos : Vector3 = Vector3(get_tree().get_root().get_node("World/Player").position.x,
	#get_tree().get_root().get_node("World/Player").position.y,
	#get_tree().get_root().get_node("World/Player").position.z);
	
	print(get_tree().get_root().get_node("World/Player/BelowPlayer").is_colliding());
	
	pass;
