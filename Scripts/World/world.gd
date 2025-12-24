#This script controls the world and how fragments spawn. 
#MAIN Script.  

extends Node

#Instance of the debugWindow to print logs
var debugWindow;

#Scenes
var fragmentScene = preload("res://Scenes/World/Fragment.tscn"); #Use fragments to makeup the world
var playerScene = preload("res://Scenes/Player/Player.tscn"); #Instance of the player
var mainMenuScene : String = "res://Scenes/UserInterfaces/MainMenu.tscn"; #Path to the main menu

#Player
var player = playerScene.instantiate();

#fragments array
#Array contains instances of every loaded fragment that
#has been fully rendered in the world
var fragments = []; #Array contains all fragments currently loaded into the world

#Entities array.
#Array contains instances of every entity currently spawned
#in the world, which includes all monsters, creatures, players (online +
#themselves)
var entities = [];

#fragments to render array.
#Array holds corrdinates of every fragment that needs to be
#rendered into the world.
#Acts as a queue of fragments to render
var fragmentsRenderQueue = [];

#Frag point
var fragPoint : Vector3 = Vector3(0.0, 0.0, 0.0);



#These variables represent the x and z lengths of the world (think above perspective).
var worldWidth = global_variables.renderDistance * 2;
var worldHeight = global_variables.renderDistance * 2;

#Instance of the main menu scene.
#Holds all UI for the main menu when
#starting the game, creating worlds, etc.
var mainMenu;


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
	
	#Update the total amount of frames/cycles that have happened
	#since the app booted.
	#Increments the cycles by 1.
	#"global_variables.application_cycles" is the total
	#cycles that have passed.
	updateApplicationCycles();
	
	pass;


#Monitor input and keybinds.
#If a specific keybind is pressed while the world is
#running, we assign actions to functions to run here
func _input(event) -> void:
	
	pass;




func _ready() -> void:
	
	#Set world data and paramters
	#from the World Save File.
	#Terrain/Biome seeds, player pos
	#and other data will be pulled from
	#the save file and intialized
	initSaveData();
	
	#Starts the main menu if "global_variables.in_main_menu" is true.
	#The entire "World" scene will be thrown out and we will load into
	#the main menu scene as the main scene.
	#If "in_main_menu" is false, we ignore going into the main menu
	#and load straight into the world scene, starting the game.
	#"global_variables.in_main_menu" is true by default.
	if (global_variables.in_main_menu == true):
		startMainMenu();
	
	#Sets the players spawn positon
	#based on saves or RNG if its a new
	#world.
	spawnPlayer();
	
	#Render in the entire world by adding
	#all fragments within render distance of the fragpoint
	#to the render queue and loading the entire queue
	#before leaving this function.
	#If we are entering the start menu,
	#then don't load this.
	if (global_variables.in_main_menu == false):
		renderWorld_instant();
	
	#Setup the instance of the debug window so we can log
	#the output box if needed
	debugWindow = $Player/CameraPivot/Camera3D/DebugWindow/DebugWindowPanel/OutputBoxPanel/OutputBox;
	
	#Unlock the players gravity,
	#since the world has rendered in
	$Player.axis_lock_linear_y = false;
	
	pass;


