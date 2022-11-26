extends CharacterBody3D

# class member variables go here
var view_sensitivity = 0.3
var yaw = 0
var pitch = 0

var myVelocity = Vector3()

const WALK_MAX_SPEED = 15
const ACCEL = 4
const DECCEL = 10

var isMoving = false

const JUMP = 3*3
const GRAVITY = -9.8*3

const FLOOR_NORMAL = Vector3(0,1,0)

var weapon = null;

#gun cooldown
var fireRate = 10.25
var coolDown = 0

#preload the players guns
var ballGun = preload("res://objects/BallGun.tscn").instantiate()
var SMG 	= preload("res://objects/SmgGun.tscn").instantiate()

var originalSnap = Vector3(0,-8,0)
var snap

func _input(event):
	if(event is InputEventMouseMotion):
		
		yaw = fmod(yaw - event.relative.x * view_sensitivity, 360)
		get_node("yaw").set_rotation(Vector3(0,deg_to_rad(yaw),0))
		
		pitch = max(min(pitch - event.relative.y * view_sensitivity, 90), -90)
		get_node("yaw/Camera3D").set_rotation(Vector3(deg_to_rad(pitch),0,0))
	


func _ready():
	#add default weapon to character
	get_node("yaw/Camera3D/currentWeapon").add_child(ballGun)
	weapon = get_node("yaw/Camera3D/currentWeapon").get_child(0)
	fireRate = weapon.fireRate
	snap = originalSnap

func _physics_process(delta):	
	#process character movment
	_walk(delta)
	_weaponSystem(delta)


#Set the mouse mode to captured when the 'actor' is created	
func _enter_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
#set the mouse mode to visable when the 'actor' is destroyed
func _exit_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _walk(delta):
	#get the current rotation of the camers (as a basis)
	var aim = get_node("yaw/Camera3D").get_global_transform().basis

	#determin what direction the player wants to go
	var direction = Vector3()
	if(Input.is_action_pressed("move_foward")):
		direction -= aim[2]
	if(Input.is_action_pressed("move_back")):
		direction += aim[2]
	if(Input.is_action_pressed("strafe_left")):
		direction -= aim[0]
	if(Input.is_action_pressed("strafe_right")):
		direction += aim[0]
	
	#determin if the character is moving
	isMoving = (direction.length()>0)
	
	#convert the desired direction into a unit vector
	direction = direction.normalized()
	
	#calculate the target vector
	var target = direction*WALK_MAX_SPEED
	
	# if the character is moving, he must accelerate. 
	# Otherwise he deccelerates
	var accel=DECCEL
	if (isMoving):
		accel=ACCEL
	
	#Determin the myVelocity
	var hvel = myVelocity
	hvel.y = 0
	
	#clamp movment values at low speeds to allow stopping checked slopes
	if (!isMoving):
		if hvel.x < 2 && hvel.x > -2:
			hvel.x = 0
		if hvel.z < 2 && hvel.z > -2:
			hvel.z = 0
	
	hvel = hvel.lerp(target, accel*delta)
	
	#Note this seems like it shouldn't be needed
	#if issue #30311 gets fixed this might break things or be unnecessary.
	#make the player "stick" with moving floors and platforms
	hvel += get_platform_velocity()*delta
	
	myVelocity.x = hvel.x
	myVelocity.z = hvel.z
	
	#move towards the desired direction
	set_velocity(myVelocity)
	# TODOConverter40 looks that snap in Godot 4.0 is float, not vector like in Godot 3 - previous value `snap`
	set_up_direction(FLOOR_NORMAL)
	set_floor_stop_on_slope_enabled(true)
	move_and_slide()
	myVelocity = myVelocity
	
	#Only allowed to jump if checked the floor. 
	if( is_on_floor() and Input.is_action_pressed("Jump")):
		snap = Vector3(0,0,0)
		myVelocity.y += JUMP
	if(!is_on_floor()):
		snap = originalSnap
	
	#Apply Gravity
	myVelocity.y += delta*GRAVITY

#process weapons firing
func _weaponSystem(delta):

	if(coolDown <= 0):
		if(Input.is_action_pressed("primartFire")):
			coolDown = delta+fireRate
			weapon.fire()
	else:
		coolDown -= delta
		
	#weapon switching. pretty in-elegant but It works
	if(Input.is_action_pressed("weapon1")):
		get_node("yaw/Camera3D/currentWeapon").remove_child(weapon)
		get_node("yaw/Camera3D/currentWeapon").add_child(ballGun)
		weapon = get_node("yaw/Camera3D/currentWeapon").get_child(0)
		fireRate = weapon.fireRate
	if(Input.is_action_pressed("weapon2")):
		get_node("yaw/Camera3D/currentWeapon").remove_child(weapon)
		get_node("yaw/Camera3D/currentWeapon").add_child(SMG)
		weapon = get_node("yaw/Camera3D/currentWeapon").get_child(0)
		fireRate = weapon.fireRate
		
		
