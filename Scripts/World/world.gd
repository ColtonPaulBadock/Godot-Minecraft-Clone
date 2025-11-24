#This script controls the world and how fragments spawn. 
#MAIN Script.  

extends Node

#Instance of the debugWindow to print logs
var debugWindow;

#Scenes
var fragmentScene = preload("res://Scenes/World/Fragment.tscn"); #Use fragments to makeup the world
var playerScene = preload("res://Scenes/Characters/Player.tscn"); #Instance of the player

#Player
var player = playerScene.instantiate();

#fragments array
var fragments = []; #Array contains all fragments currently loaded into the world

#Frag point
var fragPoint : Vector3 = Vector3(0.0, 0.0, 0.0);


func _process(delta: float) -> void:
	
	#Every frame, we update the "fragpoint", a Vector3 position (y is useless/not important)
	#of the fragpoint for the player. This point is the center most point
	#of the world and is what the world renders around. It moves position between
	#fragments with the player so we can keep the world rendered around them.
	#This function updates the point every frame.
	updateFragPoint();
	
	#Render the world around the fragpoint, which is updated by "updateFragPoint()"
	#each frame.
	renderWorld();
	
	
	
	pass;



func _ready() -> void:
	
	#Set the players spawn position for the Y corrdinate after the world has spawned in.
	player.position.y = 95;
	
	add_child(player); #Add the player into the world
	
	#TEST CODE
	#updateFragPoint(); #Updates the fragment point based on the player position.
	
	renderWorld(); #Render the world around the fragpoint
	
	#Setup the instance of the debug window so we can log
	#the output box if needed
	debugWindow = $Player/CameraPivot/Camera3D/DebugWindow/DebugWindowPanel/OutputBoxPanel/OutputBox;



#Updates the frag point based on the players position.
func updateFragPoint():
	
	#Player world corrdinates, used to set the frag point based on the players position.
	#"int()" is used to eliminate the decimal place. This place value doesn't matter as if modulus worked with floats, we would eliminate the decimal anyway.
	#Decimal places are irrelevant for determining and using fragpoint
	var playerX = int(get_node("Player").position.x);
	var playerZ = int(get_node("Player").position.z);
	
	#Set the frag point to the nearest number divisble by 5, rounding down.
	#The frag point exists every 10 units (1 fragment) in the world.
	fragPoint.x = playerX - (playerX % 10);
	fragPoint.z = playerZ - (playerZ % 10);
	
	pass;


