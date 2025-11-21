#Global variables for the game

extends Node

#Default world gravity
var gravity = 9.8;

#Render distance (fragments)
var renderDistance = 2; #How many fragments in each direction about the fragpoint the world will render

#Length of each side of the fragment.
var fragmentSideLength = 10; 

#Block table of all blocks that exist in the game, holding there locations. The index of the array is the block id
#BLOCKS:
#ID 0: DarkBlock
#ID 1: SodBlock
#ID 2: TopSoilBlock
#ID 3: SubSoilBlock
var block_table = [preload("res://Scenes/Objects/Blocks/DarkBlock.tscn"), 
preload("res://Scenes/Objects/Blocks/SodBlock.tscn"), 
preload("res://Scenes/Objects/Blocks/TopSoilBlock.tscn"),
preload("res://Scenes/Objects/Blocks/SubSoilBlock.tscn")];
