#Default block script, all blocks extend this script
#and feature custom funcitionality while setting these
#values/properties related to the block themselves.
#All blocks will contain the default values listed here

extends Node

#The block ID of the block, related
#to and as it appears in "global_variables.block_table"
var block_id : int = 0;

#The destructivity variable.
#If true, the block cannot be broken
#If false, the block can be broken
var is_indestructible : bool = false;

#This will be the stack height (limit) of how many
#of this block can be carried in an inventory slot.
#All blocks will assume the global default stack limit
#of "stack_height_default_limit" in the "global_variables",
#however, this might be modified depending block.
var stack_height_limit : int = global_variables.stack_height_default_limit;

#The current stack height if this block is in the players inventory
#/backpack.
var stack_height : int = 0;

#The item type. All items/blocks
#are "BLOCK" by default.
#-----------
#BLOCK -> 1*1*1 cube in the world, with several properties.
var item_type = "BLOCK";
