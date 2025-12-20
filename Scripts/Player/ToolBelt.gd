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

#This is the index I am actively moving if
#I clicked an index with the mouse.
#Points to an index in "items[]"
var moving_index = null;
#The index of the item "moving_index" in
#"items[]" array
var moving_index_items_index = null;

#Instance of the items in the players
#backpack/toolbelt.
#----
#Each index represents 1 slot of the backpack.
#refer to "backpack_reference.png" in "\Assets\ingameUI\toolbelt"
var items = [];
#Indexes related to "items[]" which are in
#the toolbelt.
var toolbelt_indexes = [0, 8, 16, 24, 25, 26, 27];
#The current index of the players tool_belt.
#from 0-toolbelt_indexes.size;
var tool_belt_index = 0;

#Called when scene enters the tree,
#here we can intialize important aspects
#related to the inventory, such as pulling
#save data for what was in the inventory
func _ready() -> void:
	
	#Intialize the inventory and all its sprites,
	#assets, functions, vars, etc.
	initInventoryUtilities();
	
	#NOTE: DEBUG
	insertAtIndex(global_variables.block_table[4].instantiate(), 0, 10);
	insertAtIndex(global_variables.block_table[6].instantiate(), 5, 45);
	insertAtIndex(global_variables.block_table[2].instantiate(), 17, 4);
	insertAtIndex(global_variables.block_table[5].instantiate(), 23, 69);
	insertAtIndex(global_variables.block_table[1].instantiate(), 30, 67);
	
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
	
	
	#Run the toolbelt/backpack (inventory)
	#system each game frame. Here we update
	#the inventory, change toolbelt visualy
	#("ToolBeltSelectedSlot"), etc.
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
	#Also make the Indexes of the backpack
	#all fully visible
	$Indexes.visible = true;
	
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
	#Also make the Indexes of the backpack
	#all invisible
	$Indexes.visible = false;
	
	#Allow inputs again once we close the backpack.
	#Also hide the mouse so we can play the game again.
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN);
	global_variables.inputAllowed = true;
	
	pass;


#Runs the inventory/backpack system for the
#player when the menu is open. Allows for
#moving, slecting items, etc.
func runInventory() -> void:
	
	#Updates the ToolBelt to show the player
	#which index of the ToolBelt they have
	#actively selected.
	toolBeltSelectedSlotController();
	
	#Updates everything that changed in the backpack
	#from the previous frame to display what the actual
	#backpack is (items, etc); This changes the icon
	#of the index, how many in the stack, etc.
	updateBackPack();
	
	#Removes all items where stack_height is 0 or less,
	#since these stacks are empty, nothing can be there.
	#We remove icon, stack_height label and set the index
	#of "items[]" to be null.
	removeEmptyItems();
	
	#Allow for drag and drop backpack/inventory
	#management if we are in the backpack.
	dragDropController();
	
	pass;



