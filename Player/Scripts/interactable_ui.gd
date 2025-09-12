class_name AimDot
extends CenterContainer

var circle_raduis: float
var circle_color: Color
var outline_raduis: float
var outline_color: Color
var filled: bool 
var circle_width: float 
var antialiass: bool 

func _ready() -> void:
	var default_width:= circle_width
	if filled:
		circle_width = -1
	else:
		circle_width = default_width


func _draw() -> void:
	draw_circle(Vector2.ZERO, circle_raduis, circle_color, filled, circle_width, antialiass)
	draw_circle(Vector2.ZERO, outline_raduis + 0.5 , circle_color, filled, circle_width, antialiass)
