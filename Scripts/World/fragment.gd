extends Node3D

#Size of the fragment in the positive corrdinate directions
#9.5, 29.5, 9.5
var fragmentSize : Vector3 = Vector3(10.0, 30.0, 10.0);

#All blocks currently in the fragment.
var blocks = [];

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
		#However, there are special exceptions (see: EXCEPTIONS)
		#--------
		#EXCEPTIONS:
		#Air Block (ID: 7) -> If its an air block, we call insertAirBlock(),
		#if just the position provided, as air blocks are used
		#for world rendering and are not legitimate blocks.
		if (blockData[3] != 7):
			addBlock(blockPos, blockData[3]);
		
		#handle special air blocks.
		#These blocks are used for terrain generation
		#and are not legitimate blocks, they will
		#be added by "insertAirBlock()" with special
		#operations as needed.
		elif (blockData[3] == 7):
			insertAirBlock(blockPos);
		
		pass;
	
	#Load all air blocks in, spawning in the natural
	#terrain from the generator around them (if any)
	loadAllAirblocks();
	
	pass;



#This function is a sub/child-function of "generateFragment()".
#Here we spawn in the fragments terrain.
#On top of this terrain we can spawn structures, etc.
#The terrain is created using noise from "noise_manager.worldTerrainNoise";
#---------
#Generates the top layer of the world, we have a seperate function loading
#blocks individually of noise (for the ground, maybe elsewhere in the future)
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
					block.block_id = 2;
				
				
				
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
				#block.position.y = ((1 * (noise_manager.worldTerrainNoise_heightAmplifier * noise_manager.worldTerrainNoise.get_noise_2d(block_x + global_position.x , block_z + global_position.z))) + block_y) + global_variables.medianWorldLayer;
				block.position.y = noise_manager.getTerrainHeightNoise(Vector2(block_x + global_position.x, block_z + global_position.z)) + block_y;
				
				addBlock(block.position, block.block_id);
				
				#-ORPHAN NODE PROBLEM SOLVED AFTER 1 WEEK!!!!-
				#I was instantiating a instance of "block", then passing it to
				#"addBlock()" just to pull data from it and create a whole new block via instancating,
				#effectively creating two instances of the block, with one not being added.
				#Free the extra instance of the block from RAM.
				block.queue_free();
				
				pass;
			
	
	pass;


#Takes the Vector3 point provided
#and generates the block it resides in
#within the fragment if the block hasn't been generated.
#Uses noise_manager and world noise for this.
#---------
#This is used for generating blocks underground.
func generateUnderground(position : Vector3):
	
	#The ID of the block to spawn in.
	var block_id : int = 6;
	
	#The height of the surface layer,
	#so we can determine which type of blocks we
	#want to spawn underground (depending on the biome, our depth,
	#etc)
	var surfaceLayerHeight : int = noise_manager.getTerrainHeightNoise(Vector2(position.x, position.z));
	
	#Remove the decimal of the positon
	#provided so that the generated
	#block snaps to the block
	#grid of the fragment
	position.x = floor(position.x);
	position.y = floor(position.y);
	position.z = floor(position.z);
	
	#If we are at the bottom of the world, the block
	#will be inibillisite, so we can't mine out
	#of the world.
	if (position.y == 0):
		block_id = 8;
	
	#Add the block picked by the generated at the
	#provided position "position" of the block we
	#wanted to generate
	addBlock(position, block_id);
	
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
		BLOCK.block_id = 1;
	#We detected a desert, so build the desert block accordingly
	#based on noise and the known biome
	elif (noise_manager.identifyBiome(noiseValue) == "DESERT"):
		BLOCK = global_variables.block_table[5].instantiate();
		BLOCK.block_id = 5;
	#Somehow, nothing was detected or a unexpected value was returned,
	#so make the biome dark blocks.
	else:
		BLOCK = global_variables.block_table[0].instantiate();
		BLOCK.block_id = 0;
	
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
			#However, if this block is ID: 7 (AirBlock)
			#there is nothing here but a terrain generation
			#block and we can safely override it.
			if (isIllegalBlock(BLOCK) == false):
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



