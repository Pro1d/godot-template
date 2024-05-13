@tool
extends Door

@onready var _bottom_panel := $Node3D/BottomPanel
@onready var _top_panel := $Node3D/TopPanel
var _tween: Tween = null


func _build_model() -> void:
	pass

func trigger_open() -> void:
	if _tween != null:
		_tween.kill()
	
	_tween = create_tween()
	_tween.tween_property(_bottom_panel, "position:y", -1.15, 0.5) \
		.from_current().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_tween.parallel().tween_property(_top_panel, "position:y", 0.775, 0.5) \
		.from_current().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	_tween.play()
	
	state = State.OPENING
	_tween.finished.connect(func() -> void: state = State.OPENED)

func trigger_close() -> void:
	if _tween != null:
		_tween.kill()
	
	_tween = create_tween()
	_tween.tween_property(_bottom_panel, "position:y", 0.0, 0.35) \
		.from_current().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_tween.parallel().tween_property(_top_panel, "position:y", 0.0, 0.35) \
		.from_current().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	_tween.play()
	
	state = State.CLOSING
	_tween.finished.connect(func() -> void: state = State.CLOSED)