#Enables drag and drop inventory management
func dragDropController() -> void:
	
	#The mouse position of where we
	#clicked in the backpack;
	#We will use this to determine if
	#we selected an index or not.
	var mouse_position = null;
	
	#If the player left-clicked, we will determine
	#where it was they clicked, however, if they didn't
	#"mouse_position" will remain as null and we will exit
	#this function.
	if (Input.is_action_just_pressed("strike") && isInBackpack == true):
		mouse_position = get_viewport().get_mouse_position();
	
	#Here is where we determine what it is we clicked,
	#and how it should be handled (I.E. dragged by mouse,
	#etc).
	#------
	#We will also make sure "moving_index" is null,
	#if its not null, then we are actively moving stuff
	#and will keep moving the stuff at ID: 99991793.
	if (mouse_position != null && moving_index == null && isInBackpack == true):
		
		#Determine which index I clicked
		for i in items.size():
			
			#Get the pixel location of the current index
			#we are checking "i", so we can compare the mouse
			#screen corrdinates "mouse_position" to the position
			#of all indexes since we detected a "strike" from the
			#input map.
			var indexPosition : Vector2 = getBackPackIndexPixelLocation(i);
			
			#Check to see if the mouse corrdinates are within a 40 * 40
			#area around the center of the index. We use "20" for each
			#side, but this number could varry if we wanted it to.
			#-------
			#First check the x-axis
			if (indexPosition.x - 20 < mouse_position.x && mouse_position.x < indexPosition.x + 20):
				#We determined the x-axis lines up, now we will check the y-axis
				#to see if it lines up
				if (indexPosition.y - 20 < mouse_position.y && mouse_position.y < indexPosition.y + 20):
					#We determined the index we clicked,
					#now set "moving_index" to this, so that
					#we can move the index around and hold
					#it with the mouse (i is the current index
					#and we are checking if we clicked said indexes
					#position or a position within said index)
					moving_index = getItem(i);
					moving_index_items_index = i;
					return;
					pass;
				pass;
			
			pass;
		
		pass;
	
	#ID: 99991793
	#If the "moving_index" is not null,
	#we are actively moving an index and will control it here.
	if (moving_index != null):
		
		#Move the current item we are dragging
		#"moving_index" with the cursor.
		$Indexes.get_node(str(moving_index_items_index)).position = get_viewport().get_mouse_position();
		
		#If we close the backpack, make the item we were dragging
		#return to its orginal index, and set the item we are
		#currently dragging to null
		if (isInBackpack == false):
			$Indexes.get_node(str(moving_index_items_index)).position = getBackPackIndexPixelLocation(moving_index_items_index);
			items[moving_index_items_index] = moving_index;
			moving_index = null;
			moving_index_items_index = null;
			pass;
		
		#If we clicked the "strike" action, determine what
		#index we clicked. If we are not at any index, do nothing.
		#If we click a index and nothings there, we will insert the
		if (Input.is_action_just_pressed("strike")):
			
			#Determine if we actually clicked an index, if we did
			#then we will need to store the index and perform a
			#swap or insertion into the index depending on if
			#its empty or has another stack in it
			if (getIndexOfPosition(get_viewport().get_mouse_position()) != -1):
				
				#The index of we clicked in the backpack (0-31)
				var indexClicked = getIndexOfPosition(get_viewport().get_mouse_position());
				
				if (indexClicked == moving_index_items_index):
					
					#NOTE: DEBUG
					print("Clicked self!");
					
					insertAtIndex(moving_index, indexClicked, moving_index.stack_height);
					moving_index = null;
					moving_index_items_index = null;
					return;
				
				#If the index we clicked is empty "null",
				#then we will transfer all the items to
				#it from the previous index "moving_index_items_index".
				#We will then set the "moving_index" to null and its related values.
				#Clear the previous index "moving_index".
				if (getItem(indexClicked) == null):
					insertAtIndex(moving_index, indexClicked, moving_index.stack_height);
					items[moving_index_items_index] = null;
					moving_index_items_index = null;
					moving_index = null;
				#If the index we clicked has something else in it, we will insert
				#"moving_index" into the clicked index, and will make what was
				#previously in "indexClicked" as the new "moving_index"
				elif (getItem(indexClicked) != null):
					
					#Temporary variable to store the index
					#of the item we just clicked to pick up,
					#so we can inset "moving_index" into the previous spot
					var temp = getItem(indexClicked);
					
					#Insert the previous item into the index we
					#just clicked "indexClicked" and take the item
					#previously in said "indexClicked", which is
					#temporary stored in "temp" and store it in
					#"moving_index" so we can move it.
					insertAtIndex(moving_index, indexClicked, moving_index.stack_height);
					items[moving_index_items_index] = null;
					#moving_index_items_index = null;
					moving_index = temp;
					
					pass;
				pass;
			pass;
		
		
		pass;
	
	pass;


