extends Node

var scene;

func _ready():
	
	
	# Spawn MainScreen script
	if !get_node("/root/Main/MainScreen"):
		var main_screen = load("res://Scenes/MainScreen.tscn"); # Load MainScreen
		add_child(main_screen.instance()); # Add child node main_screen instance
	
func _process(delta):
	
	if scene && get_child_count() <= 0: # Check if exist child nodes on Main scene
		
		add_child(scene); # Add child node
