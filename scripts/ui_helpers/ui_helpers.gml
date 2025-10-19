/// ui_helpers.gml
/// Helpers globales para UI del editor

/// Devuelve assets[i].<field> o default_value si no existe
function ui_asset_get(i, field, default_value) {
    var a = assets[i];
    if (is_struct(a) && variable_struct_exists(a, field)) {
        return variable_struct_get(a, field);
    }
    return default_value;
}

/// Devuelve el índice del asset bajo el mouse en la paleta, o -1
function ui_get_asset_index_at(mx, my) {
    if (!point_in_rectangle(mx, my, rect_assets.x1, rect_assets.y1, rect_assets.x2, rect_assets.y2)) {
        return -1;
    }
    var ay = rect_assets.y1 + asset_cell_margin + asset_scroll;

    for (var i = 0; i < array_length(assets); i++) {
        var x1 = rect_assets.x1 + asset_cell_margin;
        var y1 = ay;
        var x2 = rect_assets.x2 - asset_cell_margin;
        var y2 = ay + asset_cell_h;

        if (mx >= x1 && mx <= x2 && my >= y1 && my <= y2) {
            return i;
        }
        ay += asset_cell_h + asset_cell_margin;
    }
    return -1;
}

/// true si la escena s cumple todas sus reglas (por nombre exacto)
function ui_is_scene_complete(s) {
    var needed = scene_rules[s];
    var placed = placed_by_scene[s];

    var remaining = array_create(array_length(needed));
    for (var i = 0; i < array_length(needed); i++) remaining[i] = needed[i];

    for (var p = 0; p < array_length(placed); p++) {
        var nm = placed[p].name;
        var found = -1;
        for (var r = 0; r < array_length(remaining); r++) {
            if (remaining[r] == nm) { found = r; break; }
        }
        if (found != -1) {
            remaining = array_delete(remaining, found, 1); // reasignar
        }
    }
    return array_length(remaining) == 0;
}