#Removes a block from the fragment.
#This takes it out of "blocks[]" array and it
#will be removed from save data when the fragement
#is derendered.
#----------------
#ARGUMENTS:
#pos -> The position of the block to remove (we search for this position and remove the block there if it exists)
#source -> the source of the removal (player, the code, etc)
#        -"PLAYER" -> The player called the removal block function
#        -"MACHINE" -> The code called the remoal of the block
func removeBlock(pos : Vector3, source : String) -> bool:
	
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
		#Finally we check if the block is illegal. If its an illegal block,
		#we will ignore it (such as airBlock) and will make it
		#undestroyable.
		if (BLOCK.position.x < pos.x && pos.x < BLOCK.position.x + global_variables.blockSideLength):
			if (BLOCK.position.z < pos.z && pos.z < BLOCK.position.z + global_variables.blockSideLength):
				if (BLOCK.position.y < pos.y && pos.y < BLOCK.position.y + global_variables.blockSideLength):
					if (isIllegalBlock(BLOCK) == false):
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
		
		pass;
	
	
	#If we found no object to remove at the provided corrdinates "pos"
	#then return "objectRemoved" (false) since we found no object and
	#can progress no further, since theres nothing to remove :D
	if (objectToRemove == null):
		return objectRemoved;
	
	
	#If the player was the source of the blocks
	#removal, we will check several parameters,
	#and might not remove the block depending on
	#parameters such as destructiblity (is the block
	#even breakable?)
	if (source == "PLAYER"):
		
		#If the block is not breakable,
		#I.E. its indestructible, then
		#we will return null and break/remove
		#no blocks.
		if (objectToRemove.is_indestructible == true):
			objectToRemove = null;
			return objectRemoved;
			pass;
		pass;
	
	#We found the object to remove! based on the position "pos" provided
	#Now we need to remove it. Assuming we are able to remove it,
	#we will set "objectRemoved" as true, leaving our return status
	#as having successfully removed the object/block in question from
	#the fragment.
	#We will also insert an air-block into its position, so that
	#everything around it will be rendered (within 1/2 block/unit
	#distance).
	blocks.erase(objectToRemove); #Erase the block from the "blocks[]" array
	remove_child(objectToRemove); #Remove the block from the scene.
	insertAirBlock(objectToRemove.position);
	loadAirBlock(objectToRemove.position);
	#We removed the object at the described position "pos"
	#Now set the exit status for our function as "true"
	#indicating we successfully removed the object/block at the
	#requested position "pos".
	objectRemoved = true;
	
	return objectRemoved;



#This will insert an air block at the provided
#corrdinates matched to the fragments
#block grid.
#We intend for air blocks to help render
#everything around them underground.
#This function will return "true" or "false"
#depending on wether or not the airblock
#was successfully inserted.
func insertAirBlock(pos : Vector3) -> bool:
	
	#If the air block was inserted successfully,
	#return true, else we will return the default
	#value "false".
	var returnStatus : bool = false;
	
	#Remove the decimal on the block to adds position, so that it is
	#aligned with the grid space.
	pos.x = int(pos.x);
	pos.y = int(pos.y);
	pos.z = int(pos.z);
	
	#Loop through all illegal blocks,
	#if an air block already exists there,
	#then we can ignore adding this air block,
	#and will simply return false "returnStatus"
	#default value, since we couldn't add the
	#air block
	for BLOCK in blocks:
		#If the request placement corrdinates already match an existing air block,
		#then don't place a air block and exit this function, since
		#one must already be there and we don't need a second
		#one placed there.
		if (BLOCK.position.x == pos.x && BLOCK.position.y == pos.y && BLOCK.position.z == pos.z && BLOCK.block_id == 7):
			return returnStatus; #If a block already occupies the spot in the fragment, return false, placing no block
		pass;
	
	
	#We determined and air block is not actively
	#at the provided space in the fragment,
	#so we will create a temporary
	#"block" and will insert it at the
	#block requested insertion position
	#alligned with the block grid.
	var block = global_variables.block_table[7].instantiate();
	block.position = pos;
	blocks.append(block);
	add_child(block);
	returnStatus = true; #We successfully inserted the airBlock, so we will return true.
	
	
	#Return the status of the air blocks insertion
	#true -> we successfully inserted the air-block
	#false -> we failed to insert the air-block.
	return returnStatus;



