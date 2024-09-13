extends CharacterBody2D

signal game_ended

@export var ROTATE_SPEED = 0.3
@export var GRAVITY_BOOSTER_RATIO = 1.7
@export var MAX_SPEED_X = 5
@export var MAX_SPEED_Y = 30
@export var MAX_TILT = 15
@export var INIT_FUEL = 1500
@export var MAX_DISTANCE = 80
@export var AUTO_TILT: bool = false
@export var AUTO_IGNITION: bool = false

var landed = false
var previous_velocity
var fuel = INIT_FUEL
var target_position
var altitude

@onready var sol: StaticBody2D = %Sol
@onready var turn_left_button: Button = %Turn_Left_Button
@onready var turn_right_button: Button = %Turn_Right_Button
@onready var ignition_button: Button = %Ignition_Button

func reset():
	rotation = 0
	velocity = Vector2(0,0)
	ignition = false
	tilt_left = false
	tilt_right = false
	$SpriteExplosion.emitting = false
	$SpriteExplosion.one_shot = true
	position.x = 652
	position.y = 52
	fuel = INIT_FUEL
	landed = false
	visible = true
	$still.visible = false
	$astronaut.visible = false
	$flame.visible = false
	target_position = randi_range(0,1052) + 50
	#target_position = 100

func _ready() -> void:
	reset()

func successfull_landing():
	# Check vertical velocity, horizontal velocity, tilt angle and distance from target
	return  abs(previous_velocity.x)<MAX_SPEED_X && abs(previous_velocity.y)<MAX_SPEED_Y && abs(rotation)<MAX_TILT && abs(target_position-position.x) < MAX_DISTANCE
	
func has_landed() -> void: 
	if ( successfull_landing()): 
		$astronaut.visible = true
		$landingAudioPlayer.play()
	else:
		$SpriteExplosion.emitting = true
		$astronaut.visible = false
		$still.visible = false
		$flame.visible = false
		$crashingAudioPlayer.play()
	landed = true	
	rotate(-rotation)
	velocity = Vector2(0,0)
	game_ended.emit() 
	
#Proportional factor between delta pos and speed
@export var p_speed: float = 0.25	
#Maximum tilt angle in degrees
@export var max_tilt = 60
#Proportional factor between the target speed and the tilt angle
@export var p_tilt: float = 1.5
#Tilt limit for ignition
@export var ignition_title_limit_deg = 20
#Maximum vertical speed allowed for max alitude
@export var max_speed_altitude = 200
const MAX_ALTITUDE = 575.0
var ignition:bool = false
var tilt_left: bool = false
var tilt_right: bool = false

func auto_pilot():
	if AUTO_TILT :
		#X speed = f(dist)
		var target_speed_X = (target_position - position.x)*p_speed*altitude/MAX_ALTITUDE
		#If too fast too low, limit speed
		if ( altitude < 50 && abs(target_speed_X)>4):
			target_speed_X = 4*sign(target_speed_X)
		# tilt = f(target_speed, current speed)
		var target_tilt_deg = (target_speed_X - velocity.x)*p_tilt
		if ( target_tilt_deg < -max_tilt ):
			target_tilt_deg = -max_tilt
		if ( target_tilt_deg > max_tilt ):
			target_tilt_deg = max_tilt
		var delta_tilt = deg_to_rad(target_tilt_deg) - rotation
		rotate(delta_tilt)
	
	if AUTO_IGNITION:
		var target_speed_Y = altitude*altitude/MAX_ALTITUDE/MAX_ALTITUDE*max_speed_altitude + 35
		if ( altitude < 40 ):
			target_speed_Y = 20
		#Ignition is vertical speed is too high or angle is too high
		var speed_ignition = velocity.y > target_speed_Y
		var tilt_ignition = abs(rotation)>deg_to_rad(ignition_title_limit_deg)
		ignition =  speed_ignition || tilt_ignition 
		#No climbing	
		if ( velocity.y < 0 ):
			ignition = false
			
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	altitude = MAX_ALTITUDE - position.y
	auto_pilot()
	
	# Handle boost.
	if !landed:
		if (Input.is_action_pressed("ignition") || ignition ) && fuel > 0:
			# velocity change, in the frame of the module
			var deltaVBooster = -GRAVITY_BOOSTER_RATIO*get_gravity()*delta
			# velocity chnage, in the frame of the game
			var projectedDeltaVBooster = deltaVBooster.rotated(rotation)
			velocity += projectedDeltaVBooster
			fuel -= 100*delta
			$still.visible = false
			$flame.visible = true
		else:
			$still.visible = true
			$flame.visible = false

	#Handle rotation
	if (Input.is_action_pressed("rot_left") || tilt_left) && !landed:
		rotate(-ROTATE_SPEED*delta)
	if (Input.is_action_pressed("rot_right") || tilt_right) && !landed:
		rotate(ROTATE_SPEED*delta)
		
	previous_velocity = velocity
		
	move_and_slide()
	if (!landed):
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			if (collision.get_collider() == sol): 
				has_landed()


func _on_autopilot_tilt_check_toggled(toggled_on: bool) -> void:
	AUTO_TILT = toggled_on

func _on_autopilot_ignition_check_toggled(toggled_on: bool) -> void:
	AUTO_IGNITION = toggled_on


func _on_ignition_button_button_up() -> void:
	if (!AUTO_IGNITION):
		ignition = false


func _on_ignition_button_button_down() -> void:
	if (!AUTO_IGNITION):
		ignition = true


func _on_turn_left_button_button_down() -> void:
	if (!AUTO_TILT):
		tilt_left = true


func _on_turn_left_button_button_up() -> void:
	if (!AUTO_TILT):
		tilt_left = false


func _on_turn_right_button_button_down() -> void:
	if (!AUTO_TILT):
		tilt_right = true


func _on_turn_right_button_button_up() -> void:
	if (!AUTO_TILT):
		tilt_right = false
