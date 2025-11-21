#Test script, used to figure out which block the player is standing on, or a block in the fragment

extends Node


func _ready():
	
	
	pass;


func _process(delta):
	
	#Vector holds the players position in the world
	#var playerPos : Vector3 = Vector3(get_tree().get_root().get_node("World/Player").position.x,
	#get_tree().get_root().get_node("World/Player").position.y,
	#get_tree().get_root().get_node("World/Player").position.z);
	
	get_tree().get_root().get_node("World").locateBlockAt(12.7, -74.9, -10.2);
	
	#Gets the world location of the raycast collision
	if get_tree().get_root().get_node("World/Player/BelowPlayer").get_collider() != null:
		#print(get_tree().get_root().get_node("World/Player/BelowPlayer").get_collision_point());
		pass;
	
	pass;
