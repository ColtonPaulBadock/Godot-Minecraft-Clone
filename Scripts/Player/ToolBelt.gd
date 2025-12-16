#This is the players toolbelt (inventory)
#Here it will allow the player to select various
#materials, tools, items, etc.
#Anything the player can pickup will be stored
#here when picked up.

extends Control

#Boolean status to if the player is in their
#backpack or not. 
#------------
#false -> The player is not in there backpack,
#the backpack UI is hidden and the player
#can see and interact with the toolbelt UI
#true -> The player is in there backpack,
#the backpack UI is open, and the player
#can move around the items, manage the
#backpack/inventory, etc.
var isInBackpack : bool = false;

#Instance of the items in the players
#backpack/toolbelt.
#----
#Each index represents 1 slot of the backpack.
#refer to "backpack_reference.png" in "\Assets\ingameUI\toolbelt"
var items = [];

#Called when scene enters the tree,
#here we can intialize important aspects
#related to the inventory, such as pulling
#save data for what was in the inventory
func _ready() -> void:
	pass;


#Runs every application frame.
func _process(delta: float) -> void:
	pass;
