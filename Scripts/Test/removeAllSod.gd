#Test script to loop through all fragments and delete every sod block.
#Script runs based on binded key.

extends Node

var loadedFragments; #Array that holds all the loaded fragments in the world


func _ready() -> void:
	
	loadedFragments = get_tree().get_root().get_node("World").fragments;
	
	pass;


func _process(delta) -> void:
	
	removeSodBlocks(loadedFragments); #Remove all sod blocks from the world
	
	pass;


func removeSodBlocks(fragments) -> void:
	
	for FRAGMENT in fragments:
		for BLOCK in FRAGMENT.blocks:
			if BLOCK.block_id == 1:
				#FRAGMENT.blocks.remove_at(BLOCK.find(blockToRemove));
				FRAGMENT.blocks.remove_at(FRAGMENT.blocks.find(BLOCK));
				FRAGMENT.remove_child(BLOCK);
			pass;
		pass;
	
	pass;