#Renders the world around the fragpoint (the players location)
func renderWorld() -> void:
	
	#Devlog the rendering world, so we know each time this system runs.
	print("Rendering the world around the player|world.gd, renderWorld()");
	
	#The width of the world is double the render distance, as render distance can be thought of as a radius around the player, we are getting "diameter" for the world.
	#width = "-" parallel to x-axis
	var worldWidth = global_variables.renderDistance * 2;
	#The height of the world is double the render distance, as render distance can be thought of as a radius around the player, we are getting "diameter" for the world.
	#height = "|" parallel to z-axis
	var worldHeight = global_variables.renderDistance * 2;
	
	#RENDER THE WORLD AROUND THE FRAGPOINT
	#Check around the fragpoints render distance. If a fragment is missing (I.E. it moved and needs to load more fragments) load in the missing fragment
	#Go along each HEIGHT, but do each ROW for every HEIGHT fragment
	for HEIGHT in worldHeight:
		for ROW in worldWidth:
			var fragmentPosition : Vector3 = Vector3(0.0, 0.0, 0.0); #Vector3 to hold the position of the fragment; Ingore Y corrdinate
			var fragmentRendered = false;
			
			#Go all the way to the front (<) of the row, from here count forward until we have reached the next untouched fragment
			#in the row. Stay at the same height throughout the entire row.
			#See "docs" folder for diagram on this system "renderWorld/renderWorldAroundFragPoint."
			fragmentPosition.x = fragPoint.x - (global_variables.renderDistance * 10) + (ROW * 10);
			fragmentPosition.z = fragPoint.z - ((global_variables.renderDistance) * 10) + (HEIGHT * 10)
			
			#Search through each exisitng fragment and see if the fragment we are checking for is rendered in. If it hasn't been renedered yet, keep "fragmentRendered" false.
			#This will allow us to render it in later at ID: 72827s
			for FRAGMENT in fragments:
				if (FRAGMENT.position.x == fragmentPosition.x && FRAGMENT.position.z == fragmentPosition.z):
					fragmentRendered = true;
					pass;
			
			#ID: 72827s
			#If we have determined that the fragment we are checking for has not been rendered in yet,
			#render it in here.
			if (fragmentRendered != true):
				var newFragment = fragmentScene.instantiate(); #Temp fragment instance so we can set its attributes before adding it to the scene
				
				#Set the fragments position to the current fragment position from the fragpoint we are checking, at which it was determined no fragment was rendered yet.
				newFragment.position.x = fragmentPosition.x;
				newFragment.position.z = fragmentPosition.z;
				
				#Add the temporary fragment to the scene, adding it "permently". 
				#"newFragment" is irrelevant from this point on.
				add_child(newFragment);
				fragments.append(newFragment);
			
			pass;
	
	
	#Max and min possible corrdinates of fragments that are rendered in. Anything below
	#or above should be derendered.
	var row_minX = fragPoint.x + (global_variables.renderDistance * -global_variables.fragmentSideLength); #The minimum X-axis value from the fragpoint. Anything less than this needs to be derendered
	var row_maxX = fragPoint.x + ((global_variables.renderDistance - 1) * global_variables.fragmentSideLength);
	var height_minZ = fragPoint.z + (global_variables.renderDistance * -global_variables.fragmentSideLength);
	var height_maxZ = fragPoint.z + ((global_variables.renderDistance - 1) * global_variables.fragmentSideLength);
	
	
	#Derender/remove fragments outside the frag point.
	#Loop through all fragments and there positions.
	for FRAGMENT in fragments:
		
		#If the rows x is less than the minimum x from the fragpoint to be rendered or is larger than the maximum, derender it;
		#Same logic applies for the z-axis (height)
		if (FRAGMENT.position.x < row_minX || FRAGMENT.position.x > row_maxX || FRAGMENT.position.z < height_minZ || FRAGMENT.position.z > height_maxZ):
			
			#Remove the fragment from the scene and take it out of the fragments array (array of loaded/rendered fragments)
			remove_child(FRAGMENT);
			fragments.erase(FRAGMENT);
			FRAGMENT.queue_free();
			
			pass;
		pass;
	
	pass;




