#This is the players toolbelt (inventory)
#Here it will allow the player to select various
#materials, tools, items, etc.
#Anything the player can pickup will be stored
#here when picked up.

extends Control

#Inventory textures
var tool_belt_texture_path : Resource = preload("res://Assets/ingameUI/toolbelt/ToolBelt.png");
var back_pack_texture_path : Resource = preload("res://Assets/ingameUI/toolbelt/Backpack.png");

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
	
	#Intialize the inventory and all its sprites,
	#assets, functions, vars, etc.
	initInventoryUtilities();
	
	pass;


#Runs every application frame.
func _process(delta: float) -> void:
	
	#If the "toggle_backpack" input is pressed, flip the
	#boolean "isInBackpack" to true if false, and false
	#if true. This will run the inventory/backpack management
	#system until the player hits this keybind again to
	#close the backpack.
	if (Input.is_action_just_pressed("toggle_backpack") && (global_variables.inputAllowed != false || isInBackpack == true)):
		isInBackpack = !isInBackpack;
		
		#NOTE: DEBUG
		print("Inventory toggled!");
		
		#Depending on if we where in or not in
		#the backpack at the time for the key being pressed
		#we will either open or exit the backpack.
		if (isInBackpack == true):
			openBackPack();
		elif (isInBackpack == false):
			closeBackPack();
	
	
	#If we are suppose to be inside the backpack,
	#then allow the player to interact with it,
	#move stuff, etc.
	if (isInBackpack == true):
		runInventory();
	
	
	pass;

#Opens the players inventory/backpack
#menu. The backpack will be open until
#"closeBackPack()" is called.
#--------
#Intializes the players inventory
func openBackPack() -> void:
	
	#Switch from the toolbelt only texture to the texture
	#including the backpack.
	$ToolBelt.texture = back_pack_texture_path;
	#Set the position of the "ToolBelt" (Sprite2D) to be moved
	#over so the backpack sprite fits.
	$ToolBelt.position.x = 332.0;
	#Apply the grayed out background/effect
	#for the backpack window
	$BackPackWindow.visible = true;
	
	#Disable all inputs while we are in the backpack.
	global_variables.inputAllowed = false;
	
	
	pass;


#Closes the players backpack/inventory
#menu.
func closeBackPack() -> void:
	
	#Switch from the toolbelt+backpack texture
	#to the toollbelt only texture.
	$ToolBelt.texture = tool_belt_texture_path;
	#Set the position of the "ToolBelt" (Sprite2D) to be moved
	#over so the ToolBelt sprite fits.
	$ToolBelt.position.x = 170.0;
	#Hide the backpack background
	#so that its not visible while we are
	#outside the backpack
	$BackPackWindow.visible = false;
	
	#Allow inputs again once we close the backpack.
	global_variables.inputAllowed = true;
	
	pass;


#Runs the inventory/backpack system for the
#player when the menu is open. Allows for
#moving, slecting items, etc.
func runInventory() -> void:
	
	pass;


#Intializes the inventory system when
#the "ToolBelt.tscn" scene is loaded into
#the game (with the player).
#This will be called from _ready();
func initInventoryUtilities() -> void:
	
	
	pass;
