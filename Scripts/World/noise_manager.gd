#This is the noise manager
#Here we create noise to use in world generatation
#and generating aspects of the world
extends Node

#Generator used to generate noise for the worlds
#terrian. This is in reguard to world height, hills,
#steepness, possibly water level.
var worldTerrainNoise = FastNoiseLite.new();


#Generator used to generate noise for the worlds
#biomes. Based on the noise at a specific part
#of the noise image, we select biomes/blocks
#to spawn in "generateBiome()" in "fragment.gd".
var worldBiomeNoise = FastNoiseLite.new();

#This is the seed for the noise_manager
#to generate all the worlds terrain, biomes
#and structures off of.
#--------
#All seeds and FastNoiseLite models for biome generation, terrain,
#structures, etc will all be set based on a derivative of this seed.
#For example: (the terrain seed might be set by dividing this
#seed by 10 and adding 4 (Not actually, but similar to this, get a random
#number thats different from seed, but related to it so we can
#always get it each time when loading the save file))
var seed : int;

#World terrain amplifer variables,
#these are used to set the height of the terrain,
#over specific distances, flatness, etc.
#----------
#How high the world terrain is amplifed to generate
#the higher this variable, the higher mountains
#will become.
var worldTerrainNoise_heightAmplifier : int = 50; #10-50 is default
#This is the distance at which height is drawn out.
#this doesn't effect overall height "worldTerrainNoise_heightAmplifier",
#it just modifies how long it takes for terrain to achieve
#max height and how long mountains will roll for.
#The lower this variable, the further mountains will roll.
var worldTerrainNoise_heightDrawDistance : float = 0.5;

#This is the biome size multipler. Used to amplify or shrink the size of generated
#biomes in "fragment.gd".
#The smaller this number, the larger biomes will be.
#The larger this number, the smaller biomes will be.
#
#10 = Femto biomes
#4 = Micro Biomes
#0.7 = Small biomes
#0.2 = Medium Biomes
#0.05 = Large Biomes
#0.01 = Massive Biomes
var biomeSizeMultipler : float = 0.2;


#The noise type we want to use for "worldTerrainNoise"
#(FastNoiseLite) noise generator for our world height, terrain, hills,
#elevation, etc.
#0 = Simplex Noise
#1 = Simplex Smooth Noise
#2 = Cellular Noise
#3 = Perlin Noise
#4 = Value Cubic
#5 = Value
var worldTerrainNoise_type : int = 3;


#The noise type we want to use for "worldBiomeNoise"
#(FastNoiseLite) noise generator for our world biomes
#0 = Simplex Noise
#1 = Simplex Smooth Noise
#2 = Cellular Noise
#3 = Perlin Noise
#4 = Value Cubic
#5 = Value
var worldBiomeNoise_type : int = 3;





#Intalize noise generators, variables
#and anything else reguarding noise generation for
#the worlds terrain.
#This function runs once when the application starts
func _ready() -> void:
	
	
	#Setup the "worldTerrainNoise" generator for hills, peaks,
	#valleys and elevation.
	#Here we set the seed, noise type, octaves, etc.
	setup_worldTerrainNoise();
	
	#Setup the "worldBiomeNoise" generator to generate noise
	#for the biomes we are spawning in the world.
	#Set the seed, noise type and other parameters.
	setup_worldBiomeNoise();
	
	pass;


#Returns the terrain height for the surface
#layer based on provided corrdinates as argument
#1 (which is a vector2).
#-----
#ARGUMENTS:
# noisePos -> The position on the noise map, related to the world position
func getTerrainHeightNoise(noisePos : Vector2):
	
	#The height of the world based on the corrdinates provided
	#in argument 1.
	#NOTE: "noisePos.y" is actually a z-axis corrdinate, since we only need
	#two corrdinates "Vector2" and y is one of them by default in godot.
	#--------------
	#"worldTerrainNoise_heightDrawDistance" is how far/long it will take for the
	#terrain to reach peak amplified height "worldTerrainNoise_heightAmplifier".
	#We multiply corrdinates by said "worldTerrainNoise_heightDrawDistance" value
	#to ensure runs longer or shorter by streaching out the variable in "get_noise_2d()"
	#as "worldTerrainNoise_heightDrawDistance" is expected to be a lower double/float
	#around 0.2 for example..
	var height = floor(((1 * (worldTerrainNoise_heightAmplifier * worldTerrainNoise.get_noise_2d(noisePos.x * worldTerrainNoise_heightDrawDistance, noisePos.y * worldTerrainNoise_heightDrawDistance)))) + global_variables.medianWorldLayer);
	
	
	return height;



#This function intializes parameters
#or data for the biome noise generator
#"worldBiomeNoise". We setup the seed,
#noise type, etc.
func setup_worldBiomeNoise() -> void:
	
	
	#Set the seed for the world biome noise generator
	#we will take the worlds seed, and add, divide, etc to get
	#a deriviative number to the seed thats different ensuring
	#unique biomes different from the terrain.
	worldBiomeNoise.seed = (seed / 2) + 12;
	
	#Setup the noise type for the world biome noise.
	#Setting the noise equal to the picked noise type
	#set in "worldBiomeNoise_type" up top with the rest of the
	#script variables.
	#Could be Perlin, Simplex, etc
	worldBiomeNoise.noise_type = worldBiomeNoise_type;
	
	pass;




#This function is used to intalize the
#"worldTerrainNoise" which uses FastNoiseLite
#to generate world terrain. (Hills, slopes, elevation)
#We want to setup the seed, noise type and other
#octal factors if needed. The intention is that
#this function runs before we access "worldTerrainNoise"
#and its noise images.
func setup_worldTerrainNoise() -> void:
	
	#Set the terrain seed for the terrain noise
	#generator (FastNoiseLite).
	#-----
	#We will take the worlds seed, and add, divide, etc to get
	#a deriviative number to the seed thats different ensuring
	#unique terrain.
	worldTerrainNoise.seed = ((seed * 4) / 12) - 6;
	
	#Setup the noise type we want to use in "worldTerrainNoise" the type of
	#noise is preset in variable "worldTerrainNoise_type", which is declared
	#above, here we apply the noise type.
	worldTerrainNoise.noise_type = worldTerrainNoise_type;
	
	pass;


#Here are some variables related to "identifyBiome()" biome
#detection system, named to remove magical numbers
#NOTE: For biome boarder variables, the leading
#listed biome is either larger or equal to the
#noise value of the boarder, while the second
#listed variable in the biome name is less than the boarder value.
#The noise boarder between grassland and desert
var grassland_desert_boarder : float = -0.3;

#Returns the idenity of the biome based on the inputted noise
#variable "noise" for argument 1. This function can be used
#anywhere throughout the application to identify the biome based
#on noise, returning a string value representing the biome.
#
#
#BIOMES:
#
#Grassland: noise >= -0.3
#Desert: noise < -0.3
func identifyBiome(noise : float) -> String:
	
	#This variable will hold the return value for
	#which biome we are in.
	#Returned at the end of this function as a String.
	var biome : String;
	
	#Depending on the noise level that was inputed, detect which biome we are in.
	#For example, if the noise is equal to or larger than -0.3, we are in the grassland
	#biome. Noise is expected to have been inputed from "noise_manager.worldBiomeNoise.get_noise_2d()",
	#using "worldBiomeNoise" but this can work with any noise.
	if (noise >= grassland_desert_boarder):
		biome = "GRASSLAND";
	elif (noise < grassland_desert_boarder):
		biome = "DESERT"
	
	return biome;