#Locate a block from a fragment based on world corrdinates
#Return a instance of the block located, but if a action is required, perform the
#action on that block instead
#
#-Arguments-
#
#worldPos = world position to locate the block at
#
func locateBlockAt(worldPos):
	
	#Corrdinates for the block to locate
	var worldX = worldPos.x;
	var worldY = worldPos.y;
	var worldZ = worldPos.z;
	
	var identifiedFragment = null; #Variable to store the fragment we idenified as containing the block we are looking for.
	var identifiedBlock = null; #Variable will hold the instance of the block if its located
	
	#Using the corrdinates, identify which fragment the block is in.
	for FRAGMENT in fragments:
		
		if (FRAGMENT.position.x + global_variables.fragmentSideLength >= worldX + global_variables.fragmentSideLength):
			continue;
		
		#Check each fragment in "fragments" array. Make sure the x and z corrdinates are both between the min and max corrdinates on each axis
		if (worldX >= FRAGMENT.position.x && worldX <= FRAGMENT.position.x + global_variables.fragmentSideLength && worldZ >= FRAGMENT.position.z && worldZ < FRAGMENT.position.z + global_variables.fragmentSideLength):
			identifiedFragment = FRAGMENT; #If we found the fragment that contains corrdinates that posses the block, set "identifiedFragment" as a instance of this fragment
			pass;
		
		#Found the fragment? Exit this loop.
		if (identifiedFragment != null):
			break;
		
		pass;
	
	#If no fragment could be found that does contain this block, end this function;
	#Continuing would cause error
	#Since no fragment was located, no block can be either, so return null
	if (identifiedFragment == null):
		return identifiedBlock;
	
	
	
	#Convert the world corrdinates to corrdinates of the fragment
	#Subtract the total number of fragment side lengths from each corrdinate (x, y, z) to convert to corrdinates of the local fragment
	var blocksFragmentCorrdinates : Vector3 = Vector3(worldX - (global_variables.fragmentSideLength * (int(worldX / global_variables.fragmentSideLength))), worldY, worldZ - (global_variables.fragmentSideLength * (int(worldZ / global_variables.fragmentSideLength))));
	
	#If any of the corrdinates (x, z) are negative, convert them to the positive corresponding corrdinate for the local fragment.
	#This conversion is simply done by adding the fragments width to the negatve corrdinate.
	#Since all fragments start at there own (0, 0, 0) in there own scene and run positive in the world and there own scene, this converstion works
	#Convert X corrdinate if needed; ID: aestwgdf45
	if (blocksFragmentCorrdinates.x < 0):
		blocksFragmentCorrdinates.x += global_variables.fragmentSideLength;
		pass;
	
	#Based on the same logic described and impleneted at ID: aestwgdf45,
	#convert the corrdinate z to its positive corresponding corrdinate for the local fragment corrdinates.
	if (blocksFragmentCorrdinates.z < 0):
		blocksFragmentCorrdinates.z += global_variables.fragmentSideLength;
		pass;
	
	#ID: hhwidyg37
	#Based on the corrdinates and the known fragment, locate the block
	#Loop through the block array if the fragment until the block is found.
	for BLOCK in identifiedFragment.blocks:
		
		#Search through each block in the "blocks" array of the fragment we determined to contain the block.
		#If the X position of the blocks cordinates are between the start of the block and the end of the block, check the same logic for the z. Then check the same logic again for the y.
		if (BLOCK.position.x <= blocksFragmentCorrdinates.x && BLOCK.position.x + global_variables.blockSideLength >= blocksFragmentCorrdinates.x && BLOCK.position.z <= blocksFragmentCorrdinates.z && BLOCK.position.z + global_variables.blockSideLength >= blocksFragmentCorrdinates.z && BLOCK.position.y <= blocksFragmentCorrdinates.y && BLOCK.position.y + global_variables.blockSideLength >= blocksFragmentCorrdinates.y):
			
			identifiedBlock = BLOCK; #Variable "identifiedBlock" now points to the block we identified by corrdinates.
			
			pass;
		
		
		pass;
	
	
	#If no action is request, return the blocks instance.
	#If a block was found, return the instance of said block.
	#If no instance was found, return null, exiting the function.
	if (identifiedBlock != null):
		return identifiedBlock;
	else: #If no block was found, no action was requested, return null and exit this function.
		return null;
	pass;


#Locates the fragment and returns a instance of it
#locates the fragment based on the first arguent : Vector3
#"pos"
#
#-Arguments-
#
#pos = world position to try to locate the fragment at.
func locateFragmanetAt(pos : Vector3):
	
	var identifiedFragment = null; #Variable to store the fragment we idenified as containing the block we are looking for.
	
	#Using the corrdinates, identify which fragment the pos is in.
	for FRAGMENT in fragments:
		
		if (FRAGMENT.position.x + global_variables.fragmentSideLength >= pos.x + global_variables.fragmentSideLength):
			continue;
		
		#Check each fragment in "fragments" array. Make sure the x and z corrdinates are both between the min and max corrdinates on each axis
		if (pos.x >= FRAGMENT.position.x && pos.x <= FRAGMENT.position.x + global_variables.fragmentSideLength && pos.z >= FRAGMENT.position.z && pos.z < FRAGMENT.position.z + global_variables.fragmentSideLength):
			identifiedFragment = FRAGMENT; #If we found the fragment that contains corrdinates that posses the block, set "identifiedFragment" as a instance of this fragment
			pass;
		
		#Found the fragment? Exit this loop.
		if (identifiedFragment != null):
			break;
		
		pass;
	
	#If the fragment is found, this will be a instance of it
	#If its not found, this will be null.
	return identifiedFragment;


