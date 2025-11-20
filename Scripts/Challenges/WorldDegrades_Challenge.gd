#World Degrades Challenge!
#When this script runs, every block in the "blocks[]" array of every fragment in the world will slowly begin to disappear.

extends Node

#Challenge variables
var blocksPerSecond = 400; #The ammount of blocks removed each second


var timeSinceBlocksLastDegraded_milliseconds = 0; #The time since the last blocks where removed/degraded from the world in milliseconds
var timeBetweenBlockDeletion_milliseconds = 0; #The time between each block deleation in milliseconds
var loadedFragments; #Array that holds all the loaded fragments in the world
var rng = RandomNumberGenerator.new(); #Script wide random number generator

#When the script first executes on the scene
func _ready() -> void:
	
	loadedFragments = get_tree().get_root().get_node("World").fragments; #Get all the fragments loaded by the aplication from the scene tree of the world and make a instance to there array.
	
	#Figure out how long it will be between each block deleation and set this time in variable "timeBetweenBlockDeletion_milliseconds"
	updateTimeBetweenBlockDegradation(blocksPerSecond);
	
	pass;


#Every frame/application cycle
func _process(delta) -> void:
	
	degradeWorldController(delta); #Degrade the world!
	
	pass;


#Takes the number of blocks to delete each second and calulates how long it will be till the next block is deleted
func updateTimeBetweenBlockDegradation(BLOCKS_PER_SECOND) -> void:
	
	timeBetweenBlockDeletion_milliseconds =  1000 / BLOCKS_PER_SECOND;
	
	pass;

#Controls the blocks degrading.
func degradeWorldController(delta) -> void:
	
	var blocksToTakeOut = 0; #The blocks to be deleted this cycle. This is here in the event of computer lag. Assume that the computer is lagging bad and it takes 400 ms for one frame, imagine we need to delete one block every 50 ms, now we need to delete 8!
	
	#Add the time used by last fram to the time since the last block was deleted
	timeSinceBlocksLastDegraded_milliseconds += delta * 1000; #Multiply by 1000 to convert to milliseconds
	
	#Once more time has passed than the time between each block removal, REMOVE A BLOCK(s)!
	if timeSinceBlocksLastDegraded_milliseconds >= timeBetweenBlockDeletion_milliseconds:
		
		#Figure out how many blocks we need to take out based on how long its been since we last removed block(s) and the ammount of time between block deleation
		#This is here in the event of computer lag. Assume that the computer is lagging bad and it takes 400 ms for one frame, imagine we need to delete one block every 50 ms, now we need to delete 8!
		#Convert to int to remove decimal
		blocksToTakeOut = int(timeSinceBlocksLastDegraded_milliseconds / timeBetweenBlockDeletion_milliseconds);
		
		#After the number of blocks to delete has been found, set time since we last removed blocks to the excess amnount of time left.
		#Convert everything to int for modulo (ignore microsecond).
		timeSinceBlocksLastDegraded_milliseconds = int(timeSinceBlocksLastDegraded_milliseconds) % int((blocksToTakeOut * timeBetweenBlockDeletion_milliseconds));
		
		degradeBlocks(blocksToTakeOut); #Degrade the blocks!
		
		pass;
	
	pass;


#Degrades all the blocks in the world according to the ammount perscribed by the controller (func) "degradeWorldController".
func degradeBlocks(blocksToDegrade) -> void:
	
	#Degrade the number of blocks needed according to (func) "degradeWorldController".
	for block in blocksToDegrade:
		
		#Pick a random fragment and random block from said fragment
		var fragmentNumber : int = rng.randi_range(0, len(loadedFragments) - 1); #Use "len() - 1" so we don't generate a number larger than the total fragments or blocks array.
		var blockNumber : int = rng.randi_range(0, len(loadedFragments[fragmentNumber].blocks) - 1);
		
		#Remove the block from said fragment and its "blocks" array
		if len(loadedFragments[fragmentNumber].blocks) > 0: #If no blocks are in the fragment, don't remove any blocks; If the "blocks" array is empty and we try to remove a child from the scene based on that array, we can't remove a null instance from the scene and the game will crash.
			print("DEV LOG: WorldDegradesScript: Block Removed!");
			loadedFragments[fragmentNumber].remove_child(loadedFragments[fragmentNumber].blocks[blockNumber]);
			loadedFragments[fragmentNumber].blocks.remove_at(blockNumber);
		
	
	pass;


#Stops blocks from degrading
func stopDegrading() -> void:
	blocksPerSecond = 0;
	pass;
