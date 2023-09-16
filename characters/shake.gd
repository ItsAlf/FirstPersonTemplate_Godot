extends Camera3D
var added_shakes = Array()

class CameraShakeSource:
	var current_duration = -1
	var total_duration = -1
	var current_scale = 0
	var blend_in = 0.2
	var shake_speed = 1.0
	
	var noise = FastNoiseLite.new()
	var noise_position = 0.0
	
	
	var bis_active = false
	var camera_offset = Vector2.ZERO
	
	signal on_finished(finished_shake)
	
	func activate_shake(duration: float, shake_scale: float, speed: float, inblend_in: float):
		total_duration = duration
		current_duration = total_duration
		current_scale = shake_scale
		blend_in = inblend_in
		shake_speed = speed
		noise.seed = randi()
		noise.fractal_gain = 10
		noise.frequency = 0.1
		
		
		
		bis_active = true
	
	func get_shake_time_normalized() -> float:
		return 1 - current_duration / total_duration
	
	func get_blend_in_scalar() -> float:
		return clamp(get_shake_time_normalized() / blend_in, 0.0, 1.0)
	
	func update_shake(delta):
		if bis_active:
			if current_duration >= 0:
				current_duration -= delta
				current_scale = lerp(current_scale, 0.0, get_shake_time_normalized())
				
				
				camera_offset = get_source_offset(delta) * current_scale
			
			# infinite shake if total duration <= 0
			else: if total_duration <= 0:
				camera_offset = get_source_offset(delta) * current_scale
			
			else:
				camera_offset = Vector2.ZERO
				bis_active = false
				on_finished.emit(self)
		
		else:
			camera_offset = Vector2.ZERO

	func get_source_offset(delta: float) -> Vector2:
		noise_position += delta * shake_speed
		return Vector2(noise.get_noise_2d(1, noise_position), noise.get_noise_2d(100, noise_position))

#func _ready():
#	shake(1.0, 0.2, 0.2, 0.2)

func shake(duration: float, shake_scale: float, speed: float, blend_in: float):
	var NewShakeSource = CameraShakeSource.new()
	NewShakeSource.activate_shake(duration, shake_scale, speed, blend_in);
	NewShakeSource.on_finished.connect(on_shake_finished)
	added_shakes.push_front(NewShakeSource)

func on_shake_finished(finished_shake):
	if finished_shake != null && added_shakes.has(finished_shake):
		added_shakes.remove_at(added_shakes.find(finished_shake))

func _process(delta):
	var total_offset = Vector2.ZERO
	
	if !added_shakes.is_empty():
		for current_shake in added_shakes:
			current_shake.update_shake(delta)
			total_offset += current_shake.camera_offset
	
	self.h_offset = total_offset.x
	self.v_offset = total_offset.y
