extends Node2D

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
	NIGHT,
	NEVER
}

# Determines how happy the sheep is.
# I ripped these straight from Neopets with no shame.
enum Morale {
	DEPRESSED = -2,
	MISERABLE,
	SAD,
	CONTENT,
	HAPPY,
	CHEERFUL,
	OVERJOYED,
}

enum Hunger {
	STARVING = -2,
	FAMISHED,
	HUNGRY,
	CONTENT,
	SATISFIED,
	FULL,
	OVERSTUFFED
}

@onready var movement_cooldown : Timer = $MovementCooldown
@onready var sight_radius : Area2D = $SightRadius

# These are things that WON'T change about the sheep during its lifespan. (Unless changed by a mutation.)
var sheep_name : String = "Dolly"
var sex : int = Sex.INTERSEX

# Handles state.
var current_state : int = State.WANDER
var search_target_group : String = ""

# Handles life stages.
var life_stage_can_change : bool = true
var current_life_stage : int = LifeStage.CHILD
var current_age : int = 0

# Handles breeding.
var able_to_breed : bool = true
var can_breed : bool = false # can_breed and able_to_breed are DIFFERENT. able_to_breed is permanent, can_breed isn't.

# Handles movement.
const MAX_MOVE_DISTANCE : float = 100.0
const SPEED : float = 200.0
var movement_target : Vector2 = Vector2(0, 0)
var moving : bool = false
var can_move : bool = true

# Handles morale.
var morale_can_change : bool = true
var current_morale : int = Morale.CONTENT

# Handles hunger.
var hunger_can_change : bool = true
var hunger_drain_rate : int = 1
var current_hunger : int = Hunger.CONTENT

# Handles sleep.
var sleep_time : int = SleepTime.NIGHT

signal state_changed(state : int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.day_changed.connect(_age_up)
	Events.time_changed.connect(_morale_check)
	Events.time_changed.connect(_sleep_check)
	Events.time_changed.connect(_hunger_check)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match current_state: # Being asleep and being dead are functionally the same, so we don't need to worry about that for now.
		State.WANDER:
			if (can_move) && (!moving):
				_random_walk()
			return
		State.SEARCH:
			if (can_move) && (!moving):
				var result : Array = _locate_target_group(search_target_group)
				if result[0] == true: 
					_move(result[1].position, SPEED) # If a node that is in the group is found, move to it.
				else:
					_random_walk() # Otherwise, move in a random direction and look again.

func _random_walk() -> void:
	var delta_x : float = Math._random_float((position.x - MAX_MOVE_DISTANCE), (position.x + MAX_MOVE_DISTANCE))
	var delta_y : float = Math._random_float((position.y - MAX_MOVE_DISTANCE), (position.y + MAX_MOVE_DISTANCE))
	_move(Vector2(delta_x, delta_y), SPEED)

func _locate_target_group(group : String) -> Array:
	var return_array : Array = []
	var target_found : bool = false
	var target : Node = null
	
	for body in sight_radius:
		if body.is_in_group(search_target_group):
			_move(body.global_position, SPEED)
			target_found = true
			target = body
			break
	
	return_array[0] = target_found
	return_array[1] = target
	return return_array

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
	if life_stage_can_change:
		current_life_stage = life_stage
		if current_life_stage == LifeStage.DEAD: # Prevents sheep who are dead from rising from the grave.
			life_stage_can_change = false

func _age_up() -> void:
	if current_life_stage != LifeStage.DEAD: # Prevents sheep who are dead from getting any older.
		current_age += 1
		_change_age(current_age)

func _change_age(age : int) -> void:
	match age:
		5:
			_change_life_stage(LifeStage.ADULT)
		40:
			_change_life_stage(LifeStage.DEAD)
		_:
			if age > 30:
				_death_roll(age, current_morale)

func _change_hunger(hunger : int) -> void:
	current_hunger = hunger

func _change_morale(morale : int) -> void:
	if morale_can_change:
		current_morale = morale
	
	if morale < Morale.CONTENT:
		can_breed = false # Makes it so that sheep that are sad can't breed; better incentivizes the player to keep their sheep happy.
	else:
		can_breed = true

# Checks whether or not a sheep dies when it ages up; the older a sheep is, the more likely it is to die.
func _death_roll(age : int, morale_level : int) -> void:
	var roll : int = Math._random_int(29, 40)
	
	if roll + morale_level < age: # Makes it so that the happier your sheep is, the less likely it is to die.
		_change_life_stage(LifeStage.DEAD)

func _morale_check() -> void:
	var new_morale : int = current_morale + current_hunger
	_change_morale(new_morale)

func _hunger_check() -> void:
	var new_hunger : int = current_hunger - hunger_drain_rate
	_change_hunger(new_hunger)

func _sleep_check(time : int) -> void:
		if time == sleep_time:
			_change_state(State.ASLEEP)

func _on_movement_cooldown_timeout() -> void:
	can_move = true

func _on_breeding_cooldown_timeout() -> void:
	can_breed = true
