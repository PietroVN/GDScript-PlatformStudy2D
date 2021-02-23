extends KinematicBody2D

# Vars
var vel = Vector2();
var stamina = STAMINA_DEF;
var horizontal = 0;
var can_double_jump = true;

# Const
const ACC = .2;
const DE_ACC = .3;
const DEFAULT = Vector2(0 , -1);
const STAMINA_DEF = 100;            
const SPD = 500;
const JUMP_HEIGHT = 450;
const GRV = 20;

# States
enum states {idle, walking, jumping, double_jumping, wall_sliding, wall_jumping, dashing, falling};
var state = states.idle;

func _physics_process(delta):
	
	# Gravity
	vel.y += GRV;
	
	# State Machine
	match state:
		states.idle: _state_idle();
		states.walking: _state_walking();
		states.jumping: _state_jumping();
		states.double_jumping: _state_double_jumping();
		states.wall_sliding: _state_wall_sliding();
		states.wall_jumping: _state_wall_jumping();
		states.dashing: _state_dashing();
		states.falling: _state_falling();
		
	# Horizontal input
	horizontal = float(Input.is_action_pressed("ui_right")) - float(Input.is_action_pressed("ui_left"));
	
	# Move and slide
	vel = move_and_slide(vel, DEFAULT);
	
	# Enable sprite.flip_h based on vel.x
	if horizontal > 0: $Sprite.flip_h = true; # If horizontal is bigger then 0 sprite will be flipped horizontaly
	elif horizontal < 0: $Sprite.flip_h = false; # If horizontal is lower then 0 sprite will not be flipped horizontaly
	
	# Update staminaBar (DEBUG)
	$CanvasLayer/Stamina.text = "Stamina: " + String(stamina);
	
	if is_on_floor(): _recover_energy();
	
func _state_idle():
	
	# De-acelerate
	vel.x = lerp(vel.x, 0, DE_ACC);
	
	# Change state
	if Input.is_action_just_pressed("ui_accept") && $Dash.is_stopped(): 
		state = states.dashing # Change to dashing
		$Dash.start(); # Start dash timer
	if horizontal: state = states.walking # Change to walking
	if !is_on_floor(): state = states.falling # Change to falling
	if Input.is_action_pressed("ui_up") && is_on_floor(): state = states.jumping # Change to jumping
	
func _state_walking():
	
	# Walk
	vel.x = lerp(vel.x, horizontal * SPD, ACC);
	
	# Change state
	if Input.is_action_just_pressed("ui_accept") && $Dash.is_stopped(): 
		state = states.dashing # Change to dashing
		$Dash.start(); # Start dash timer
	if !is_on_floor(): state = states.falling # Change to falling
	if !horizontal: state = states.idle # Change to idle
	if Input.is_action_pressed("ui_up") && is_on_floor(): state = states.jumping # Change to jumping
	
func _state_jumping():
	
	# Jump can be high or short
	if vel.y > -JUMP_HEIGHT:
		vel.y -= 100;
	else:
		vel.y += GRV * 2 # Multiply 
		state = states.falling; # Change to falling
	
	# Walk
	vel.x = lerp(vel.x, horizontal * SPD, ACC);
	
	# Change state
	if !Input.is_action_pressed("ui_up"):
		vel.y += GRV * 2 # Multiply gravity
		
		# Change state
		state = states.falling # Change to falling
		
	if Input.is_action_just_pressed("ui_accept") && $Dash.is_stopped(): 
		state = states.dashing # Change to dashing
		$Dash.start(); # Start dash timer
	if Input.is_action_just_pressed("ui_up") && can_double_jump: state = states.dobule_jumping # Change to double jumping
	if is_on_wall(): state = states.wall_sliding # Change to wall sliding

func _state_falling():
	
	# Walk
	vel.x = lerp(vel.x, horizontal * SPD, ACC);
	
	# Change state
	if Input.is_action_just_pressed("ui_accept") && $Dash.is_stopped(): 
		state = states.dashing # Change to dashing
		$Dash.start(); # Start dash timer
	if Input.is_action_just_pressed("ui_up") && can_double_jump: state = states.double_jumping # Change to double jumping
	if is_on_wall(): state = states.wall_sliding # Change to wall sliding
	if is_on_floor():
		if !horizontal: state = states.idle # Change to idle
		if horizontal: state = states.walking # Change to walking

func _state_double_jumping():
	
	# Jump
	vel.y -= JUMP_HEIGHT;
	
	# Walk
	vel.x = lerp(vel.x, horizontal * SPD, ACC);
	
	# Can_double_jump will be false
	can_double_jump = false;
	
	# Multiply gravity
	vel.y += GRV * 2
	
	# Change state
	if Input.is_action_just_pressed("ui_accept") && $Dash.is_stopped(): 
		state = states.dashing # Change to dashing
		$Dash.start(); # Start dash timer
	state = states.falling; # Change to falling
	if is_on_wall(): state = states.wall_sliding # Change to wall sliding

func _state_wall_sliding():
	
	# Walk
	vel.x = lerp(vel.x, horizontal * SPD, ACC);
	
	# If stamina is bigger then 50, wall_sliding will cost less stamina and vel.y will be slow
	if stamina > 50:
		vel.y = 15
		stamina -= .1
	
	# If stamina is slower then 50, wall_sliding will cost more stamina and vel.y will be fast
	if stamina <= 50 && stamina > 0:
		vel.y = 25
		stamina -= .5
	
	# Change state
	if Input.is_action_just_pressed("ui_accept") && $Dash.is_stopped(): 
		state = states.dashing # Change to dashing
		$Dash.start(); # Start dash timer
	if stamina <= 0: state = states.falling # Change to falling
	if is_on_floor() && horizontal: state = states.walking; # Change to walking
	if Input.is_action_just_pressed("ui_up"): state = states.wall_jumping # Change to wall jumping
	if !is_on_wall(): state = states.falling # Change to falling
	if is_on_floor() && !horizontal: state = states.idle; # Change to idle

func _state_wall_jumping():
	
	# Multiply JUMP_HEIGHT by 1.3
	vel.y -= JUMP_HEIGHT * 1.3;
	
	# Push player 
	vel.x -= 1000 * horizontal;
	
	# Change state
	state = states.falling; # Change to falling

func _state_dashing():
	
	if $Sprite.flip_h: vel.x = SPD * 2; # If sprite is flipped horizontaly SPD will be positive
	elif !$Sprite.flip_h: vel.x = -SPD * 2; # If sprite is not flipped horizontaly SPD will be negative
	
	# Change state
	if $Dash.is_stopped() && horizontal: state = states.walking; # Change to walking
	if $Dash.is_stopped() && !horizontal: state = states.idle; # Change to idle
	
func _recover_energy():
	
	# Reload stamina
	if stamina < STAMINA_DEF: stamina += 1;

	# Check if can_double_jump is false, and turn it true
	if can_double_jump == false: can_double_jump = true;
