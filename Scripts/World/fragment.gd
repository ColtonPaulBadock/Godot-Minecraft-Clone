extends Node3D

#Size of the fragment in the positive corrdinate directions
#9.5, 29.5, 9.5
var fragmentSize : Vector3 = Vector3(10.0, 30.0, 10.0);

#All blocks currently in the fragment.
var blocks = [];

#All illegal (debug) blocks
#used for world generation or other
#features of the game.
#-----
#These blocks should not be attainable
#by the player!
var illegal_blocks = [];

#Random number generator for world generation
var rng = RandomNumberGenerator.new(); #Generates random numbers

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	generateFragment(); #Generate the fragment
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


#Renders the fragment for the world
#Uses noise generator (such as perlin noise)
#from "noise_manager.gd" to generate the terrain at
#the given position in the world
func generateFragment():
	
	#We use this variable throughout this fragment
	#generator to know if a fragment was already generated or not.
	#If we already loaded in a fragment via a save file,
	#then we can set this variable to true, and not
	#generate it fresh from the seed since it already exists.
	var fragmentAlreadyGenerated = false;
	
	#ID: 11117483789473
	#Once we create a new fragment, we need to check if a
	#save file that can later accompany it exists.
	#If it doesn't, then we are creating a new save area
	#for the fragment and others nearby
	if (WorldSaveSystem.checkIfSaveFileExists(self) == false):
		WorldSaveSystem.createSaveFile(self);
		pass;
	
	#We already checked to see if a save file
	#existed that could hold this fragment, at
	#this point we know for sure a save file was
	#created for it at ID: 11117483789473
	#Now we need to see if the fragment
	#itself exists with save data.
	#If its already been generated and is saved
	#we will load in the fragment instead of generating
	#We will set "fragmentAlreadyGenerated" to true
	#so we don't generate it again and will then load
	#this fragment from saved data.
	#If the fragment doesn't exist, we will generate it
	#at ID: 7892379487247
	if (WorldSaveSystem.checkIfFragmentIsSaved(self) == true):# && self.global_position.x == -100.0 && self.global_position.z == -100.0):
		
		#Load the fragment from save data,
		#as we determined it exists in save files.
		loadTerrain();
		
		#No need to generate terrain/fragment via noise,
		#we already have its generation/status saved in the
		#games save files.
		fragmentAlreadyGenerated = true;
		
		pass;
	
	#ID: 7892379487247
	#Generate in the worlds terrain before spawning trees, plants
	#strutures, etc.
	#Here we just layout world height, biomes and the actual land
	#before spawning anything on top of it.
	if (fragmentAlreadyGenerated != true):
		generateTerrain();
	
	pass;


#Loads this current fragment from
#saved data instead of generating it
#based on noise and seeds like in "generateTerrain()".
func loadTerrain() -> void:
	
	#The block/object data being returned
	#from the fragments save data.
	#Contains position, block id, etc.
	#When "-1", we hit the end of the
	#save data for the fragment.
	var blockData = [0];
	
	#Get the save_data for the fragment
	#ready, set the index to the start of the
	#fragment data on the WorldSaveSystem's end
	WorldSaveSystem.loadFragment(self);
	
	#Keep pulling blocks using the "WorldSaveSystem.feedFragment()" utility,
	#and then add said blocks to the fragment from the save data.
	#Once "-1" is returned, we hit the end of the save
	#data for the fragment, so we will exit this function as the fragment
	#is fully loaded.
	while (typeof(blockData) != TYPE_INT):
		
		#Position of the block, which
		#will be set from the block data coming from
		#the save file.
		var blockPos : Vector3;
		
		#The block data returned from the save file
		#if "-1", the end of the file/save data is reached and
		#we will exit.
		blockData = WorldSaveSystem.feedFragment();
		
		#If "-1", no more blocks are left
		#in the save data, so we will move on.
		if typeof(blockData) == TYPE_INT:
			if (blockData == -1):
				continue;
		
		#Set block position using save data
		blockPos.x = blockData[0];
		blockPos.y = blockData[1];
		blockPos.z = blockData[2];
		
		#Add the block with saved position and id.
		addBlock(blockPos, blockData[3]);
		
		pass;
	
	pass;



