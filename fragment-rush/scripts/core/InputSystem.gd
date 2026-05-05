extends Node
## InputSystem.gd
## Ponte segura para centralizar leitura de input.
##
## Responsabilidades:
## - Interpretar toque, arrasto, teclado e pause.
## - Emitir sinais de intenção.
##
## Ainda NÃO controla:
## - Movimento real.
## - Dash real.
## - Pause real.
## - Estado do jogo.

signal move_requested(direction: int)
signal dash_requested
signal pause_requested
signal resume_requested

var is_touching: bool = false
var touch_start: Vector2 = Vector2.ZERO


func handle_unhandled_input(event: InputEvent, screen: String) -> void:
	if screen != "game":
		return

	if event is InputEventScreenTouch:
		var te: InputEventScreenTouch = event as InputEventScreenTouch

		if te.pressed:
			is_touching = true
			touch_start = te.position
		else:
			is_touching = false
			var swipe_delta: Vector2 = te.position - touch_start

			if absf(swipe_delta.x) > 65.0:
				move_requested.emit(1 if swipe_delta.x > 0.0 else -1)
			elif absf(swipe_delta.y) < 80.0:
				dash_requested.emit()

	if event is InputEventScreenDrag:
		var de: InputEventScreenDrag = event as InputEventScreenDrag
		var drag_delta: Vector2 = de.position - touch_start

		if absf(drag_delta.x) > 90.0:
			move_requested.emit(1 if drag_delta.x > 0.0 else -1)
			touch_start = de.position


func handle_input(event: InputEvent, screen: String) -> void:
	if event.is_action_pressed("ui_cancel"):
		if screen == "game":
			pause_requested.emit()
		elif screen == "pause":
			resume_requested.emit()

	if screen != "game":
		return

	if event.is_action_pressed("move_left"):
		move_requested.emit(-1)

	if event.is_action_pressed("move_right"):
		move_requested.emit(1)

	if event.is_action_pressed("dash") or event.is_action_pressed("ui_accept"):
		dash_requested.emit()


func reset_touch() -> void:
	is_touching = false
	touch_start = Vector2.ZERO
