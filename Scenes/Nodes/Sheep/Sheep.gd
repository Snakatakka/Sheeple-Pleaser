extends Node2D

# Determines how happy the sheep is.
# I ripped these straight from neopets with no shame.
enum Morale {
	DEPRESSED = -2,
	MISERABLE,
	SAD,
	CONTENT,
	HAPPY,
	CHEERFUL,
	OVERJOYED,
}

# The sheep's sex.
enum Sex {
	MALE,
	FEMALE,
	INTERSEX
}

# Determines what life stage the sheep is at.
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

# Determines whether or not the sheep will sleep when it's day time or when it's night time.
enum SleepTime {
	DAY,
	NIGHT
}

@onready var movement_cooldown : Timer = $MovementCooldown

# These are things that WON'T change about the sheep during its lifespan. (Unless changed by a mutation.)
var sheep_name : String = "Dolly"
var sex : int = Sex.INTERSEX
var sleep_time : int = SleepTime.NIGHT
var can_breed : bool = true

# These are things that MIGHT change about the sheep during its lifespan.
var current_state : int = State.WANDER
var current_life_stage : int = LifeStage.CHILD
var current_morale : int = Morale.CONTENT
var current_age : int = 0
var breeding_age : bool = false


# Handles movement.
const MAX_MOVE_DISTANCE : float = 100.0
const SPEED : float = 200.0
var movement_target : Vector2 = Vector2(0, 0)
var moving : bool = false
var can_move : bool = true

# Handles hunger.
var hunger : int = 100
var hunger_drain_rate : int = 2.5

signal state_changed(state : int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.day_changed.connect(_age_up)
	Events.day_changed.connect(_hunger_drain)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match current_state:
		State.WANDER:
			_random_walk()
			return

func _random_walk() -> void:
	if (can_move) && (!moving):
		var delta_x : float = Math._random_float((position.x - MAX_MOVE_DISTANCE), (position.x + MAX_MOVE_DISTANCE))
		var delta_y : float = Math._random_float((position.y - MAX_MOVE_DISTANCE), (position.y + MAX_MOVE_DISTANCE))
		_move(Vector2(delta_x, delta_y), SPEED)

func _move(target : Vector2, speed : float) -> void:
	var tween : Tween = create_tween()
	moving = true
	var absolute_x : float = abs(position.x - abs(target.x))
	var absolute_y : float = abs(position.y - abs(target.y))
	var speed_value : float = (absolute_x + absolute_y) / speed
	print(speed_value)
	tween.tween_property(self, "position", target, speed_value)
	await tween.finished
	print("moved to " + str(position))
	moving = false
	can_move = false
	movement_cooldown.start(Math._random_float(1.0, 5.0))

func _change_state(state : int) -> void:
	current_state = state
	state_changed.emit(current_state)

func _change_life_stage(life_stage : int) -> void:
	current_life_stage = life_stage

func _age_up() -> void:
	current_age += 1
	_change_age(current_age)

func _change_age(age : int) -> void:
	match age:
		5:
			_change_life_stage(LifeStage.ADULT)
			breeding_age = true # Prevents adults from breeding with children.
		40:
			_change_life_stage(LifeStage.DEAD)
		_:
			if age > 30:
				_death_roll(age, morale)

func _morale_change(morale_level : int) -> void:
	if morale_level < Morale.CONTENT:
		can_breed = false

# Checks whether or not a sheep dies when it ages up; the older a sheep is, the more likely it is to die.
func _death_roll(age : int, morale_level : int) -> void:
	var roll : int = Math._random_int(29, 40)
	
	if roll + morale_level < age: # Makes it so that the happier your sheep is, the less likely it is to die.
		_change_life_stage(LifeStage.DEAD)

func _hunger_drain() -> void:
	pass

func _on_movement_cooldown_timeout() -> void:
	can_move = true