#Takes "pos" a Vector2 as an argument and
#will return the backpack index at the position.
#Returns -1 if no index is found
#------
#ARGUMENTS:
#pos -> A position in the backpack, the index of the "items{}" array related to this slot is returned if one matches the position
func getIndexOfPosition(pos : Vector2) -> int:
	
	#The backpack index at the Vector2
	#position provided "pos"
	#-1 if we can't find an index at the
	#position. This value will be returned by the function.
	var index = -1;
	
	#Determine which index I clicked
	for i in items.size():
		
		#Get the pixel location of the current index
		#we are checking "i", so we can compare the mouse
		#screen corrdinates "mouse_position" to the position
		#of all indexes since we detected a "strike" from the
		#input map.
		var indexPosition : Vector2 = getBackPackIndexPixelLocation(i);
		
		#Check to see if the mouse corrdinates are within a 40 * 40
		#area around the center of the index. We use "20" for each
		#side, but this number could varry if we wanted it to.
		#-------
		#First check the x-axis
		if (indexPosition.x - 20 < pos.x && pos.x < indexPosition.x + 20):
			#We determined the x-axis lines up, now we will check the y-axis
			#to see if it lines up
			if (indexPosition.y - 20 < pos.y && pos.y < indexPosition.y + 20):
				#We determined the index we clicked,
				#now set "moving_index" to this, so that
				#we can move the index around and hold
				#it with the mouse (i is the current index
				#and we are checking if we clicked said indexes
				#position or a position within said index)
				index = i;
				pass;
			pass;
		pass;
	
	return index;




#If we have any item with a stack_height of 0,
#we will remove it from the inventory and set
#the index to null.
#-------
#Used in "runInventory()", to keep
#the inventory clear of anything that
#is fully used/does not exist.
func removeEmptyItems() -> void:
	
	#The index of the for-loop at "ID: 329874"
	#so we can loop through all the items and
	#remove anything with a stack_height of 0
	#or below
	var index : int = 0;
	
	#"ID: 329874"
	#Loop through all items,
	#if the stack_height is 0 or less,
	#remove it from the backpack.
	for item in items:
		#Skip null indexs (no items)
		if (item == null):
			index = index + 1;
			continue;
		if (item.stack_height <= 0):
			items[index] = null;
			pass;
		index = index + 1;
	
	pass;


#Data arrays holding the last icon/stack_height
#for the index. We compare these to whats
#current in "updateBackPack()", if theres a difference
#then we will change the icon/stack_height displayed.
#This saves a lot of processing power from changing
#text and .png's
#(indexes in these arrays directly corolate to the
#indexes of "items[]" array)
var last_id = []; #The last block_id of the index
var last_stack_height = []; #The last stack_height of the index

#Updates all indexes of the backpack.
#Will check to see whats in each index of
#the backpack/toolbelt in "items[]" array,
#and will update the icon, ammount and
#other stats of the backpack if needed.
func updateBackPack() -> void:
	
	#The index of "items[]" while looping
	#through all items at ID: 79837
	var index : int = 0;
	
	#ID: 79837
	#Loop through all indexs of the "items[]"
	#array, we will then make sure we have every
	#corolating index of the backpack displaying
	#the correct items.
	for item in items:
		
		#If nothing is there (null), the index is empty
		#and we will bypass this iteration and move to the
		#next index. (Also setting the last variables as null
		#reflecting this)
		if (item == null):
			last_id[index] = null;
			last_stack_height[index] = null;
			#Remove the icon and text if the index is empty (null).
			#There should be nothing there.
			$Indexes.get_node(str(index)).texture = null;
			$Indexes.get_node(str(index)).get_node("stack_height").text = "";
			#Update the index we are currently
			#iterating through
			index = index + 1;
			continue;
		
		#If both the icon (block_id) and the stack height are up to
		#date, we will not need to change anything and can skip this instance
		if (last_id[index] == item.block_id && last_stack_height[index] == item.stack_height):
			#Update the index we are currently
			#iterating through
			index = index + 1;
			continue;
		
		#If we didn't continue through the loop,
		#at this point something changed. Check what
		#changed!
		#-----------
		#Check to make sure the icon (block_id) is the same
		#as last time. If its different, we will update the
		#icon
		if (last_id[index] != item.block_id):
			#Set the icon of the item at "index" of "items[]" with the
			#correct icon for "block_id" of "item" from the
			#global_variables.block_table_icon (array with index-to-index
			#relation to block_table (we are effectively setting the icon
			#related to the item from block_table to said item))
			$Indexes.get_node(str(index)).texture = global_variables.block_table_icon[item.block_id];
			last_id[index] = item.block_id;
			pass;
		
		#If the last stack_height for this index if different than now,
		#we will update it.
		if (last_stack_height[index] != item.stack_height):
			#Update the current stack_height displayed in the inventory
			#if we detected its different from the previous frame.
			$Indexes.get_node(str(index)).get_node("stack_height").text = str(item.stack_height);
			last_stack_height[index] = item.stack_height;
			pass;
		
		#Reset all index Sprite2Ds to default position.
		#This fixed a issue regaurding Sprite2D drifitng
		#when moving items in the inventory.
		$Indexes.get_node(str(index)).position = getBackPackIndexPixelLocation(index);
		
		#Update the index we are currently
		#iterating through
		index = index + 1;
		pass;
	
	pass;


