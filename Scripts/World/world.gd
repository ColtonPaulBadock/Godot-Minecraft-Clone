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

func _ready() -> void:
	
	#Give the 4 test fragments positions in the world
	testFragment1.position.x = 0;
	testFragment1.position.z = 0;
	testFragment2.position.x = 0;
	testFragment2.position.z = -10;
	testFragment3.position.x = -10;
	testFragment3.position.z = 0;
	testFragment4.position.x = -10;
	testFragment4.position.z = -10;
	
	#Add fragments to the world
	add_child(testFragment1);
	fragments.append(testFragment1);
	add_child(testFragment2);
	fragments.append(testFragment2);
	add_child(testFragment3);
	fragments.append(testFragment3);
	add_child(testFragment4);
	fragments.append(testFragment4);
	
	player.position.y = 58;
	
	add_child(player);
