extends Node3D

#Size of the fragment in the positive corrdinate directions
var fragmentSize : Vector3 = Vector3(9.5, 29.5, 9.5);

#All blocks currently in the fragment.
var blocks = [];

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
					block = global_variables.block_table[1].instantiate();
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
