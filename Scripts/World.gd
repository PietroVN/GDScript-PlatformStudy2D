extends Node2D

func _ready():
	
	# Spawn player script
	if !get_node("/root/Main/World/Player"): # Check if player exists
		
		var player = load("res://Scenes/Player.tscn"); # load player
		
		add_child(player.instance()); # Add child node player instance