#This function is a sub/child-function of "generateFragment()".
#Here we spawn in the fragments terrain.
#On top of this terrain we can spawn structures, etc.
#The terrain is created using noise from "noise_manager.worldTerrainNoise"
func generateTerrain() -> void:
	
	#This variable is a reference to the block
	#of the top layer of the world.
	#We use this variable later determining if the block
	#we are generating will be at the very top of the world
	#I.E. it is a surface block
	#Used at ID: poqlsj
	var topLayerBlock = global_variables.worldDepth - 1;
	
	#This variable is a temporary variable.
	#It is used to hold the instance of current block/object
	#currently being generated/evaluated
	#Null by default
	var block = null;
	
	#Sweep through the fragment in a grid like patter.
	#(using local corrdinates to the fragment). We will
	#start at X = 0, then start on Z = 0 and do all the
	#Y corrdinates before incrementing to X = 0, Z = 1, Y = 0;
	#Once we reach the end of Z (10 blocks in) we will
	#increment X and go the next row, etc.
	#Using these for-loops below, we will evaluate/generate the
	#fragment in the grid order
	for block_x in fragmentSize.x:
		for block_z in fragmentSize.z:
			
			#Based on "global_variables.worldDepth" this is how
			#far down we want to spawn/evaluate Y.
			#For example, if "global_variables.worldDepth" = 2,
			#we will only generate the top layer, and 1 layer down
			#ID: dhhtay
			for block_y in global_variables.worldDepth:
				
				#We start by generating from the bottom of the world
				#up, so if we are at the top layer block, set it based on
				#the biome of world condition we are in.
				#This statement will run if we are spawning the top
				#block/layer in this fragment.
				#ID: poqlsj
				if (block_y == topLayerBlock):
					#Generate the top block based on which biome
					#we are in. Biome is determined by "noise_manager.worldBiomeNoise".
					block = generateBiome(block, block_x, block_z);
					#block = global_variables.block_table[1].instantiate();
					
				#If the block we are spawning is not on the surface layer
				#I.E. we have not generated the world to its full depth
				#set by variable "global_variables.worldDepth", then
				#make it a topsoil block
				else:
					block = global_variables.block_table[2].instantiate();
				
				
				
				block.position.x = (block_x); #Corrdinate x is the row in the x corrdinate we are on.
				block.position.z = (block_z); #Corrdinate z is the row in the z corrdinate we are on from the for loops, creating on full layer.
				
				
				#ID: hdysyagsg
				#Now set the blocks world Y height based on the
				#"noise_manager.worldTerrainNoise"
				#Basically, we want to get the world position of the block so for x for example,
				#we do "block_x" which is the local fragment x position of the block in the fragment.
				#Then we add the world position of the fragment to it, getting the exact position
				#of where the block is in the world. We then take this world position
				#and pass it to "worldTerrainNoise", which is the FastNoiseLite engine for
				#our world terrain noise (perlin, simplex) and get the noise value from
				#the engine at the specific corrdinate for our blocks Y-height.
				#Then we can amplify it and modify it with various variables like our height modifier "worldTerrainNoise_heightAmplifier"
				#"+ block_y" the current 'layer' the generateTerrain() system is looping through. We start with the noise at the bottom
				#of the rendered world and work our way up, by adding "+ block_y" we are saying the last part
				#of this for loop will be the top layer of the world.
				#"+ global_variables.medianWorldLayer" takes into account negative noise.
				#This adds a buffer zone for the top world layer to spawn in with mountains and valleys,
				#without the risk of dropping below Y=0.
				block.position.y = ((1 * (noise_manager.worldTerrainNoise_heightAmplifier * noise_manager.worldTerrainNoise.get_noise_2d(block_x + global_position.x , block_z + global_position.z))) + block_y) + global_variables.medianWorldLayer;
				
				addBlock(block.position, block.block_id);
				
				#-ORPHAN NODE PROBLEM SOLVED AFTER 1 WEEK!!!!-
				#9/18/2025. I was instantiating a instance of "block", then passing it to
				#"addBlock()" just to pull data from it and create a whole new block via instancating,
				#effectively creating two instances of the block, with one not being added.
				#Free the extra instance of the block from RAM.
				block.queue_free();
				
				pass;
			
	
	pass;



