extends Sprite2D

@export var SPEED = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x -= delta*SPEED
	if position.x < -200:
		position.x = 1200
	
