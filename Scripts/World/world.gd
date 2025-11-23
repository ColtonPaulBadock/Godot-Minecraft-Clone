#This script controls the world and how fragments spawn. 
#MAIN Script.  

extends Node

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
	
	updateFragPoint(); #Updates the fragment point based on the player position.
	
	#renderWorld(); #Render the world around the fragpoint
	
	pass;


func _ready() -> void:
	
	#Set the players spawn position for the Y corrdinate after the world has spawned in.
	player.position.y = 58;
	
	add_child(player); #Add the player into the world
	
	#TEST CODE
	#updateFragPoint(); #Updates the fragment point based on the player position.
	
	renderWorld(); #Render the world around the fragpoint


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
			FRAGMENT.free();
			
			pass;
		pass;
	
	pass;




#Locate a block from a fragment based on world corrdinates
#Return a instance of the block located, but if a action is required, perform the
#action on that block instead
#
#-Actions list-
#-"DESTROY" -> Removes the block from the scene, world, fragment and block array of the fragment
#-"CREATE" -> Creats a block based on "id"
#
func locateBlockAt(worldPos, action : String, id):
	
	#Corrdinates for the block to locate
	var worldX = worldPos.x;
	var worldY = worldPos.y;
	var worldZ = worldPos.z;
	
	var identifiedFragment = null; #Variable to store the fragment we idenified as containing the block we are looking for.
	var identifiedBlock = null; #Variable will hold the instance of the block if its located
	
	#Using the corrdinates, identify which fragment the block is in.
	for FRAGMENT in fragments:
		
		#Check each fragment in "fragments" array. Make sure the x and z corrdinates are both between the min and max corrdinates on each axis
		if (worldX >= FRAGMENT.position.x && worldX < FRAGMENT.position.x + global_variables.fragmentSideLength && worldZ >= FRAGMENT.position.z && worldZ < FRAGMENT.position.z + global_variables.fragmentSideLength):
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
	
	
	#If the "DESTROY" action is requested, and block exists, remove the block.
	#Once the block is removed, return null.
	if (identifiedBlock != null && action == "DESTROY"):
		#Take the fragment determined to contain the block.
		#Take these instances and remove the block from the fragments block array,
		#scene and the world.
		destroyBlock(identifiedFragment, identifiedBlock);
		return null;
	
	
	#If the "CREATE" action is requested, then place the block at the position requested
	if (identifiedBlock != null && action == "CREATE"):
		placeBlockFromPlayer(worldPos, id, identifiedFragment, identifiedBlock);
		pass;
	
	
	#If no action is request, return the blocks instance.
	#If a block was found, return the instance of said block.
	#If no instance was found, return null, exiting the function.
	if (identifiedBlock != null):
		return identifiedBlock;
	else: #If no block was found, no action was requested, return null and exit this function.
		return null;
	pass;


#This function places a block assuming the player did it.
#This function will not work if a block is being placed by code.
#Arguments:
#positionOfBlockPlacement = The corrdinates of the "playerReach" or (raycast),
#this will be used to calulate if the block should be placed on the side or above the block
#being placed on.
#
#blockId: The id of the block/object to place
#
#fragment: The fragment where we identified where the block is being placed
#
#block: The block we are placing the new block on top of, below or on the sides.
func placeBlockFromPlayer(positionOfBlockPlacement, blockId, fragment, block):
	
	#Boolean, if the block was placed, this will become true
	#If true, play the block placing sound.
	var blockSuccessfullyPlaced = false;
	
	#This variable holds true of false value as to wether
	#we found where the block will be placed.
	#If we already determined the blocks placement location
	#we can skip through this function and just place the block.
	var placementLocationFound : bool = false;
	
	#Block check variable
	#This variable will go out 1/8 the the length of a block off the blocks
	#surface that we deterected we placed on and in which side/direction.
	#If we move this distance off the face and a blocks there, then don't allow the
	#placement
	var rangeToCheckForBlock = global_variables.blockSideLength / 0.125;
	
	#The position to place the new block if applicable.
	#var positionToPlaceBlock = Vector3();
	
	#Location of the block placement in the fragments local
	#corrdinates
	#Convert the corrdinates of the block placement location
	#"playerReach" (raycast3D) corrdinates to the fragments
	#local corrdinates
	#Take the worldX of the block placement, and subtract fragmentSideLength (universally 10.0) * the % of worldX and the fragmentSideLength (universally 10.0)
	#Using int() because you can't perform modulous on floats
	var positionOfBlockPlacement_local = Vector3(positionOfBlockPlacement.x - (global_variables.fragmentSideLength * (int(positionOfBlockPlacement.x / global_variables.fragmentSideLength))), positionOfBlockPlacement.y, positionOfBlockPlacement.z - (global_variables.fragmentSideLength * (int(positionOfBlockPlacement.z / global_variables.fragmentSideLength))));
	#Convert negative corrdinates to positive corrdinates for the block placement
	#If WorldX was negative, get the positive equivalent for this fragment for Vector3 "positionOfBlockPlacement_local"
	if (positionOfBlockPlacement_local.x < 0):
		positionOfBlockPlacement_local.x += 10;
		pass;
	#If WorldY was negative, get the positive equivalent for this fragment for Vector3 "positionOfBlockPlacement_local"
	if (positionOfBlockPlacement_local.y < 0):
		positionOfBlockPlacement_local.y += 10;
		pass;
	#If WorldZ was negative, get the positive equivalent for this fragment for Vector3 "positionOfBlockPlacement_local"
	if (positionOfBlockPlacement_local.z < 0):
		positionOfBlockPlacement_local.z += 10;
		pass;
	
	
	#Check to see if the block was placed on top
	#Using the instance of the block we know the player interacted with to place the block,
	#Get this block Y corrdinate (bottom corner of it, as per the scene).
	#Add one universal width of a block to it, and if it equals the position
	#where the "playerReach.y" was detected, the block must have been placed on top.
	if (block.position.y + global_variables.blockSideLength == positionOfBlockPlacement.y):
		
		#We know the block was placed on top of "block" the identified block the players
		#raycast3d "playerReach" hit, so place the block using "addBlock()" system in fragment
		#Add the block to the position the player requeste to place it.
		fragment.addBlock(positionOfBlockPlacement_local, 1);
		blockSuccessfullyPlaced = true; #set to true, so the block placing sound plays
		
		pass;
	
	
	
	
	
	
	
	#If the block was placed, play the "placeObject" sound.
	if blockSuccessfullyPlaced == true:
		global_variables.AudioManager.placeObject.play();
	
	pass;


#Takes a instance of a "fragment" and a instance of a "block" inside the fragment
#It the removes the block from the fragment scene, blocks array and scene tree, etc.
func destroyBlock(fragment, block) -> void:
	
	#Remove the block from the fragments block array.
	#Then remove the block from the fragments scene.
	fragment.blocks.erase(block);
	fragment.remove_child(block);
	global_variables.AudioManager.breakObject.play(); #Play the audio for breaking a block/object when said block/object is removed
	
	pass;