#This function is a child/sub-function of "generateTerrain()"
#We set a blocks type based on the biome.
#This function takes in a instance of the block being assesed/spawmed in
#"generateTerrain()" and sets the blocks id based on the current biome noise
#from "noise_manager.worldBiomeNoise".
#This function will also take in the blocks local x and z corrdinates
#se we can figure out where in the world the block is, to reference the
#"noise_manager.worldBiomeNoise" noise map.
#
#-Arguments:-
#
#BLOCK: This is the instance of the block we are currently setting the ID for based on the biome noise
#
#BLOCK_X: The blocks local fragment x corrdinate, for determining global block position with
#/paired with fragments global corrdinates.
#
#BLOCK_Z: The blocks local fragment z corrdinate, for determining global block position with
#/paired with fragments global corrdinates.
#
#
func generateBiome(BLOCK, BLOCK_X, BLOCK_Z):
	
	#Take the blocks local X and Z corrdinates in the fragment, and add the global fragment position
	#in the world to them. "BLOCK_X + global_position.x" for example, adds the global position
	#of the fragment and th blocks local position in the fragment togther. Doing this, we find
	#the blocks exact position in the world. From here, we can derive a noise value from
	#the "worldBiomeNoise", which we then use this noise value to determine which biome
	#the block/area is in. However, before determining the the noise value by inputing corrdinates
	#into "get_noise_2d()", we multiply each corrdinate by "noise_manager.biomeSizeMultipler",
	#which shrinks or expands the corrdinates, effecting the biome size, as described at the variables
	#declartion in "noise_manager".
	var noiseValue : float = noise_manager.worldBiomeNoise.get_noise_2d((BLOCK_X + global_position.x) * noise_manager.biomeSizeMultipler, (BLOCK_Z + global_position.z) * noise_manager.biomeSizeMultipler);
	
	
	#Based on the noise value from the position we are in, in the fragment,
	#determine which biome we are in and set the blocks id accordingly.
	#Uses "identifyBiome()" from "noise_manager" which is a system
	#that returns a legal biome type based on the amount of noise
	#at the position.
	#
	#We detected a grassland, so build the desert block accordingly
	#based on noise and the known biome
	if (noise_manager.identifyBiome(noiseValue) == "GRASSLAND"):
		BLOCK = global_variables.block_table[1].instantiate();
	#We detected a desert, so build the desert block accordingly
	#based on noise and the known biome
	elif (noise_manager.identifyBiome(noiseValue) == "DESERT"):
		BLOCK = global_variables.block_table[5].instantiate();
	#Somehow, nothing was detected or a unexpected value was returned,
	#so make the biome dark blocks.
	else:
		BLOCK = global_variables.block_table[0].instantiate();
	
	return BLOCK;





