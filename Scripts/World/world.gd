#This script controls the world and how fragments spawn. 
#MAIN Script.  

extends Node

#Scenes
var fragmentScene = preload("res://Scenes/World/Fragment.tscn"); #Use fragments to makeup the world
var playerScene = preload("res://Scenes/Characters/Player.tscn"); #Instance of the player

#Player
var player = playerScene.instantiate();

#4 test fragments
var testFragment1 = fragmentScene.instantiate();
var testFragment2 = fragmentScene.instantiate();
var testFragment3 = fragmentScene.instantiate();
var testFragment4 = fragmentScene.instantiate();

#fragments array
var fragments = []; #Array contains all fragments currently loaded into the world

#Frag point
var fragPoint : Vector3 = Vector3(0.0, 0.0, 0.0);


func _process(delta: float) -> void:
	
	updateFragPoint(); #Updates the fragment point based on the player position.
	
	renderWorld(); #Render the world around the fragpoint
	
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
			FRAGMENT.queue_free();
			fragments.erase(FRAGMENT);
			
			pass;
		pass;
	
	pass;




#Locate a block from a fragment based on world corrdinates
func locateBlockAt(worldX, worldY, worldZ) -> void:
	
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
			print("Fragment not found!");
			break;
		
		pass;
	
	#If no fragment could be found that does contain this block, end this function;
	#Continuing would cause error
	if (identifiedFragment == null):
		return;
	
	
	#Convert the world corrdinates to corrdinates of the fragment
	#Subtract the total number of fragment side lengths from each corrdinate (x, y, z) to convert to corrdinates of the local fragment
	var blocksFragmentCorrdinates : Vector3 = Vector3(worldX - (global_variables.fragmentSideLength * (int(worldX / global_variables.fragmentSideLength))), worldY, worldZ - (global_variables.fragmentSideLength * (int(worldZ / global_variables.fragmentSideLength))));
	
	#DEBUG/Test
	#print(blocksFragmentCorrdinates.x, "  ", blocksFragmentCorrdinates.y, "  ", blocksFragmentCorrdinates.z);
	
	#Based on the corrdinates and the known fragment, locate the block
	#Loop through the block array if the fragment until the block is found.
	for BLOCK in identifiedFragment.blocks:
		
		
		
		pass;
	
	
	pass;
