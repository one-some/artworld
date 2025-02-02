@tool
extends Node2D

@onready var inner_label = $Label

@export var label: String = "Something":
    set (value):
        label = value
        inner_label = value

func _ready() -> void:
    if Engine.is_editor_hint(): return
    self.visible = false
