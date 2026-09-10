extends Button

func _on_pressed() -> void:
	Events.emit_signal("sheep_interacted", get_parent())
