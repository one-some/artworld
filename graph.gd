@tool
extends Control

var sample = _sample

func _sample(x: int) -> float:
    var dropoff = 5.0
    var base_damage = 10.0
    return base_damage + (1000.0 * dropoff / x)

func _draw() -> void:
    var domain = 1700
    var last_pos = Vector2(0, 0)
    for i in range(self.size.x):
        var y_point = self.size.y - (sample.call(i / self.size.x * domain) if sample else 0)
        y_point = max(0, y_point)
        var new_pos = Vector2(i, y_point)

        draw_line(last_pos, new_pos, Color("#4287f5"))

        if i % 2 == 0:
            draw_line(Vector2(i, self.size.y), new_pos, Color("#4287f5"))

        last_pos = new_pos



func _process(delta: float) -> void:
    queue_redraw()