#Spawns the player into the world and determines
#there starting position based on previous saves,
#or RNG if starting a new world.
func spawnPlayer() -> void:
	
	add_child(player); #Add the player into the world
	
	#Add the player (the user) to the entities list,
	#so we can enusre that we don't place blocks,
	#or stuff on the player and use the players position
	#to check other things.
	entities.append(player);
	
	#Set the players spawn position for the Y corrdinate after the world has spawned in.
	#If no save is detected "playerSpawnPos = null", we will use
	#a default spawn for the player
	var playerSpawnPos = WorldSaveSystem.loadSpawn();
	
	#If the player has no saved spawn position, spawn the player
	#within a 100*100 radius of (0, 0).
	if (playerSpawnPos == null):
		#Generate a random (x, z) starting position
		#between 100 * 100 of (0, 0)
		#Add ".5" to center the player with a block
		#after we floor the values to be directly
		#at the whole corrdinate (no floating points)
		player.position.x = floor(randf_range(-100, 100)) + .5;
		player.position.z = floor(randf_range(-100, 100)) + .5;
		
		#Use the noise_manager to get the terrain height the
		#player will spawn at, then add a 5.0 margin of error
		#to it, ensuring the player spawns above the terrain.
		player.position.y = noise_manager.getTerrainHeightNoise(Vector2(player.position.x, player.position.z)) + 5.0;
	#If the player has save data, then we willl set
	#the players position to the save data.
	#We will also add an increse to Y corrdinate,
	#ensuring the player doesn't somehow fall out of the world.
	else:
		$Player.position.x = playerSpawnPos.x;
		$Player.position.y = playerSpawnPos.y + 0.1;
		#Lock all linear Y movement, so the player cannot
		#fall from gravity until everything loads in.
		$Player.axis_lock_linear_y = true;
		$Player.position.z = playerSpawnPos.z;
		$Player.rotation.y = playerSpawnPos.w;
	
	#Update the frag point since we
	#changed the players position.
	updateFragPoint();
	
	pass;

#Sets the world and player parameters
#from the world save file. (Example: biome/terrain
#seeds, player pos, etc).
func initSaveData():
	
	#Retirve the seed from "\meta\meta.gemd",
	#and set the seed for the noise_manager
	#so we can generate all terrain, biomes, structures,
	#etc.
	noise_manager.seed = WorldSaveSystem.getMetaData("seed");
	noise_manager.setup_worldTerrainNoise();
	noise_manager.setup_worldBiomeNoise();
	
	pass;



#Exits the world scene and restarts the main
#scene as the main menu.
#When this is called, the entire World Scnene
#is reset, and the only nodes running are the main menu,
#as if (and is) it was the main scene.
func startMainMenu() -> void:
	
	#Restart the main scene as the main menu scene.
	#Loads the path in string "mainMenuScene" as the
	#current scene.
	get_tree().change_scene_to_file(mainMenuScene);
	
	pass;





#Updates "global_variables.application_cycles" a 64 bit integer containing
#the total cycles/frames that have passed since the application booted.
#This method is called in "_process()" in the main scene "world.gd".
#Runs once each frame.
func updateApplicationCycles() -> void:
	
	#Increment the application cycles by 1,
	#since 1 frame will pass after this cycle/frame.
	global_variables.application_cycles += 1;
	
	pass;






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



#Very similar to "renderWorld()" in "world.gd".
#Renders the entire world within 1 frame, instead of
#rendering from a queue over a period of time.
#Checks the entire render distance, adds everything not rendered to
#the render queue "fragmentsRenderQueue[]", then renders the entire
#queue before exiting the function.
func renderWorld_instant() -> void:
	
	#Check around the entire render distance of the
	#frag point, and add any missing fragments to the render queue.
	renderQueueWorldAroundFragPoint();
	
	#Keep rendering the next fragment in the queue from
	#the top until there is no fragments in the render queue anymore.
	while (fragmentsRenderQueue.is_empty() != true):
		renderWorldFromQueue();
	
	#We are returning from this function, so every fragment that
	#was in the fragment queue has now been rendered.
	pass;




#Renders the world around the fragpoint (the players location)
#Derenders and removes old fragments that are no longer within render distance
#of the frag point.
#Renders in fragments from the render queue.
func renderWorld() -> void:
	
	#Check around the fragpoint within render distance.
	#Find any fragments that aren't render in or in the render queue,
	#and add them to the render queue.
	#We do this periodically (every few frames)
	#to add fragments to render to the render queue
	#as the fragpoint moves as we move around the world.
	#NOTE: Runs every 50 frames
	if (global_variables.application_cycles % 50 == 0):
		renderQueueWorldAroundFragPoint();
	
	
	#Renders the next fragment position at the top of the queue to be
	#render/loaded into the world.
	#By using a queue to remove fragments, we greatly reduce
	#hickups in FPS by loading everything at once between 2 frames
	#NOTE: Runs every 5 frames
	if (global_variables.application_cycles % 5 == 0):
		renderWorldFromQueue();
	
	#Derender and remove old fragments
	#that are no longer within render distance
	#of the fragpoint. These fragments
	#are removed from the scene and cleared
	#from RAM.
	#NOTE: Runs every 100 frames
	#if (global_variables.application_cycles % 100 == 0):
	derenderOldFragments();
	
	
	pass;



