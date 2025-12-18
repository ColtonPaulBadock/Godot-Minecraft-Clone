#Script for the BrickBlock.

extends "res://Scripts/World/block.gd"

#Runs when object is created
func _init() -> void:
	
	#Set all default parameters for the block
	setDefaultParameters();
	
	pass;

#Intilizes all default parameters for the block
func setDefaultParameters() -> void:
	
	block_id = 4;
	
	pass;
