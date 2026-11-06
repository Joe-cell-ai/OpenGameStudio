extends Node3D
## Builds a lightweight, original futuristic city around the existing player.
## All geometry is generated from built-in primitives so the prototype has no
## third-party asset dependencies and remains suitable for mobile testing.

const ROAD_LENGTH := 80.0
const ROAD_WIDTH := 14.0

var _road_material: StandardMaterial3D
var _sidewalk_material: StandardMaterial3D
var _building_materials: Array[StandardMaterial3D] = []
var _window_material: StandardMaterial3D
var _marking_material: StandardMaterial3D
var _metal_material: StandardMaterial3D
var _lamp_material: StandardMaterial3D


func _ready() -> void:
    _create_materials()
    var city := Node3D.new()
    city.name = "GeneratedCity"
    add_child(city)
    _build_road(city)
    _build_sidewalks(city)
    _build_buildings(city)
    _build_street_lights(city)
    _build_roadside_props(city)


func _create_materials() -> void:
    _road_material = _material(Color(0.055, 0.075, 0.095), 0.15, 0.92)
    _sidewalk_material = _material(Color(0.24, 0.27, 0.29), 0.05, 0.9)
    _window_material = _material(Color(0.12, 0.48, 0.62), 0.35, 0.28)
    _marking_material = _material(Color(0.82, 0.78, 0.57), 0.0, 0.75)
    _metal_material = _material(Color(0.12, 0.16, 0.2), 0.65, 0.48)
    _lamp_material = _material(Color(0.55, 0.78, 0.9), 0.15, 0.25)
    _building_materials = [
        _material(Color(0.16, 0.2, 0.25), 0.35, 0.78),
        _material(Color(0.21, 0.24, 0.27), 0.25, 0.82),
        _material(Color(0.13, 0.18, 0.22), 0.4, 0.72),
        _material(Color(0.25, 0.25, 0.24), 0.2, 0.86)
    ]


func _material(color: Color, metallic_value: float, roughness_value: float) -> StandardMaterial3D:
    var result := StandardMaterial3D.new()
    result.albedo_color = color
    result.metallic = metallic_value
    result.roughness = roughness_value
    return result


func _build_road(parent: Node3D) -> void:
    _add_box(parent, "MainRoad", Vector3(0, 0.035, 0), Vector3(ROAD_WIDTH, 0.08, ROAD_LENGTH), _road_material, false)

    # Broken centre markings make the avenue readable without expensive textures.
    for index in range(10):
        var road_z := -36.0 + float(index) * 8.0
        _add_box(
            parent,
            "CentreLine_%02d" % index,
            Vector3(0, 0.09, road_z),
            Vector3(0.16, 0.025, 3.2),
            _marking_material,
            false
        )


func _build_sidewalks(parent: Node3D) -> void:
    for side in [-1, 1]:
        _add_box(
            parent,
            "Sidewalk_%s" % ("Left" if side < 0 else "Right"),
            Vector3(float(side) * 9.2, 0.07, 0),
            Vector3(4.0, 0.14, ROAD_LENGTH),
            _sidewalk_material,
            false
        )


func _build_buildings(parent: Node3D) -> void:
    for side in [-1, 1]:
        for index in range(5):
            var width := 8.0 + float(index % 2) * 2.0
            var depth := 10.0 + float((index + 1) % 2) * 2.0
            var height := 13.0 + float((index * 7 + (1 if side > 0 else 2)) % 4) * 4.0
            var building_x := float(side) * (15.0 + width * 0.5)
            var building_z := -30.0 + float(index) * 15.0
            var building_name := "Building_%s_%02d" % ["L" if side < 0 else "R", index + 1]
            var building_material: StandardMaterial3D = _building_materials[(index + (1 if side > 0 else 0)) % _building_materials.size()]

            _add_box(
                parent,
                building_name,
                Vector3(building_x, height * 0.5, building_z),
                Vector3(width, height, depth),
                building_material,
                true
            )
            _add_building_windows(parent, side, building_x, building_z, width, height, index)