#The controller system to set the "ToolBeltSelectedSlot"
#on the tool belt so the player can visually see what
#they are holding.
func toolBeltSelectedSlotController() -> void:
	
	#Set the "ToolBeltSelectedSlot" on the players toolbelt
	#so we can see what we are holding (tool_belt_index).
	if (tool_belt_index != $ToolBeltSelectedSlot.highlighted_slot_index):
		$ToolBeltSelectedSlot.position = getBackPackIndexPixelLocation(toolbelt_indexes[tool_belt_index]);
		#Set the current slot (index) we are highlighting in the ToolBelt
		#in the variable "highlighted_slot_index", so that we are not
		#changing the position every frame since "toolBeltSelectedSlotController()"
		#runs per each frame. We will only update possible according to the
		#if statement this is under.
		$ToolBeltSelectedSlot.highlighted_slot_index = tool_belt_index;
		pass;
	
	pass;


#Scrolls the players tool_belt index up by one,
#so we can scroll toward the next index.
func tool_belt_up() -> void:
	
	#Scroll one down the tool belt.
	tool_belt_index = tool_belt_index + 1;
	
	#If we are beyond the length of the tool
	#belts size, we will reset back to index number
	#zero.
	if (tool_belt_index >= toolbelt_indexes.size()):
		tool_belt_index = 0;
	
	pass;

#Scrolls the players tool_belt index dwon by one,
#so we can scroll toward the next index.
func tool_belt_down() -> void:
	
	#Scroll one down the tool belt.
	tool_belt_index = tool_belt_index - 1;
	
	#If we are below the length of the tool
	#belts size, we will reset back to the max
	#index "toolbelt_indexes.size()"
	if (tool_belt_index < 0):
		tool_belt_index = toolbelt_indexes.size() - 1;
	
	pass;


#Intializes the inventory system when
#the "ToolBelt.tscn" scene is loaded into
#the game (with the player).
#This will be called from _ready();
func initInventoryUtilities() -> void:
	
	#Sets the "items[]" array to a size of 31
	#(32 total indexs 0-31). This is the max
	#inventory size.
	items.resize(32);
	last_id.resize(32);
	last_stack_height.resize(32);
	
	#Set the position for all inventory/backpack
	#indexes, so each index appears in the
	#correct slot
	for num in 32:
		$Indexes.get_node(str(num)).position = getBackPackIndexPixelLocation(num);
		pass;
	
	pass;


#Returns the center location of a index in the backpack
#in pixels as a Vector2 (x, z).
#--------
#ARGUMENTS:
#index -> the index of the backpack in which we
#will get the pixel location for.
func getBackPackIndexPixelLocation(index : int) -> Vector2:
	
	#The location we will return as Vector2, containing
	#the screen corrdinates in pixels, for the center
	#of "index".
	var pixel_location : Vector2 = Vector2(0, 0);
	
	#Take the backpack grid (inventory grid), we are basically
	#finding the corrinates of the index related to the
	#grid and the apply our math to find the pixel location.
	var index_x : int = ((index % 8) * 81) + 49;#38; #INTIAL: 5 + (43 + ((index % 8) * 87));
	var index_y : int = 746 + (43 + ((floor(index / 8)) * 81)); #INTIAL: 746 + (43 + ((floor(index / 8)) * 87));
	
	#Apply the pixel locations we found,
	#so we can return the corrdinates of the
	#indexs pixel location (for inventory icon UI, for
	#setting the ToolBeltSelectedSlot, etc)
	pixel_location.x = index_x;
	pixel_location.y = index_y;
	
	return pixel_location;