#This function searchs around the fragpoint for any
#fragments that haven't yet been rendered within render distance,
#and adds them to the render queue.
#These fragments will then be rendered in by the render queue,
#preventing FPS drop from rendering all fragments in one frame/go.
func renderQueueWorldAroundFragPoint() -> void:
	
	#We go along the height and the width of the world (from top down perspective)
	#and are checking each valid fragment position within render distance of the fragpoint.
	#If the fragment doesn't exist, and is not within the render queue, we will add the fragment
	#to the render queue to be render in later to prevent FPS drops.
	#In this loop are conditions checking if the fragment exists, is in render queue, and
	#an operation to add it to the render queue if its not detected in each condition
	#(I.E. it doesn't exist, and is't queued for render.
	#Data reguarding the fragment position we are checking and booleans regaurding
	#its existance or existance in the render queue are also present.
	for HEIGHT in worldHeight:
		for WIDTH in worldWidth:
			
			#Booleans reguarding as to weather the current fragment position we are checking
			#has a fragment already rendered in, or if the position is queued to render a fragment.
			#Both booleans are false by default.
			#If even one is true, this iteration will end.
			var fragmentExists : bool = false;
			var fragmentIsQueuedForRender : bool = false;
			
			#Fragment position we are checking for a fragments existance in the world
			#or in the render queue. Set to all zeros here by default, 
			#we use the current HEIGHT and WIDTH we are checking in the world,
			#along with render distance, to determine which position we check.
			#Y-axis is redundent and doesn't matter.
			var fragmentPosition : Vector3 = Vector3(0.0, 0.0, 0.0);
			
			#Here we set the fragment position we are going to check for a fragment.
			#Notice how Y-axis isn't included, as this is redundent.
			#EXAMPLE:
			#-We start with the x axis
			#We take the fragpoint.x, then take the render distance (in fragments) and convert
			#it to blocks/units by multiplying by 10. From here, we go that distance back,
			#then add the WIDTH (fragment in the rows number) * 10 to convert to units/blocks to it,
			#and we have the x position of the fragment space to check.
			fragmentPosition.x = fragPoint.x - (global_variables.renderDistance * 10) + (WIDTH * 10);
			fragmentPosition.z = fragPoint.z - ((global_variables.renderDistance) * 10) + (HEIGHT * 10);
			
			#We are checking to see if the fragment physically exists, as the positions
			#we are checking are fragment positions within render distance of the fragpoint.
			#If the fragment exists, and is render in. We set "fragmentExists" to true,
			#so that at #ID: 736ddhe, we can skip the rest of this iteration and check the next
			#fragment position within render distance of the fragpoint.
			for FRAGMENT in fragments:
				if (FRAGMENT.position.x == fragmentPosition.x && FRAGMENT.position.z == fragmentPosition.z):
					fragmentExists = true;
			
			#ID: 736ddhe
			#We detected the fragment physically exists in the world.
			#Since it already exists, we don't need to do anything and
			#can exit the iteration, checking for the next fragment
			#position.
			if (fragmentExists == true):
				continue;
			
			
			#We determined the fragment doesn't physically exist in the world,
			#now we need to check if its in the render queue. If the fragment
			#position we are checking is in the render queue, then we set "fragmentIsQueuedForRender"
			#as true, allowing us to exit this iteration later and check for the next
			#fragment position.
			#We use the data from "fragmentIsQueuedForRender" @ ID: qwerty728nfh
			for FRAGMENT in fragmentsRenderQueue:
				if (FRAGMENT.x == fragmentPosition.x && FRAGMENT.z == fragmentPosition.z):
					fragmentIsQueuedForRender = true;
			
			#ID: qwerty728nfh
			#We detected that the fragment we are searching for doesn't exist,
			#but is in the render queue, so we will do nothing and check the next
			#fragment position by skipping the rest of this iteration.
			if (fragmentIsQueuedForRender == true):
				continue;
			
			#The fragment position we are checking, which is within render distance of the fragpoint
			#has been detected at this point to not exist and is not currently queued for render.
			#We will add the corrdinates a fragment should exist at to the render queue now.
			#We append the position the fragment should exist at to the render queue, so it will render
			#in.
			fragmentsRenderQueue.append(fragmentPosition);
			
			pass;
	pass;




