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
