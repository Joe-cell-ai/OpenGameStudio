extends CanvasLayer
## Lightweight touch controls: left side moves, right side rotates the camera.

var player: AdventurePlayer
var move_touch := -1
var look_touch := -1
var move_origin := Vector2.ZERO
var move_current := Vector2.ZERO
var jump_button: Button

func _ready() -> void:
    player = get_parent().get_node_or_null("Player") as AdventurePlayer
    if not OS.has_feature("mobile") and not DisplayServer.is_touchscreen_available():
        return

    var layer := Control.new()
    layer.name = "TouchLayer"
    layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(layer)

    jump_button = Button.new()
    jump_button.text = "JUMP"
    jump_button.custom_minimum_size = Vector2(104, 64)
    jump_button.anchor_left = 1.0
    jump_button.anchor_top = 1.0
    jump_button.anchor_right = 1.0
    jump_button.anchor_bottom = 1.0
    jump_button.offset_left = -132
    jump_button.offset_top = -100
    jump_button.offset_right = -24
    jump_button.offset_bottom = -36
    jump_button.add_theme_font_size_override("font_size", 18)
    jump_button.pressed.connect(_on_jump)
    layer.add_child(jump_button)

func _input(event: InputEvent) -> void:
    if player == null:
        return
    if event is InputEventScreenTouch:
        if event.pressed:
            if event.position.x < get_viewport().get_visible_rect().size.x * 0.48 and move_touch == -1:
                move_touch = event.index
                move_origin = event.position
                move_current = event.position
            elif look_touch == -1:
                look_touch = event.index
        else:
            if event.index == move_touch:
                move_touch = -1
                player.mobile_move = Vector2.ZERO
            if event.index == look_touch:
                look_touch = -1
    elif event is InputEventScreenDrag:
        if event.index == move_touch:
            move_current = event.position
            var delta := (move_current - move_origin) / 70.0
            player.mobile_move = Vector2(clamp(delta.x, -1, 1), clamp(delta.y, -1, 1))
        elif event.index == look_touch:
            player.mobile_look = event.relative

func _on_jump() -> void:
    if player:
        player.jump_requested = true
