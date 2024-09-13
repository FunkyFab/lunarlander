extends Node2D

var play_sound = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Target.position.x = $module.target_position
	$AudioPlayer.play(0)
	$module.AUTO_IGNITION = $UI/VBoxContainer/Autopilot_Tilt_Check.button_pressed
	$module.AUTO_TILT = $UI/VBoxContainer/Autopilot_Ignition_Check.button_pressed
	print($Sol/MeshInstance2D.texture.load_path)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if ( !$module.landed):
		var speedX = $module.velocity.x
		var speedY = $module.velocity.y
		#Ugly
		var altitude = $module.altitude
		var tilt = $module.rotation_degrees
		var fuel = $module.fuel
		var displayedText = "Speed X: "+str(abs(speedX)).pad_decimals(0)+"\nSpeed Y: "+str(abs(speedY)).pad_decimals(0)+"\nFuel: "+str(abs(fuel)).pad_decimals(0)+"\nAltitude: "+str(abs(altitude)).pad_decimals(0)+"\nTilt: "+str(abs(tilt)).pad_decimals(0)
		$UI/VBoxContainer/Label.text = displayedText
		
func _unhandled_input(event):
	if event is InputEventScreenTouch:
		var button:int = 3*event.position.x/1152
		$UI/VBoxContainer/HBoxContainer.visible = true
		match(button):
			0:
				if ( event.pressed ):
					$module._on_turn_left_button_button_down()
					$UI/VBoxContainer/HBoxContainer/LeftIcon.visible = true
				else:
					$module._on_turn_left_button_button_up()
					$UI/VBoxContainer/HBoxContainer/LeftIcon.visible = false
			1:
				if ( event.pressed ):
					$module._on_turn_right_button_button_down()
					$UI/VBoxContainer/HBoxContainer/RightIcon.visible = true
				else:
					$module._on_turn_right_button_button_up()
					$UI/VBoxContainer/HBoxContainer/RightIcon.visible = false
			2:
				if ( event.pressed ):
					$module._on_ignition_button_button_down()
					$UI/VBoxContainer/HBoxContainer/IgnitionIcon.visible = true
				else:
					$module._on_ignition_button_button_up()
					$UI/VBoxContainer/HBoxContainer/IgnitionIcon.visible = false
				

func _on_module_game_ended() -> void:
	$UI/VBoxContainer/Restart_Button.visible = true
	play_sound = false


func _on_button_pressed() -> void:
	$UI/VBoxContainer/Restart_Button.visible = false
	$module.reset()
	$Target.position.x = $module.target_position
	play_sound = true

func _on_sound_timer_timeout() -> void:
	if play_sound:
		$AudioPlayer.play(0)


func _on_borders_body_entered(body: Node2D) -> void:
	print(body.name)
	if ( body.name == "module"):
		$module.has_landed()


func _on_show_help_button_pressed() -> void:
	$UI/Control/Show_Help_Button.visible = false
	$UI/Control/Help_Label.visible = true
	$UI/Control/Hide_Help_Button.visible = true


func _on_hide_help_button_pressed() -> void:
	$UI/Control/Show_Help_Button.visible = true
	$UI/Control/Help_Label.visible = false
	$UI/Control/Hide_Help_Button.visible = false
