// =====================================================
// ControllerUI — STEP
// =====================================================

// Mouse GUI
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);


// ---------- SCROLL VERTICAL: ASSETS ----------
if (point_in_rectangle(mx, my, rect_assets.x1, rect_assets.y1, rect_assets.x2, rect_assets.y2)) {
    asset_scroll += (mouse_wheel_down() - mouse_wheel_up()) * asset_scroll_step;

    if (mouse_check_button_pressed(mb_left)) {
        asset_dragging = true;
        asset_drag_start_y = my;
        asset_drag_start_scroll = asset_scroll;
    }
}
if (asset_dragging) {
    asset_scroll = asset_drag_start_scroll + (my - asset_drag_start_y);
    if (mouse_check_button_released(mb_left)) asset_dragging = false;
}

// Limitar scroll de assets
var assets_content_h  = array_length(assets) * (asset_cell_h + asset_cell_margin) + asset_cell_margin;
var assets_view_h     = rect_assets.y2 - rect_assets.y1;
var assets_min_scroll = min(0, assets_view_h - assets_content_h);
asset_scroll = clamp(asset_scroll, assets_min_scroll, 0);

// ---------- SCROLL HORIZONTAL: CARRUSEL ----------
var view_w_total    = (rect_scenes.x2 - rect_scenes.x1);
var view_w_inner    = view_w_total - (scene_gap * 2);
var content_w       = (scene_count * scene_thumb_w) + ((scene_count - 1) * scene_gap);
var scenes_min_scroll = min(0, view_w_inner - content_w);

if (point_in_rectangle(mx, my, rect_scenes.x1, rect_scenes.y1, rect_scenes.x2, rect_scenes.y2)) {
    var wheel = 0;
    if (mouse_wheel_down()) wheel += 1;
    if (mouse_wheel_up())   wheel -= 1;
    if (wheel != 0) scenes_scroll += wheel * scenes_scroll_step;

    if (mouse_check_button_pressed(mb_left)) {
        drag_scrolling_scenes = true;
        drag_start_x = mx;
        drag_start_scroll = scenes_scroll;
    }
}
if (drag_scrolling_scenes) {
    scenes_scroll = drag_start_scroll + (mx - drag_start_x);
    if (mouse_check_button_released(mb_left)) drag_scrolling_scenes = false;
}
scenes_scroll = clamp(scenes_scroll, scenes_min_scroll, 0);

// ---------- DRAG & DROP: INICIO DESDE PALETA ----------
if (mouse_check_button_pressed(mb_left) && !drag_active) {
    var idx = ui_get_asset_index_at(mx, my);

    if (idx != -1) {
        drag_active      = true;
        drag_asset_index = idx;
        drag_sprite      = assets[idx].spr;
       drag_scale       = ui_asset_get(idx, "scale", 1);

    }
}

// ---------- DRAG & DROP: SOLTAR EN ESCENA ----------
if (drag_active && mouse_check_button_released(mb_left)) {
    if (point_in_rectangle(mx, my, rect_scene.x1, rect_scene.y1, rect_scene.x2, rect_scene.y2)) {
        var gx = clamp(mx, rect_scene.x1, rect_scene.x2);
        var gy = clamp(my, rect_scene.y1, rect_scene.y2);

        // asegurar lista independiente
        if (is_undefined(placed_by_scene[current_scene]) || !is_array(placed_by_scene[current_scene])) {
            placed_by_scene[current_scene] = [];
        }

        var itm_name  = assets[drag_asset_index].name;
        var itm_spr   = assets[drag_asset_index].spr;
        var itm_scale = ui_asset_get(drag_asset_index, "scale", 1);


        var placed_list = placed_by_scene[current_scene];
        array_push(placed_list, { name: itm_name, spr: itm_spr, x: gx, y: gy, scale: itm_scale });
        placed_by_scene[current_scene] = placed_list;

        // validar escena
       scene_complete[current_scene] = ui_is_scene_complete(current_scene);

    }

    // terminar drag
    drag_active      = false;
    drag_asset_index = -1;
    drag_sprite      = noone;
}

