extends Node2D

enum Sex {
	MALE,
	FEMALE,
	INTERSEX
}

enum LifeStage {
	CHILD,
	ADULT,
	DEAD
}

enum State {
	WANDER,
	SEARCH,
	ASLEEP,
	DEAD
}

@onready var movement_cooldown : Timer = $MovementCooldown

# These are things that WON'T change about the sheep during its lifespan.
var sheep_name : String = "Dolly"
var current_sex : int = Sex.INTERSEX

# These are things that WILL change about the sheep during its lifespan.
var current_state : int = State.WANDER
var current_life_stage : int = LifeStage.CHILD
var current_age : int = 0
var can_breed : bool = false

# Handles movement.
const MAX_MOVE_DISTANCE : float = 100.0
const MIN_MOVE_DISTANCE : float = 20.0
var movement_target : Vector2 = Vector2(0, 0)
var moving : bool = false
var can_move : bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(Time.get_unix_time_from_system())
	Events.day_changed.connect(_age_up)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match current_state:
		State.WANDER:
			if (can_move) && (!moving):
				var delta_x = Math._random_float((position.x - MAX_MOVE_DISTANCE), (position.x + MAX_MOVE_DISTANCE))
				var delta_y = Math._random_float((position.y - MAX_MOVE_DISTANCE), (position.y + MAX_MOVE_DISTANCE))
				_move(Vector2(delta_x, delta_y), 250.0)
			return

func _move(target : Vector2, speed : float) -> void:
	var tween = create_tween()
	moving = true
	var absolute_x = abs(position.x - abs(target.x))
	var absolute_y = abs(position.y - abs(target.y))
	var speed_value : float = (absolute_x + absolute_y) / speed
	print(speed_value)
	tween.tween_property(self, "position", target, speed_value)
	await tween.finished
	print("moved to " + str(position))
	moving = false
	can_move = false
	movement_cooldown.start(Math._random_float(1.0, 5.0))

func _change_life_stage(life_stage : int) -> void:
	current_life_stage = life_stage

func _age_up() -> void:
	current_age += 1
	_evaluate_age(current_age)

func _evaluate_age(age) -> void:
	match age:
		5:
			_change_life_stage(LifeStage.ADULT)
		20:
			_change_life_stage(LifeStage.ADULT)
		40:
			_change_life_stage(LifeStage.DEAD)
		_:
			if age > 30:
				_death_roll(age)

# Checks whether or not a sheep dies when it ages up; the older a sheep is, the more likely it is to die.
func _death_roll(age) -> void:
	var roll = Math._random_int(29, 40)
	
	if roll < age:
		_change_life_stage(LifeStage.DEAD)


func _on_movement_cooldown_timeout() -> void:
	can_move = true
