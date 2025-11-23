extends Node

#Instances of each audio file node of type "AudioStreamPlayer"
@onready var breakObject = $SFX/breakObject #Default sound for breaking a object
@onready var placeObject = $SFX/placeObject #Default sound for placing a object

#Instance of different songs
@onready var cloudyDay = $OST/CloudyDay
@onready var fallenHero = $OST/FallenHero

#random number generator utility for the AudioManager
var rng = RandomNumberGenerator.new()

#The total time that has based in seconds since the last
#song played
var timeWithoutMusic = 0;

#The time that will pass since a song ended till the next one will start
var startSongAfter_seconds = 10;

#If true, a song is currently playing.
var musicPlaying = false;

#Manange audio during application runtime.
func _process(delta : float) -> void:
	
	#Manage the flow of the games music.
	musicManager(delta);
	
	
	
	pass;


#Manages the games music each frame.
func musicManager(delta : float):
	
	#If no music is currently playing, update "timeWithoutMusic"
	#so we know how long its been since a song last played
	if (musicPlaying == false):
		timeWithoutMusic += delta;
	
	#Start a song if its been "startSongAfter_seconds"
	#without a song.
	if (timeWithoutMusic > startSongAfter_seconds):
		startSong();
	
	pass;

#Start a song.
func startSong() -> void:
	
	#DEVLOG
	print("New song started|audioManager.gd, startSong()");
	
	#Generate a random number to pick the next song
	var nextSong = rng.randi_range(0, 1);
	
	#Use the random number to select a song.
	if (nextSong == 0):
		cloudyDay.play();
	if (nextSong == 1):
		fallenHero.play();
	
	#Set the music status to playing.
	#This will prevent the song from being overridden.
	#Reset the time since the music last started
	musicPlaying = true; 
	timeWithoutMusic = 0;
	pass;


#Checks to see if a song is playing
func checkIfSongIsPlaying():
	
	#If no song is playing, "musicPlaying" is false,
	if (cloudyDay.playing != true || fallenHero.playing != true):
		musicPlaying = false;
	pass;
