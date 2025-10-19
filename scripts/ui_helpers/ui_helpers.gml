/// ui_helpers.gml
/// Helpers globales para UI del editor

// ---------------- Normalización ----------------
function _ui_norm(s) {
    return string_lower(string_trim(string(s)));
}

// ---------------- Lectura segura de assets ----------------
function ui_asset_get(i, field, default_value) {
    var a = assets[i];
    if (is_struct(a) && variable_struct_exists(a, field)) {
        return variable_struct_get(a, field);
    }
    return default_value;
}

// ---------------- Paleta: hit test ----------------
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

        if (mx >= x1 && mx <= x2 && my >= y1 && my <= y2) return i;
        ay += asset_cell_h + asset_cell_margin;
    }
    return -1;
}

// ---------------- Reglas: ¿escena completa? ----------------
// Usa el mismo conteo robusto de hits (ver función más abajo)
function ui_is_scene_complete(s) {
    if (s < 0 || s >= array_length(scene_rules)) return false;
    var placed = (s < array_length(placed_by_scene) && is_array(placed_by_scene[s]))
               ? placed_by_scene[s] : [];
    return ui_count_hits(s, placed) >= array_length(scene_rules[s]);
}

// ---------------- Máscara / palabra ----------------
function ui_make_mask_from_phrase(phrase) {
    var L = string_length(phrase);
    var mask = array_create(L);
    for (var i = 0; i < L; i++) {
        var ch = string_char_at(phrase, i+1);
        mask[i] = (ch == " ");
    }
    return mask;
}

function ui_draw_phrase_masked(phrase, mask, x, y) {
    var Lp = string_length(phrase);
    var out = "";
    for (var i = 0; i < Lp; i++) {
        var ch = string_char_at(phrase, i+1);
        if (ch == " ") {
            out += "  ";
        } else {
            var show = (i < array_length(mask)) ? mask[i] : false;
            out += show ? ch : "_";
            out += " ";
        }
    }
    draw_text(x, y, out);
}

// (opcional) Revelar letras sueltas
function ui_reveal_next(mask, phrase, n) {
    if (!is_array(mask) || n <= 0) return mask;
    var hidden = 0;
    for (var i = 0; i < array_length(mask); i++) if (!mask[i]) hidden++;
    n = clamp(n, 0, hidden);
    for (var j = 0, L = array_length(mask); j < L && n > 0; j++) {
        if (!mask[j]) { mask[j] = true; n--; }
    }
    return mask;
}

// ---------------- Reglas: utilidades ----------------
function ui_is_required_in_scene(s, name) {
    if (s < 0 || s >= array_length(scene_rules)) return false;
    var req = scene_rules[s], nm = _ui_norm(name);
    for (var i = 0; i < array_length(req); i++) if (_ui_norm(req[i]) == nm) return true;
    return false;
}

function ui_required_count_for_name(s, name) {
    if (s < 0 || s >= array_length(scene_rules)) return 0;
    var req = scene_rules[s], nm = _ui_norm(name), c = 0;
    for (var i = 0; i < array_length(req); i++) if (_ui_norm(req[i]) == nm) c++;
    return c;
}

function ui_is_new_correct_hit(s, placed_list, name) {
    var need = ui_required_count_for_name(s, name);
    if (need <= 0) return false; // no es requerido
    var have = 0, nm = _ui_norm(name);
    if (is_array(placed_list)) {
        for (var i = 0; i < array_length(placed_list); i++)
            if (_ui_norm(placed_list[i].name) == nm) have++;
    }
    return (have < need);
}

// ---------------- Segmentado de palabra por escena ----------------
function ui_make_segments_for_phrase(phrase, parts) {
    var L = string_length(phrase);
    parts = max(1, parts); // mantener cantidad de partes pedida
    var base  = (parts > 0) ? (L div parts) : 0;
    var extra = (parts > 0) ? (L mod parts) : 0;

    var segs = array_create(parts);
    var pos = 0;
    for (var i = 0; i < parts; i++) {
        var len = base + (i < extra ? 1 : 0);
        segs[i] = { start: pos, len: len }; // índices 0-based
        pos += len;
    }
    return segs;
}

function ui_reveal_segment(mask, seg) {
    var s = seg.start;
    var e = seg.start + seg.len; // exclusivo
    var L = array_length(mask);
    for (var i = s; i < e && i < L; i++) mask[i] = true;
    return mask;
}

// ---------------- Conteo de aciertos actuales (ROBUSTO) ----------------
// Mapa de frecuencias: evita problemas con array_delete dentro de bucles
function ui_count_hits(s, placed_list) {
    if (s < 0 || s >= array_length(scene_rules)) return 0;

    // 1) Construir mapa de requeridos: name_norm -> cantidad
    var req = scene_rules[s];
    var need = ds_map_create();
    for (var i = 0; i < array_length(req); i++) {
        var key = _ui_norm(req[i]);
        if (ds_map_exists(need, key)) need[? key] += 1; else need[? key] = 1;
    }

    // 2) Recorrer colocados y descontar cuando corresponda
    var hits = 0;
    if (is_array(placed_list)) {
        for (var p = 0; p < array_length(placed_list); p++) {
            var nm = _ui_norm(placed_list[p].name);
            if (ds_map_exists(need, nm)) {
                var left = need[? nm];
                if (left > 0) {
                    need[? nm] = left - 1;
                    hits++;
                }
            }
        }
    }

    ds_map_destroy(need);
    return hits;
}

// ---------------- Sincronización de máscara ----------------
function ui_mask_is_full(mask) {
    if (!is_array(mask)) return false;
    for (var i = 0; i < array_length(mask); i++) if (!mask[i]) return false;
    return true;
}

function ui_sync_mask_from_hits(s) {
    if (s < 0 || s >= array_length(scene_keywords)) return;
    if (s >= array_length(keyword_segments)) return;

    var phrase = scene_keywords[s];
    var mask   = ui_make_mask_from_phrase(phrase);

    var placed_list = (s < array_length(placed_by_scene) && is_array(placed_by_scene[s]))
                    ? placed_by_scene[s] : [];

    var hits = ui_count_hits(s, placed_list);
    var segs = keyword_segments[s];
    var maxh = min(hits, array_length(segs));

    for (var h = 0; h < maxh; h++) mask = ui_reveal_segment(mask, segs[h]);

    keyword_masks[s] = mask;
}
