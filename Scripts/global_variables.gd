#Global variables for the game

extends Node

#User information
#The username of the player.
const username : String = "player16";

#Default world gravity
var gravity = 9.8;

#Render distance (fragments)
var renderDistance = 2; #How many fragments in each direction about the fragpoint the world will render

#Length of each side of the fragment.
var fragmentSideLength = 10; 
#Length of the sides of each block/unit
var blockSideLength = 1.0;

#Enables/Disables input in the game
#If true, the player can use in-game input (WASD, mouse, etc)
#if false, the player cannot use any inputs.
var inputAllowed = true;

#Debug window boolean
#If true: debug window is open
#If false: debug window is closed
var debugWindowOpen : bool = false;

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
