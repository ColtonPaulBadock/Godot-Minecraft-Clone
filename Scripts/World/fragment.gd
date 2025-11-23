extends Node3D

#Size of the fragment in the positive corrdinate directions
var fragmentSize : Vector3 = Vector3(9.5, 29.5, 9.5);

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
func generateFragment():
	
	
	for x in fragmentSize.x: #Go along the X axis cordinate by cordinate
		for z in fragmentSize.z: #Go along the z axis cordinate by cordinate
			for y in 40:
				
				var block = global_variables.block_table[0].instantiate(); #Instaniate the dark block; "block" is the current block being worked on in the fragment; All blocks start as a dark block unit assigned a id.
				
				#Choose block based on layer
				#Early block spawning system, will be changed later to use more random numbers, etc.
				if (y == 39): #Top layer will be sod
					var randomBlockId = rng.randi_range(1, 3);
					block = global_variables.block_table[randomBlockId].instantiate();
				elif (y < 39 && y > 34): #The next five blocks below sod are top soil
					block = global_variables.block_table[2].instantiate();
				elif (y <= 34): #The rest of the world is sub soil below 34
					block = global_variables.block_table[3].instantiate();
					pass;
				
				#Set the blocks position
				block.position.x = (x); #Corrdinate x is the row in the x corrdinate we are on.
				block.position.z = (z); #Corrdinate z is the row in the z corrdinate we are on from the for loops, creating on full layer.
				block.position.y = (y);
				
				blocks.append(block); #Add the block to the back of blocks for this fragment
				
				add_child(block); #Add the block to the scene.
	
	pass;


#Adds a block of type "id" to the fragment.
#Whatever block space the "pos" falls into is the grid space the block will occupy
#ARGUMENTS:
#pos = Position/Corrdinates to add the block
#id = id of the object/block (its type).
func addBlock(pos : Vector3, id):
	
	#Remove the decimal on the block to adds position, so that it is
	#aligned with the grid space.
	pos.x = int(pos.x);
	pos.y = int(pos.y);
	pos.z = int(pos.z);
	
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
	
	pass;
