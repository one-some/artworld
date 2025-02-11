class_name Weapon extends Node2D

@onready var bullet_container = Utils.from_group("BulletContainer")
@onready var player_cam = Utils.from_group("PlayerCam")
@onready var tip = $PointLight2D

var shoot_time = 0.1
var shake_oomf = 1.0
var base_damage = 5.0

func shoot_fx() -> void:
    player_cam.shake(shake_oomf)
    $AudioStreamPlayer2D.play()
    $AnimationPlayer.stop()
    $AnimationPlayer.play("shoot")

func damage_for(distance: float) -> float:
    var dropoff = 5
    var damage = self.base_damage + (1000.0 * dropoff / distance)
    damage = max(damage, 0)
    return damage