// ---------- SELECCIÓN DE ESCENA (con bloqueo) ----------
if (mouse_check_button_pressed(mb_left) && !drag_scrolling_scenes && !asset_dragging && !drag_active) {
    if (point_in_rectangle(mx, my, rect_scenes.x1, rect_scenes.y1, rect_scenes.x2, rect_scenes.y2)) {
        var local_x = (mx - (rect_scenes.x1 + scene_gap)) - scenes_scroll;
        var slot_w  = scene_thumb_w + scene_gap;
        var idx2    = floor(local_x / slot_w);

        if (idx2 >= 0 && idx2 < scene_count) {
            var card_x1 = (rect_scenes.x1 + scene_gap) + scenes_scroll + idx2 * slot_w;
            var card_y1 = rect_scenes.y1 + scene_gap;
            var card_x2 = card_x1 + scene_thumb_w;
            var card_y2 = card_y1 + scene_thumb_h;

            if (mx >= card_x1 && mx <= card_x2 && my >= card_y1 && my <= card_y2) {
                if (!lock_progression) {
                    current_scene = idx2;
                } else {
                    if (idx2 <= current_scene) {
                        current_scene = idx2; // hacia atrás permitido
                    } else if (scene_complete[current_scene]) {
                        current_scene = current_scene + 1; // avanzar de a una si actual completa
                    } else {
                        // feedback opcional de bloqueo
                    }
                }
            }
        }
    }
}

// -------------------------------
// 1. Click en sprite existente → empezar movimiento
// -------------------------------
if (!drag_active && moving_item_index < 0 && mouse_check_button_pressed(mb_left)) {
    var placed_list = placed_by_scene[current_scene];
    if (is_array(placed_list)) {
        for (var i = array_length(placed_list) - 1; i >= 0; i--) {
            var itm = placed_list[i];
            var spr = itm.spr;
            var scale = itm.scale;
            var sw = sprite_get_width(spr) * scale;
            var sh = sprite_get_height(spr) * scale;

            if (point_in_rectangle(mx, my, itm.x - sw/2, itm.y - sh/2, itm.x + sw/2, itm.y + sh/2)) {
                moving_item_index = i;
                moving_offset_x = mx - itm.x;
                moving_offset_y = my - itm.y;
                break;
            }
        }
    }
}

// -------------------------------
// 2. Mover sprite existente
// -------------------------------
if (moving_item_index >= 0 && mouse_check_button(mb_left)) {
    var placed_list = placed_by_scene[current_scene];
    if (is_array(placed_list)) {
        placed_list[moving_item_index].x = mx - moving_offset_x;
        placed_list[moving_item_index].y = my - moving_offset_y;
    }
}

// -------------------------------
// 3. Soltar sprite
// -------------------------------
if (moving_item_index >= 0 && mouse_check_button_released(mb_left)) {
    var placed_list = placed_by_scene[current_scene];
    if (is_array(placed_list)) {
        var itm = placed_list[moving_item_index];

        itm.x = clamp(itm.x, rect_scene.x1, rect_scene.x2);
        itm.y = clamp(itm.y, rect_scene.y1, rect_scene.y2);
        placed_list[moving_item_index] = itm;
    }

    moving_item_index = -1;
    scene_complete[current_scene] = ui_is_scene_complete(current_scene);
}

// ===========================================
// 4 Eliminar sprite con click derecho
// ===========================================
if (!drag_active && mouse_check_button_pressed(mb_right)) {
    var placed_list = placed_by_scene[current_scene];
    if (is_array(placed_list)) {
        for (var i = array_length(placed_list) - 1; i >= 0; i--) {
            var itm = placed_list[i];
            var spr = itm.spr;
            var scale = itm.scale;
            var sw = sprite_get_width(spr) * scale;
            var sh = sprite_get_height(spr) * scale;

            if (point_in_rectangle(mx, my, itm.x - sw/2, itm.y - sh/2, itm.x + sw/2, itm.y + sh/2)) {
                array_delete(placed_list, i, 1);
                break;
            }
        }
    }
}
