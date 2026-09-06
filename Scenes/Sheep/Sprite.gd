extends Node2D

var time : float
var variance : float = Math._random_float(-0.5, 0.5)
var limit : float = 5.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rotation = 0.0
	_bob()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += (delta)
	rotation_degrees = Math._sine(time + variance) / limit

func _bob() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_loops()
	tween.tween_property(self, "scale", Vector2(1.075, 0.925), 2 + variance)
	tween.tween_property(self, "scale", Vector2(0.925, 1.075), 2 + variance)
