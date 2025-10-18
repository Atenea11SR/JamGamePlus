
// Mouse en coordenadas GUI
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);


// SCROLL VERTICAL: ASSETS
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
var assets_content_h = array_length(assets) * (asset_cell_h + asset_cell_margin) + asset_cell_margin;
var assets_view_h    = rect_assets.y2 - rect_assets.y1;
var assets_min_scroll = min(0, assets_view_h - assets_content_h);
asset_scroll = clamp(asset_scroll, assets_min_scroll, 0);


// SCROLL HORIZONTAL: CARRUSEL
var view_w_total   = (rect_scenes.x2 - rect_scenes.x1);
var view_w_inner   = view_w_total - (scene_gap * 2);
var content_w      = (scene_count * scene_thumb_w) + ((scene_count - 1) * scene_gap);
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

// Selección de escena (solo si NO se está arrastrando el carrusel)
if (mouse_check_button_pressed(mb_left) && !drag_scrolling_scenes) {
    if (point_in_rectangle(mx, my, rect_scenes.x1, rect_scenes.y1, rect_scenes.x2, rect_scenes.y2)) {
        var local_x = (mx - (rect_scenes.x1 + scene_gap)) - scenes_scroll;
        var slot_w  = scene_thumb_w + scene_gap;
        var idx     = floor(local_x / slot_w);

        if (idx >= 0 && idx < scene_count) {
            var card_x1 = (rect_scenes.x1 + scene_gap) + scenes_scroll + idx * slot_w;
            var card_y1 = rect_scenes.y1 + scene_gap;
            var card_x2 = card_x1 + scene_thumb_w;
            var card_y2 = card_y1 + scene_thumb_h;
            if (mx >= card_x1 && mx <= card_x2 && my >= card_y1 && my <= card_y2) {
                current_scene = idx;
            }
        }
    }
}
