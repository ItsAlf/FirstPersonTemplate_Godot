extends Node3D
@export var LIGHT_INTENSITY = 1
var is_enabled = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func interact():
	is_enabled = !is_enabled
	$OmniLight3D.visible = is_enabled
