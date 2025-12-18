#Script for the Air Block.
#This block is a special block to the games
#rendering and generation, as everything
#within .5 unit radius (touching it) will
#be rendered.
#---------
#Block is used for underground and terrain
#generation for blocks that have been
#removed.

extends "res://Scripts/World/block.gd"

#Runs when object is created
func _init() -> void:
	
	#Set all default parameters for the block
	setDefaultParameters();
	
	pass;

#Intilizes all default parameters for the block
func setDefaultParameters() -> void:
	
	block_id = 7;
	
	pass;
