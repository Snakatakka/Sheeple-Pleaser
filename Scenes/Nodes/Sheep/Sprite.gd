extends Node2D

@onready var face_sprite : Sprite2D = $FaceSprite
@onready var hair_sprite : Sprite2D = $HairSprite
@onready var body_sprite : Sprite2D = $BodySprite
@onready var leg_sprite : Sprite2D = $LegSprite

var parent : Node = get_parent()
var scale_min : float = 0.925
var scale_max : float = 1.075

var time : float
var variance : float = Math._random_float(-0.5, 0.5)
var limit : float = 5.0

var tween : Tween
var bob_speed : float = 2.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_bob()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += (delta)
	rotation_degrees = Math._sine(time + variance) / limit
	var new_bob_speed : int
	
	match get_parent().moving:
		true:
			new_bob_speed = 1
		false:
			new_bob_speed = 2
	
	bob_speed = new_bob_speed
	

func _bob() -> void:
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_loops()
	tween.tween_property(self, "scale", Vector2(scale_max, scale_min), bob_speed + variance)
	tween.tween_property(self, "scale", Vector2(scale_min, scale_max), bob_speed + variance)
	# I lowk have no idea what the 2 is doing here, it just makes the tween look better

func _on_state_changed(state: int) -> void:
	pass # Replace with function body.