func renderWorldFromQueue() -> void:
	
	#If the render queue is completely empty,
	#then exit this function, there is nothing else to
	#render! Once it has an index in it again, we can
	#keep rendering.
	if (fragmentsRenderQueue.is_empty()):
		return;
	
	var newFragment = fragmentScene.instantiate();
	
	newFragment.position.x = fragmentsRenderQueue[0].x;
	newFragment.position.z = fragmentsRenderQueue[0].z;
	#Add the temporary fragment to the scene, adding it "permently". 
	#"newFragment" is irrelevant from this point on.
	add_child(newFragment);
	fragments.append(newFragment);
	if (fragmentsRenderQueue.is_empty() == false):
		fragmentsRenderQueue.remove_at(0); #Remove the top of the arrayaa
	
	pass;






#Used in "renderWorld()"
#Loops through the array "fragments[]" checking all rendered fragments
#in the world. Any fragment that is "global_variables.renderDistance" away
#from the fragpoint is derendered and removed from the scene/world.
func derenderOldFragments() -> void:
	
	#Max and min possible corrdinates of fragments that are rendered in. Anything below
	#or above should be derendered.
	#minX = the lowest x corrdinate of the x-axis
	#maxZ = the max z corrdinate of the z-axis, etc
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
			
			#Before removing the old fragments from the scene
			#when there being derendered, we write the contents
			#of them to a save file, so we don't lose progress
			#or regenerate fragments
			WorldSaveSystem.saveFragment(FRAGMENT);
			
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
		
		#BROKEN CODE:
		#This was removed and fragmend.loadAirBlock() began working.
		#Likely a crutch because "pos.x < FRAGMENT.position.x + global_variables.fragmentSideLength"
		#was originally "pos.x <= FRAGMENT.position.x + global_variables.fragmentSideLength"
		#if (FRAGMENT.position.x + global_variables.fragmentSideLength >= pos.x + global_variables.fragmentSideLength):
		#	continue;
		
		
		#.Check each fragment in "fragments" array. Make sure the x and z corrdinates are both between the min and max corrdinates on each axis
		if (pos.x >= FRAGMENT.position.x && pos.x < FRAGMENT.position.x + global_variables.fragmentSideLength && pos.z >= FRAGMENT.position.z && pos.z < FRAGMENT.position.z + global_variables.fragmentSideLength):
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
#pos = The position of the block/object to remove. If the object is within these corrdinates, remove it.
#source -> the source of the removal (player, the code, etc)
#        -"PLAYER" -> The player called the removal block function
#        -"MACHINE" -> The code called the remoal of the block
func removeBlock(pos : Vector3, source : String) -> bool:
	
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
	blockRemoved = fragmentContainingBlock.removeBlock(pos, source);
	
	
	#Return the status if a block was removed or not
	#as type bool.
	#If block removed, true, else: false.
	return blockRemoved;



#Writes all loaded fragments to a save file before exiting the world
func exitAndSave():
	
	#Send each fragment loaded in currently in "fragments"
	#into the WorldSaveSystem to write all there contents to a file
	#to be saved.
	for fragment in fragments:
		WorldSaveSystem.saveFragment(fragment);
		pass;
	
	#Save the players backpack (inventory)
	#to the player save folder
	WorldSaveSystem.saveInventory($Player/CameraPivot/Camera3D/ToolBeltCanvasLayer/ToolBelt.items);
	
	#Save the players spawn location
	#to the player save folder
	WorldSaveSystem.saveSpawn($Player.position, $Player.rotation.y);
	
	#Once everything in the world has been saved
	#exit to the main menu.
	get_tree().change_scene_to_file(global_variables.titleScreen);
	
	pass;



#A test function that prints a message when
#called. This function has no use
#anywhere and can be safely deleted if
#needed.
func testFunc():
	
	print("Checksum!");
	
	pass;