#Adds the block of type "id" to the position in the world
#of Vector3 "pos". If a block is already there, it will not
#be added
#-ARGUMENTS_
#
#pos = Position in the world to add the block to (will nap to 
#nearest grid space)
#
#id = ID of the block to place.
func addBlock(pos : Vector3, id) -> bool:
	
	#If this value is true, the block was successfully placed
	#If its false, the block was not placed
	#This value is set using "addBlock()" from fragment.gd
	#This variable is false by default until the block is
	#placed.
	var blockPlaced = false;
	
	#This variable will hold the fragment we need
	#to place the block in.
	#If its not found, this should remain as null.
	var fragment = null;
	
	#Locate the fragment we are wanting to add the block to.
	#If the fragment isn't found, this will be null and we
	#should exit this function or take approiate measures.
	fragment = locateFragmanetAt(pos);
	
	#If the fragment was not located, exit this function
	#We have no fragment to place the block in!
	if (fragment == null):
		return false;
	
	#Convert the corrdinates from the world
	#position to the locale corrdinates of
	#the fragment, to easily place the block
	pos = worldCordsToFragment(pos);
	
	#Add the block of type "id" to the position in the fragment
	#If the block was successfully placed, this function "addBlock()"
	#in fragment.gd will return false. We will then return this value
	#upon exiting the current function "addBlock()" in "world.gd".
	blockPlaced = fragment.addBlock(pos, id);
	
	return blockPlaced;





#Takes the first argument (float) and converts
#it to corrdinate for a fragment.
#returns float.
#
#-Arguments-
#
#value = value to convert to a local corrdinate for the fragment.
#
func worldCordsToFragment(value):
	
	#Here we have a switch like system.
	#If the value "value", passed into the function is
	#a Vector3, then we want to convert the corrdinates within
	#it to the equivalent fragment corrdinates.
	#Can be thought of as: (fragment.pos + fragmentCorrdinates = worldPos)
	#If "value" is a float, we are converting one single corrdinate
	#in this same way, as to be eqivalent within the fragment
	#as it is in the world.
	if value is Vector3:
		value = worldCordsToFragment_Vector3(value);
	elif value is float:
		value = worldCordsToFragment_float(value);
	
	#Once we converted the world corrdinates to the fragments
	#equivalent corrdinates, we can return "value" with the
	#above modifications.
	return value;


#Used by "worldCordsToFragment()"
#This function is not intended to be called anywhere else in the code.
#Takes a float as the first argument, and converts it to
#local corrdinates for a fragment. This will be called
#when a float is based to "worldCordsToFragment()".
#The resaulting value will be eqivalent to the world corrdinate via:
#fragment.pos + value = whatever corrdinate
#-ARGUMENTS-
#
#value = float to assess and convert to a local fragments eqivalent corrdinate.
#
func worldCordsToFragment_float(value : float) -> float:
	
	#If the value of the corrdinate is above 0, then we can use the above
	#system to convert it to the equivalent corrdinate for a fragment.
	#If the value is negative, us the below (inside elif) system to
	#convert the corrdinate to a equivalent for a fragment.
	if (value > 0):
		#If the value is positive:
		#Convert to the eqivalent corrdinate for a fragment:
		value = value - (int((value / global_variables.fragmentSideLength)) * global_variables.fragmentSideLength);
	elif (value < 0):
		#If the value is negative:
		#Convert to the eqivalent corrdinate for a fragment:
		value = value + (10 * (1 + (-1 * int(value / 10))));
		pass;
	
	#Return the value once we are done converting it to
	#a local corrdinate of a fragment, that is equivalent to
	#the world corrdinate, inside the fragment.
	return value;




