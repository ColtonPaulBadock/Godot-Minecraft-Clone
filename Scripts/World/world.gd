#This script controls the world and how fragments spawn.

extends Node

#Scenes
var fragment = preload("res://Scenes/World/Fragment.tscn"); #use fragments to makeup the world


var testFragment = fragment.instantiate();

func _ready() -> void:
	testFragment.position.x = 0;
	testFragment.position.z = 0;
	
	add_child(testFragment);
