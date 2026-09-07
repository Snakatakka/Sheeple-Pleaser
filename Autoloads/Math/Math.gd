extends Node

## Returns the sine of angle "angle" in degrees.
func _sine(angle : float) -> float:
	return rad_to_deg(sin(angle))

## Returns a random float between two specified values.
func _random_float(minimum : float = 0.0, maximum : float = 1.0, rng_seed : float = Time.get_unix_time_from_system()) -> Variant:
	var rng : RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = hash(rng_seed)
	var generated_number : float = 0.0
	generated_number = rng.randf_range(minimum, maximum)
	
	return generated_number

## Returns a random int between two specified values.
func _random_int(minimum : int = 0, maximum : int = 1, rng_seed : float = Time.get_unix_time_from_system()) -> Variant:
	var rng : RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = hash(rng_seed)
	var generated_number : int = 0
	generated_number = rng.randi_range(minimum, maximum)
	
	return generated_number
