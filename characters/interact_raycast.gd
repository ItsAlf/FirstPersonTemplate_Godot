extends RayCast3D
var interact_target

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if self.is_colliding() && self.get_collider().has_node("interact"):
		# get a child mode named "interact"
		interact_target = self.get_collider().get_node("interact")
		if interact_target.has_method("interact"):
			$InteractPrompt.show()
			if Input.is_action_just_pressed("Interact"):
				print("attempting interact...")
				# call the interact. let the target handle all the stuff
				interact_target.interact()
		else:
			print(interact_target)
	else:
		$InteractPrompt.hide()