#This function is pivitol to world generation.
#It takes a Vector3 (air blocks position) and renders/loads all blocks around
#said air block within 1/2 block distance.
#This allows for us to only load what should
#be visible to the player and save massive ammounts
#of space in the save files and RAM.
#------
#ARGUMENTS:
#
#"position" -> Position of the airBlock in the fragment (Local corrdinates only)
func loadAirBlock(position : Vector3):
	
	#ID: 80280482094
	#System to generate all nearby blocks
	#touching the air block which are ungenerated
	#All nearby blocks will form a 3 * 3 * 3 cube
	#around the single air block (including the air block itself).
	#This will come out to be a volume of 27 blocks,
	# we will start with each column of blocks,
	#then will move to the right down each row,
	#until we have complete 3 rows of 3 columns
	#each
	#
	#   1. We go up column 1,
	#   2. Then move right to column 2
	#   3. Continuing until the end of row 1
	#   4. Before droping back to row 2 and repeating till we hit every column
	#
	#  a. b.
	#  \/ \/
	#  *  *  *  < c.
	#  *  *  *  < d.
	#  *  *  *
	#
	#  a. column 1
	#  b. column 2
	#  c. row 1
	#  d. row 2
	#
	
	#Variables related to spawning in
	#-----------
	#Starting positions of each axis
	#when generating
	#blocks around the air block..
	var x_axis_init = position.x - 1;
	var y_axis_init = position.y - 1;
	var z_axis_init = position.z + 1;
	var blockPosition : Vector3 = Vector3(x_axis_init, y_axis_init, z_axis_init);
	#If true, we detected no issues with generating a block at "blockPosition"
	#and can procede with generating the block that should be there.
	var blockSafeToGenerate : bool = true;
	#Instance of the world, incase
	#we need to get interact with another
	#fragment (because blocks could be in
	#another fragment)
	var world = get_parent();
	#The fragment we are currently working
	#with. This is "self" by default,
	#but if we have blocks in a foreign fragment
	#it will change.
	var fragment = self;
	
	#Z-Axis
	#There is 3 rows of of columns to address
	for row in 3:
		
		#X-Axis
		#Each row has 3 columns in it to address
		#ID: checksum90812
		for column in 3:
			#Y-Axis
			#Each column contains 3 blocks.
			#ID: testghagjge
			for block in 3:
				
				#Temporary stores a copy of the blockPosition,
				#in the event we modify it for overflowing
				#into other fragments.
				var expectedPos : Vector3 = blockPosition; 
				
				#If the blocks position is outside of or below the length
				#of a fragment, then it is overflowing into another fragment.
				#we need to determine which fragment this is flowing into,
				#by search the corrdinates (global) and returning the fragment.
				#We then need to store an instance to the fragment
				#and use it to call and determine data about the block
				#we are trying to place around the air block..
				if (blockPosition.x >= global_variables.fragmentSideLength || blockPosition.x < 0.0 || blockPosition.z >= global_variables.fragmentSideLength || blockPosition.z < 0.0):
					
					#We take the global position of our current fragment "self" and add
					#the position of the block we are currently working with "blockPosition".
					#This will give us each corrdinate for the block in the world, and we keep
					#Y corrdinate the same since Y is redundent. We will then, use these corrdinates
					#in a Vector3 position and pass it to the world at "locateFragmentAt()" to return
					#an instance of the fragment the block is in.
					fragment = world.locateFragmanetAt(Vector3(self.global_position.x + blockPosition.x, blockPosition.y, self.global_position.z + blockPosition.z));
					
					#Get the new block corrdinates for the
					#block (since we are in a different fragment)
					#corrdinates will be flipped
					#--------
					#ID: LDGHYU##*8
					#First we will flip the x corrdinate (if needed)
					#We will add or subtract global length of a fragment
					#depending on if x is less than or larger than the
					#global length, to basically convert/flip the corrdinate
					#to the other fragments eqivalent corrdinate.
					if (blockPosition.x >= global_variables.fragmentSideLength):
						blockPosition.x = blockPosition.x - global_variables.fragmentSideLength;
					elif (blockPosition.x < 0.0):
						blockPosition.x = blockPosition.x + global_variables.fragmentSideLength;
					#We follow the same procedure for the z-axis as in the x-axis for flipping
					#corrdinates (ID: LDGHYU##*8)
					if (blockPosition.z >= global_variables.fragmentSideLength):
						blockPosition.z = blockPosition.z - global_variables.fragmentSideLength;
					elif (blockPosition.z < 0.0):
						blockPosition.z = blockPosition.z + global_variables.fragmentSideLength;
					
					pass;
					
				
				#If we can't find a fragment, it is because the air
				#block is trying to load blocks from
				#a fragment that doesn't exist outside
				#render distance. We will skip checking anything
				#for this block by setting "blockSafeToGenerate" to false,
				#so we try to spawn the next block around the air block.
				if (fragment == null):
					blockSafeToGenerate = false;
				
				#In the following statements, we will check for specific values,
				#instances or times where we can't generate blocks around the air
				#block. We will be checking until we determine it is safe
				#to generate the block and we generate it at ID: 09823478902749
				#(or we determine there is issues generateing a block there,
				#such as being above the surface, or a block is already there
				#and we won't generate).
				#----------------------
				#Check to see if the block would be generate above the
				#surface, if so, we can't generate the block there
				#since the surface is full of air, structures, folliage,
				#etc. "blockSafeToGenerate" will become false, preventing us
				#from generating the new block.
				#----------------------
				#We only check if the block is still determined to be safe to generate
				if (blockSafeToGenerate == true):
					if (blockPosition.y >= floor(noise_manager.getTerrainHeightNoise(Vector2(blockPosition.x + fragment.global_position.x, blockPosition.z + fragment.global_position.z)))):
						blockSafeToGenerate = false;
						pass;
					pass;
				
				#If the there is already a generated/loaded block there,
				#or more air blocks, then we will not generate
				#the block.
				#----------------------
				#We only check if the block is still determined to be safe to generate
				if (blockSafeToGenerate == true):
					for BLOCK in fragment.blocks:
						if (BLOCK.position == blockPosition):
							blockSafeToGenerate = false;
					pass;
				
				
				
				#ID: 09823478902749
				#If we determined its safe
				#for the block to generate, we will
				#do so at the blockPosition.
				if blockSafeToGenerate == true:
					fragment.generateUnderground(blockPosition);
				
				#Reset the fragment pointing back to self.
				#So that we will reference this current fragment "self"
				#next time unless we detect we are in a foreign fragment.
				#MAKE_FAST: We could set this back to self
				#when done with the column (So we aren't checking for the same
				#foreign fragment 2 additional times)
				#------
				#We reset "blockPosition" back to its expected position
				#this is just in case we where in a foreign fragment
				#and set "blockPosition" to reflect the foreign fragments
				#local corrdinates of the blocks.
				fragment = self;
				blockPosition = expectedPos;
				
				#We start at a y of 1 below the air block,
				#since we want to generate in columns all
				#around the air block if blocks are not
				#generated, then we will generate up this
				#column we are on. We add 1 to y to go to
				#the next block above, so next time we can
				#check and generate a block there is its
				#not present. (As described in ID: 80280482094)
				blockPosition.y = blockPosition.y + 1;
				
				#Reset the status of block being safe to generate.
				#since we either generated or didn't the previous
				#block depending on if it was safe, we now reset
				#this value to determine if its safe for the next
				#block.
				blockSafeToGenerate = true;
				
				
				
				pass;
			
			#We finished our column, as described
			#by ID: 80280482094. We reset to the intial
			#y-height we want to generate
			#at and will then move to the next column in
			#the row "blockPosition.x + 1".
			#We will then generate the next 3 blocks
			#in this column in ID: testghagjge.
			blockPosition.y = y_axis_init;
			blockPosition.x = blockPosition.x + 1;
			
			pass;
		
		#We completed a full row of columns at this
		#point, so we will reset back to the start
		#of the row "blockPosition.x = x_axis_init".
		#We will then move back to the next row,
		#and repeat generating the row
		#and all of its columns again as in
		#ID: checksum90812.
		blockPosition.x = x_axis_init;
		blockPosition.z = blockPosition.z - 1;
		
		pass;
	
	pass;