#Adds a block of type "id" to the fragment.
#Whatever block space the "pos" falls into is the grid space the block will occupy
#Returns true if the block was placed successfully
#ARGUMENTS:
#pos = Position/Corrdinates to add the block
#id = id of the object/block (its type).
func addBlock(pos : Vector3, id) -> bool:
	
	#Remove the decimal on the block to adds position, so that it is
	#aligned with the grid space.
	pos.x = int(pos.x);
	pos.y = int(pos.y);
	pos.z = int(pos.z);
	
	#Loop through "blocks[]" in the fragment, to insure no
	#blocks are already in these corrdinates, if so, abort
	for BLOCK in blocks:
		#If the request placement corrdinates already match an existing block,
		#then don't place a block and exit this function.
		if (BLOCK.position.x == pos.x && BLOCK.position.y == pos.y && BLOCK.position.z == pos.z):
			return false; #If a block already occupies the spot in the fragment, return false, placing no block
		pass;
	#Create a temporary instance of the block "block", use
	#global block table to select the right type of block
	#passed on argument of this function "id"
	var block = global_variables.block_table[id].instantiate();
	
	#The "pos" (position) we formated at ID: 37hstag to match the corrdinate grid
	#can now be set as the blocks position
	block.position = pos;
	
	#Add the block to the "blocks[]" array and the fragment scene
	blocks.append(block);
	add_child(block);
	
	#Assuming at this point that no block was in the way, no obstructions
	#occured and that the block was placed, return true.
	return true;




func removeBlock(pos : Vector3) -> bool:
	
	#This value contains a boolean to the status of
	#if we removed a block or not.
	#This variable is returned at the end of the function.
	#If a block/object was detected and removed, this value
	#becomes true.
	#By default and assuming nothing is removed, it is false
	var objectRemoved : bool = false;
	
	#This is an instance of the identified block/object we want
	#to remove from the "blocks[]" array and scene. This value
	#is null by default, remains null if we identify nothing in the
	#position of the object/block we want to remove
	var objectToRemove = null;
	
	#FOR loop. Here we loop through every block in the fragment
	#"BLOCK" is the current block we are inspecting from
	#array "blocks[]" which holds all blocks in the fragment.
	#We compare the x, y and z corrdinates.
	#If the corrdinates of the position of the block/object to remove
	#in "pos" falls between all 3 axis's of the BLOCK (block being inspected)
	#then we identified the block and need to remove it from the fragment,
	#the scene as a child and the "blocks[]" array.
	for BLOCK in blocks:
		
		#Take the blocks X position. If the X position of the block/object is larger than this position
		#the block/object could be in range on the x-axis. Now, add the length of one block to the BLOCK's x position.
		#If the block/object position x is now less than the BLOCK's position x, the position of the object/block we want
		#to break is within range of BLOCK (the block we are inspecting) on the X axis. Us this same logic
		#to inspect both Y and Z axis's.
		#Basically in laymans terms we are seeing if the block is within 1 blockSideLength or range
		#of the corrdinate of the block in the fragment.
		if (BLOCK.position.x < pos.x && pos.x < BLOCK.position.x + global_variables.blockSideLength):
			if (BLOCK.position.z < pos.z && pos.z < BLOCK.position.z + global_variables.blockSideLength):
				if (BLOCK.position.y < pos.y && pos.y < BLOCK.position.y + global_variables.blockSideLength):
					
					#Okay, if we are here, we have identified there is infact a object/block
					#at the position of the block/object we want to remove, this is the object.
					#Now, take a instance of this item and exit this for loop. We will
					#remove it from the scene, "blocks[]" block array next.
					#Set "objectToRemove" as a instance of the object we want to 
					#remove from the scene.
					objectToRemove = BLOCK;
					break; #Break out of this for loop, we found the object.
					
					pass;
				pass;
			pass;
		
		pass;
	
	
	#If we found no object to remove at the provided corrdinates "pos"
	#then return "objectRemoved" (false) since we found no object and
	#can progress no further, since theres nothing to remove :D
	if (objectToRemove == null):
		return objectRemoved;
	
	
	#We found the object to remove! based on the position "pos" provided
	#Now we need to remove it. Assuming we are able to remove it,
	#we will set "objectRemoved" as true, leaving our return status
	#as having successfully removed the object/block in question from
	#the fragment.
	blocks.erase(objectToRemove); #Erase the block from the "blocks[]" array
	remove_child(objectToRemove); #Remove the block from the scene.
	#We removed the object at the described position "pos"
	#Now set the exit status for our function as "true"
	#indicating we successfully removed the object/block at the
	#requested position "pos".
	objectRemoved = true;
	
	return objectRemoved;
