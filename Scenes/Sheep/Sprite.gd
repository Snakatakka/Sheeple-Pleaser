extends Node2D

@onready var face_sprite : Sprite2D = $FaceSprite
@onready var hair_sprite : Sprite2D = $HairSprite
@onready var body_sprite : Sprite2D = $BodySprite
@onready var leg_sprite : Sprite2D = $LegSprite
var scale_min : float = 0.925
var scale_max : float = 1.075

var time : float
var variance : float = Math._random_float(-0.5, 0.5)
var limit : float = 5.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.time_changed.connect(_placeholder)
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
	tween.tween_property(self, "scale", Vector2(scale_max, scale_min), 2 + variance)
	tween.tween_property(self, "scale", Vector2(scale_min, scale_max), 2 + variance)
	# I lowk have no idea what the 2 is doing here, it just makes the tween look better

func _placeholder() -> void:
	pass
