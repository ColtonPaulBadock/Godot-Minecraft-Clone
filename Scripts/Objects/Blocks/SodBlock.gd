#Script for the Sod Block

extends "res://Scripts/World/block.gd"

#Runs once when entering the scene tree.
func _ready() -> void:
	
	#Set all default parameters for the block
	setDefaultParameters();
	
	pass;

#Intilizes all default parameters for the block
func setDefaultParameters() -> void:
	
	block_id = 1;
	
	pass;
