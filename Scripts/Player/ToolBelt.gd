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
	
	#NOTE: DEBUG
	insertAtIndex(global_variables.block_table[2].instantiate(), 4, 24);
	insertAtIndex(global_variables.block_table[4].instantiate(), 8, 28);
	insertAtIndex(global_variables.block_table[3].instantiate(), 15, 57);
	
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
	#Make the mouse visible for inventory management
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
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
	#Also hide the mouse so we can play the game again.
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN);
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
	
	#Sets the "items[]" array to a size of 31
	#(32 total indexs 0-31). This is the max
	#inventory size.
	items.resize(31);
	
	pass;


#Inserts the object "BLOCK" into the inventory
#at the index of "index" and inputs the given
#amount "amount" into said index. Will destroy
#the instance of whatever was previously in that
#index
#----------
#ARGUMENTS:
#BLOCK -> What to insert
#index -> Where to insert the object (which index of the backpack)
#amount -> The amount of the object to insert.
func insertAtIndex(BLOCK, index, amount) -> void:
	
	#If the index requested is larger than 31,
	#return from this function as 31 is the largest
	#possible backpack slot.
	if (index > 31):
		return;
	
	#Next we need to check the ammount being
	#inserted at this index. If the ammount
	#is over the maximum allowed ammount,
	#then we will set the ammount to the
	#maximum ammount, and insert the max
	#ammount allowed in a stack instead.
	if (amount > BLOCK.stack_height_limit):
		amount = BLOCK.stack_height_limit;
	
	#We will now apply the amount
	#in the stack to the stack of items
	BLOCK.stack_height = amount;
	
	
	#Insert the stack of the item in instance "BLOCK"
	#into the backpack at the given index "index".
	items.insert(index, BLOCK);
	
	pass;


#Takes "BLOCK" and inserts the ammount "ammount"
#of the "BLOCK" into the next non-full stack.
#If no space, the object is not inserted into the backpack
#and false is returned. If there is space, the object is inserted
#into the next empty stack or a new stack is created
#if empty space if other stacks are full or no stack
#of the object "BLOCK" already exists (true is returned).
#--------
#ARGUMENTS:
#BLOCK -> What to insert
#ammount -> How much to insert.
#--------
#RETURNS:
#true -> everything was inserted with no issue
#false -> no space, so nothing was inserted OR some space existed but not all of it fit
func insertIntoBackPack(BLOCK, ammount) -> bool:
	
	#This is the return value of this function.
	#If false, not everything was inserted into
	#the backpack. If true, everything fit fine.
	var stuffFullyInserted = false;
	
	#First we will check to see if theres any existing
	#stacks. If there is, we will begin by filling these
	#stacks to max stack limit.
	for item in items:
		
		#We moved to the next index of "items" we will
		#check to see if the block_id of the item we want
		#to insert matches the item, if it does, lets
		#add the ammount to the stack:
		if (item.block_id == BLOCK.block_id):
			
			#If we can add the ammount to the stack we
			#found of the same ID, and it sums to less
			#than the objects stack_height_limit, simply add the ammount to the
			#stack, and then we can return true for success.
			if (item.stack_height + ammount < BLOCK.stack_height_limit):
				item.stack_height = item.stack_height + ammount;
				stuffFullyInserted = true;
				return stuffFullyInserted;
			
			#If the stack_height travels above the items
			#stack_height_limit. Then we will store
			#what we can into the given stack, and will then
			#move to the next index, trying to store more in
			#another.
			if (item.stack_height + ammount > BLOCK.stack_height_limit):
				
				#Figure out how much we can add to the
				#item.stack_height until it is at max
				#stack height.
				var addedAmount : int = BLOCK.stack_height_limit - item.stack_height;
				
				#We determined that the stack_height for the item
				#in this index will be filled to the top (max stack height).
				item.stack_height = BLOCK.stack_height_limit;
				
				#We subtract the ammount we added to the
				#stack in this index of the backpack from
				#the overall ammount we need to add, to
				#update "ammount" with how much more left
				#we need to store.
				ammount = ammount - addedAmount;
				
				pass; 
			pass;
		pass;
	
	
	
	#If we didn't insert everything fully, we will return
	#false, saying we didn't fully insert everything
	#as an exit status.
	return stuffFullyInserted;
