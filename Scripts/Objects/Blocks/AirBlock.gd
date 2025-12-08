#Script for the Air Block.
#This block is a special block to the games
#rendering and generation, as everything
#within .5 unit radius (touching it) will
#be rendered.
#---------
#Block is used for underground and terrain
#generation for blocks that have been
#removed.

extends Node

var block_id : int = -1; #Id of the block, based on "global_variables.block_table".
