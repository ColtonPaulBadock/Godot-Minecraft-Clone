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
	
	#If the "toggle_backpack" input is pressed, flip the
	#boolean "isInBackpack" to true if false, and false
	#if true. This will run the inventory/backpack management
	#system until the player hits this keybind again to
	#close the backpack.
	if (Input.is_action_just_pressed("toggle_backpack")):
		isInBackpack = !isInBackpack;
		
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
func openBackPack() -> void:
	
	pass;


#Closes the players backpack/inventory
#menu.
func closeBackPack() -> void:
	
	pass;


#Runs the inventory/backpack system for the
#player when the menu is open. Allows for
#moving, slecting items, etc.
func runInventory() -> void:
	
	pass;