func _add_building_windows(parent: Node3D, side: int, building_x: float, building_z: float, width: float, height: float, building_index: int) -> void:
    var facade_x := building_x - float(side) * (width * 0.5 + 0.065)
    var floor_count := int(height / 3.5)
    for floor_index in range(1, floor_count):
        for window_index in range(2):
            var offset_z := -2.2 + float(window_index) * 4.4
            var window_y := 1.8 + float(floor_index) * 3.3
            _add_box(
                parent,
                "Window_%02d_%02d_%02d" % [building_index, floor_index, window_index],
                Vector3(facade_x, window_y, building_z + offset_z),
                Vector3(0.12, 1.35, 1.65),
                _window_material,
                false
            )


func _build_street_lights(parent: Node3D) -> void:
    for side in [-1, 1]:
        for index in range(4):
            var light_z := -27.0 + float(index) * 18.0
            var light_x := float(side) * 7.0
            var pole := MeshInstance3D.new()
            pole.name = "StreetLightPole_%s_%02d" % ["L" if side < 0 else "R", index + 1]
            var pole_mesh := CylinderMesh.new()
            pole_mesh.top_radius = 0.09
            pole_mesh.bottom_radius = 0.13
            pole_mesh.height = 4.2
            pole.mesh = pole_mesh
            pole.material_override = _metal_material
            pole.position = Vector3(light_x, 2.1, light_z)
            parent.add_child(pole)

            _add_box(
                parent,
                "StreetLightArm_%s_%02d" % ["L" if side < 0 else "R", index + 1],
                Vector3(light_x - float(side) * 0.45, 4.12, light_z),
                Vector3(1.0, 0.1, 0.12),
                _metal_material,
                false
            )
            _add_sphere(
                parent,
                "StreetLightLamp_%s_%02d" % ["L" if side < 0 else "R", index + 1],
                Vector3(light_x - float(side) * 0.88, 4.0, light_z),
                0.22,
                _lamp_material
            )


func _build_roadside_props(parent: Node3D) -> void:
    # Low concrete barriers frame the avenue and give the street some scale.
    for side in [-1, 1]:
        for index in range(6):
            var prop_z := -34.0 + float(index) * 13.5
            _add_box(
                parent,
                "RoadBarrier_%s_%02d" % ["L" if side < 0 else "R", index + 1],
                Vector3(float(side) * 11.6, 0.42, prop_z),
                Vector3(0.65, 0.8, 3.8),
                _sidewalk_material,
                true
            )


func _add_box(parent: Node3D, node_name: String, world_position: Vector3, box_size: Vector3, material: StandardMaterial3D, with_collision: bool) -> void:
    if with_collision:
        var body := StaticBody3D.new()
        body.name = node_name
        body.position = world_position
        var mesh_instance := MeshInstance3D.new()
        mesh_instance.name = "Mesh"
        var box_mesh := BoxMesh.new()
        box_mesh.size = box_size
        mesh_instance.mesh = box_mesh
        mesh_instance.material_override = material
        body.add_child(mesh_instance)
        var collision := CollisionShape3D.new()
        collision.name = "Collision"
        var box_shape := BoxShape3D.new()
        box_shape.size = box_size
        collision.shape = box_shape
        body.add_child(collision)
        parent.add_child(body)
    else:
        var mesh_instance := MeshInstance3D.new()
        mesh_instance.name = node_name
        var box_mesh := BoxMesh.new()
        box_mesh.size = box_size
        mesh_instance.mesh = box_mesh
        mesh_instance.material_override = material
        mesh_instance.position = world_position
        parent.add_child(mesh_instance)


func _add_sphere(parent: Node3D, node_name: String, world_position: Vector3, radius: float, material: StandardMaterial3D) -> void:
    var mesh_instance := MeshInstance3D.new()
    mesh_instance.name = node_name
    var sphere_mesh := SphereMesh.new()
    sphere_mesh.radius = radius
    sphere_mesh.height = radius * 2.0
    mesh_instance.mesh = sphere_mesh
    mesh_instance.material_override = material
    mesh_instance.position = world_position
    parent.add_child(mesh_instance)