#Loads all airblocks present inside the fragment.
#This is useful when loading a fragment from save data,
#as we can spawn in all tunnels and ground destruction
#as we previously had
func loadAllAirblocks():
	
	#Loop through all blocks in the "block[]" array, this is
	#all blocks in the fragment that are surface layer or loaded
	#from save data (player placed blocks, natural surface terrain, etc).
	#We will then load each air block (of id type 7) if we find air blocks.
	for BLOCK in blocks:
		if (BLOCK.block_id == 7):
			loadAirBlock(BLOCK.position);
	
	pass;



#A function to help streamline
#determining if a block is illegal or not.
#EXAMPLE:
#This is useful if we want to say, place
#a block and detect a block is already there,
#however, if its a illegal block like "airBlock"
#for terrain generation, we don't care and can override it.
#-----
#RETURNS:
#true -> block is illegal block (airBlock, etc)
#false -> block is not illegal block
func isIllegalBlock(BLOCK):
	
	#The return status of this function.
	#If the block is illegal, we will update
	#it to true.
	var isIllegal : bool = false;
	
	
	#LOOP THROUGH ALL POSSIBLE ILLEGAL BLOCKS:
	#Here we will determine if the block
	#matches the ID of any known illegal block,
	#if so, the return status "isIllegal" is
	#updated to true!
	
	#If its an "airBlock", then its
	#illegal.
	if (BLOCK.block_id == 7):
		isIllegal = true;
	
	return isIllegal;


#Returns true of false, depending
#on if a block can be located at "blockPos"
#or not from the "blocks[]" array.
#------
#RETURNS:
#true -> if a block is found with same position "blockPos"
#false -> if a block is not found with position "blockPos"
func blockExists(blockPos : Vector3):
	
	#This is the return value of this function.
	#If we find a block with the same corrdinates
	#as "blockPos" (the corrdinates of the
	#block we are trying to find/check if exists),
	#then this value is updated to true and we
	#return true.
	var blockExists : bool = false;
	
	#Loop through all blocks in "blocks[]" array
	#comparing the position "blockPos" to all blocks.
	#If we find a matching position
	#to "blockPos", then we will set our
	#return value "blockExists" as true,
	#since we determined a block at position "blockPos"
	#exists.
	for block in blocks:
		if (blockPos.x == block.position.x):
			if (blockPos.z == block.position.z):
				if (blockPos.y == block.position.y):
					blockExists = true;
					break;
		pass;
	
	#Return a boolean value showing if
	#the block exists or not.
	return blockExists;