#Used by "worldCordsToFragment()"
#This function is not intended to be called anywhere else in the code.
#Takes a Vector3 as the first argument, and sets all corrdinates
#in the Vector3 to the local corrdinates of a fragment they would be in,
#if applicable.
#This will be called when a Vector3 is passed to
#"worldCordsToFragment()".
#The resaulting value will be eqivalent to the world corrdinate via:
#fragment.pos + value = whatever corrdinate
#-ARGUMENTS-
#
#value = Vector3 to assess and convert its corrdinates to local corrdinates of a fragment.
#
func worldCordsToFragment_Vector3(value : Vector3) -> Vector3:
	
	#Convert the X variable of the Vector3 to local fragment corrdinates
	#if applicable. If the value already matches that of the local corrdinates,
	#say we are in a fragment close to spawn at x -> 3, then we can just leave it
	#Take appropriate action if x is negative, us the special converstion method
	if (value.x > 0):
		#If the value is positive:
		value.x = value.x - (int((value.x / global_variables.fragmentSideLength)) * global_variables.fragmentSideLength);
	elif (value.x < 0):
		#If the value is negative:
		value.x = value.x + (10 * (1 + (-1 * int(value.x / 10))));
		pass;
	
	#Convert the Z variable of the Vector3 to local fragment corrdinates
	#if applicable. If the value already matches that of the local corrdinates,
	#say we are in a fragment close to spawn at z -> 3, then we can just leave it
	#Take appropriate action if z is negative, us the special converstion method
	if (value.z > 0):
		#If the value is positive:
		value.z = value.z - (int((value.z / global_variables.fragmentSideLength)) * global_variables.fragmentSideLength);
	elif (value.z < 0):
		#If the value is negative:
		value.z = value.z + (10 * (1 + (-1 * int(value.z / 10))));
		pass;
	
	
	#For corrdinate Y, we have implemented fragments for this corrdinate
	#Y is infinently tall and deep. (y > infinity && y < -infinity)
	
	
	#Return the Vector3 value once we are done converting
	#its corrdinates to the local fragments eqivalent.
	return value;


#Removes a block from the scene/world at the provided corrdinates.
#Returns a boolean of true or false, false being no block was destroyed/
#removed and true being a block was removed.
#
#-Arguments-
#
#pos = The position of the block/object to remove. If the object is within these corrdinates, remove it.
func removeBlock(pos : Vector3) -> bool:
	
	#If this variable is true, we successfully removed a block
	#from the fragment/scene/world.
	#If false, we did not.
	#This variable is false by default, until its changed.
	var blockRemoved : bool = false;
	
	
	#This variable will contain the fragment the block
	#is located in. This variable is null by default,
	#so if a fragment is not identified, we can
	#regonize that and exit this function without
	#calling methods on the null instance and causing
	#issues.
	var fragmentContainingBlock = null;
	
	
	#First, we need to identify the fragment the block we need
	#to remove is in. Once we know the fragment its in, we can use
	#the fragments utilities to remove that specific block
	#Pass "pos" into the function "locateFragmentAt()" to
	#locate the fragment via world corrdinates.
	#Pos is the position of the block we want to remove.
	fragmentContainingBlock = locateFragmanetAt(pos);
	
	#If no fragment is identified at the world corrdinates
	#at position "pos", then exit this function returning
	#"false", the default value of "blockRemoved" which is
	#the boolean status of if we removed a block or not.
	if (fragmentContainingBlock == null):
		return blockRemoved;
	
	#The fragment we want to remove the block from is found
	#so now we need to use the fragments utility "removeBlock()"
	#to remove the block (assuming on exists). We convert
	#"pos" (world corrdinates) to the locale fragment corrdinates
	#before attempting to remove the block via fragments utility.
	#Set "blockRemoved" (bool) to the status of if a block was removed.
	#If true, a block was removed. false, a block/object wasn't removed.
	#Convert both X and Z corrdinates to fit the local fragments corrdinates.
	#We will use "worldCordsToFragment()" to accomplish this.
	pos = worldCordsToFragment(pos);
	blockRemoved = fragmentContainingBlock.removeBlock(pos);
	
	
	#Return the status if a block was removed or not
	#as type bool.
	#If block removed, true, else: false.
	return blockRemoved;
