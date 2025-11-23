#Global variables for the game

extends Node

#How far the RayCast3D.collision_point will enter into the block,
#this cuts back on the fragment and block boarders issue.
var playerReachPenetration = 0.02;

#These variables dictate the maximum rotation the camera (player view) can legally perform
#(In radians)
const playerCameraMaxLookUp = 1.57; #The maximum rotation allowed by the players camera looking up from its starting positon.
const playerCameraMinLookDown = -1.57; #The maximum rotation allowed by the players camera looking down from its starting positon.

#The version of the game
const version : String = "PCR 0.1.2";

#User information
#The username of the player.
const username : String = "player16";

#Default world gravity
var gravity = 9.8;

#Render distance (fragments)
var renderDistance = 10; #How many fragments in each direction about the fragpoint the world will render

#This variable is the world height/depth
#(how far/deep the world terrain is)
var worldDepth : int = 2;

#World median layer height
#This value acts like a 'median' height for the world.
#When a layer is being spawned in using "generateTerrain()"
#in fragment.gd, we add this value to it. to take negative noise
#values into account. This median will be subtracted from then, and can allow
#for valleys and drops to generate.
#Positive noise values will add onto this value.
#Assuming we have now spawning the top world layer with this,
#we can use noise to spawn blocks/objects below
#it and spawn nothing below Y=0.
var medianWorldLayer : int = 50;

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

#Instance of the AudioManager.
#This system is used to control all audio throughout the game.
#The "AudioManager.tscn" scene is a child of "World" node in the "World.tscn" scene.
#This variables is a instance and provides global access
@onready var AudioManager = get_tree().get_root().get_node("World/AudioManager");;

#Block table of all blocks that exist in the game, holding there locations. The index of the array is the block id
#BLOCKS:
#ID 0: DarkBlock
#ID 1: SodBlock
#ID 2: TopSoilBlock
#ID 3: SubSoilBlock
#ID 4: BrickBlock
#ID 5: SandBlock
#ID 6: LimestoneBlock
var block_table = [preload("res://Scenes/Objects/Blocks/DarkBlock.tscn"), 
preload("res://Scenes/Objects/Blocks/SodBlock.tscn"), 
preload("res://Scenes/Objects/Blocks/TopSoilBlock.tscn"),
preload("res://Scenes/Objects/Blocks/SubSoilBlock.tscn"),
preload("res://Scenes/Objects/Blocks/BrickBlock.tscn"),
preload("res://Scenes/Objects/Blocks/SandBlock.tscn"),
preload("res://Scenes/Objects/Blocks/LimestoneBlock.tscn")];

#The maximum block ID that exists.
#Take the size of the block_table[] array,
#subtract 1 from this value to account for
#ID: 0 existing as a valid value.
var maxBlockId = block_table.size() - 1;