#Takes an ammount "ammount" from an index
#at "index". If the index is empty,
#or it runs out, it will be set as null
#and we will return.
#---------
#ARGUMENTS:
#index -> index of "items[]" to remove stuff from
#ammount -> the ammount to take from the stack at "index"
func takeAmmount(index : int, ammount : int):
	
	#If its an illegal index, return nothing.
	if (index > 31 || index < 0):
		return;
	
	#Subtract the ammount from the stack_height
	#of the items present at "index" of the "items[]"
	#array.
	items[index].stack_height = items[index].stack_height - ammount;
	
	#If the stack_height is less than or is
	#0, we will make the item null, so nothing
	#is in the index.
	if (items[index].stack_height <= 0):
		items[index] = null;
		pass
	
	pass;



#Returns the item from the backpack at the
#provided index "index".
#Will return false if the index is to large or small.
#--------
#ARGUMENTS:
#index -> The index of the items[] array to return.
func getItem(index : int):
	
	#If the index is larger than
	#the "items[]" (backpack) array
	#size, we will return false;
	if (index > 31 || index < 0):
		return null;
	
	#Return the value at the index of the
	#backpack.
	return items[index];

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
	
	#Reset the indexs position in the backpack to
	#its default position (to prevent visiual bugs)
	$Indexes.get_node(str(index)).position = getBackPackIndexPixelLocation(index);
	
	#Insert the stack of the item in instance "BLOCK"
	#into the backpack at the given index "index".
	#items.insert(index, BLOCK);
	items[index] = BLOCK;
	
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
		
		#If the index has "null" value,
		#then there can't possibly be anything in
		#it and theres no reason to check to see if we
		#can insert some "ammount" into the stack.
		#We will continue to the next interation
		if (item == null):
			continue;
		
		#We moved to the next index of "items" we will
		#check to see if the block_id of the item we want
		#to insert matches the item, if it does, lets
		#add the ammount to the stack:
		if (item.block_id == BLOCK.block_id):
			
			#If we can add the ammount to the stack we
			#found of the same ID, and it sums to less
			#than the objects stack_height_limit, simply add the ammount to the
			#stack, and then we can return true for success.
			if (item.stack_height + ammount <= BLOCK.stack_height_limit):
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
	
	
	#The current index of the for items array at ID: 983274274,
	#as we are looping through it.
	var index = 0;
	#We still have some ammount left to insert even though
	#we tried to fill every existing stack that had the same
	#item in it. We will now check for any empty indexs.
	#If indexes are empty, we will fill them with the ammount,
	#to try to store more of it.
	#ID: 983274274
	for item in items:
		
		#If the item index doesn't hold null,
		#there is already something in it,
		#and we can't create a new stack, so we
		#will skip to the next iteration
		if (item != null):
			index = index + 1;
			continue;
		
		#If we find an empty index, we will fill
		#it with as much "ammount" of "BLOCK"
		#as possible
		if (item == null):
			
			#If the ammount we need to insert into this empty
			#index of the backpack is less than the stack_height_limit
			#of the item, then we can just insert it all and exit
			#with success
			if (ammount <= BLOCK.stack_height_limit):
				insertAtIndex(BLOCK, index, ammount);
				stuffFullyInserted = true;
				index = index + 1;
				return stuffFullyInserted;
				pass;
			
			#If we have more ammount to insert than we can
			#put into this empty stack, we will insert as much
			#as this item can stack to "stack_height_limit" and will
			#keep looking for more empty indexs in the next indexs
			#of the Backpack in this for loop at ID: 983274274.
			if (ammount > BLOCK.stack_height_limit):
				
				#The added ammount is the max stack limit,
				#since its and empty index.
				var addedAmmount = BLOCK.stack_height_limit;
				
				#Insert the "addedAmmount" (the stack height limit),
				#into the empty index.
				insertAtIndex(BLOCK, index, addedAmmount);
				
				#Update the ammount left to insert,
				#factoring in the fact that we just added
				#the "addedAmmount" to the empty index.
				ammount = ammount - addedAmmount;
				
				pass;
			
			pass;
		
		#Increment the current index we are on.
		index = index + 1;
		
		pass;
	
	#If we didn't insert everything fully, we will return
	#false, saying we didn't fully insert everything
	#as an exit status.
	return stuffFullyInserted;
