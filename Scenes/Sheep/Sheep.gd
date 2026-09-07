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
	ACTIVE,
	ASLEEP,
	DEAD
}

# Default values for sheep, will change when initiated.
var sheep_name : String = "Dolly"
var current_sex : int = Sex.INTERSEX
var current_life_stage : int = LifeStage.CHILD
var age : int = 0
var can_breed : bool = false
var wool_color : Color = Color.WHITE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.day_changed.connect(_age_up)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _change_life_stage(life_stage : int) -> void:
	current_life_stage = life_stage

func _age_up() -> void:
	age += 1

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
