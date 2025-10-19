// =====================================================
// ControllerUI — DRAW GUI  (fondo cover + minis al completar)
// =====================================================

draw_clear(col_bg);

// ---------- TÍTULO ----------
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_set_color(col_title);
draw_text(global.SW * 0.5, 24, title_text);

// ---------- PANEL SUPERIOR: palabra ----------
draw_set_color(col_panel);
draw_rectangle(rect_keyword.x1, rect_keyword.y1, rect_keyword.x2, rect_keyword.y2, false);
draw_set_color(c_black);
draw_rectangle(rect_keyword.x1, rect_keyword.y1, rect_keyword.x2, rect_keyword.y2, true);

// Re-sincroniza por si cambió algo en STEP
ui_sync_mask_from_hits(current_scene);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
var phrase = scene_keywords[current_scene];
var mask   = keyword_masks[current_scene];
ui_draw_phrase_masked(phrase, mask, rect_keyword.x1 + 12, rect_keyword.y1 + 8);

// ---------- PANELES ----------
draw_set_color(col_panel);
draw_rectangle(rect_scene.x1,  rect_scene.y1,  rect_scene.x2,  rect_scene.y2,  false);
draw_rectangle(rect_assets.x1, rect_assets.y1, rect_assets.x2, rect_assets.y2, false);
draw_rectangle(rect_scenes.x1, rect_scenes.y1, rect_scenes.x2, rect_scenes.y2, false);

// Bordes
draw_set_color(c_black);
draw_rectangle(rect_scene.x1,  rect_scene.y1,  rect_scene.x2,  rect_scene.y2,  true);
draw_rectangle(rect_assets.x1, rect_assets.y1, rect_assets.x2, rect_assets.y2, true);
draw_rectangle(rect_scenes.x1, rect_scenes.y1, rect_scenes.x2, rect_scenes.y2, true);

// ---------- PALETA DE ASSETS ----------
gpu_set_scissor(rect_assets.x1, rect_assets.y1,
                rect_assets.x2 - rect_assets.x1,
                rect_assets.y2 - rect_assets.y1);

var ax = rect_assets.x1 + asset_cell_margin;
var ay = rect_assets.y1 + asset_cell_margin + asset_scroll;

for (var i = 0; i < array_length(assets); i++) {
    var x1 = ax;
    var y1 = ay;
    var x2 = rect_assets.x2 - asset_cell_margin;
    var y2 = ay + asset_cell_h;

    // Fondo celda
    draw_set_color(make_color_rgb(90, 90, 90));
    draw_rectangle(x1, y1, x2, y2, false);

    // Marco thumbnail
    var thumb = 72;
    var tx1 = x1 + 8, ty1 = y1 + 8;
    var tw  = thumb, th  = thumb;
    var cx  = tx1 + tw * 0.5;
    var cy  = ty1 + th * 0.5;

    draw_set_color(make_color_rgb(60, 60, 60));
    draw_rectangle(tx1, ty1, tx1 + tw, ty1 + th, false);

    // Miniatura
    var s_prev = ui_asset_get(i, "spr_preview", assets[i].spr);
    if (s_prev != noone) {
        var sw = sprite_get_width(s_prev);
        var sh = sprite_get_height(s_prev);
        var fit = min(tw / sw, th / sh) * 0.9;
        fit *= ui_asset_get(i, "preview_scale", 1);
        var ox = sprite_get_xoffset(s_prev);
        var oy = sprite_get_yoffset(s_prev);
        var dx = (ox - sw * 0.5) * fit;
        var dy = (oy - sh * 0.5) * fit;
        draw_sprite_ext(s_prev, 0, cx - dx, cy - dy, fit, fit, 0, c_white, 1);
    }

    // Nombre
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    draw_text(x1 + 8 + thumb + 12, (y1 + y2) * 0.5, assets[i].name);

    ay += asset_cell_h + asset_cell_margin;
}
gpu_set_scissor(0, 0, global.SW, global.SH);

// ---------- ESCENA: fondo cover + colocados + ghost ----------
gpu_set_scissor(rect_scene.x1, rect_scene.y1,
                rect_scene.x2 - rect_scene.x1,
                rect_scene.y2 - rect_scene.y1);

// Fondo cover
var bg = scene_bg[current_scene];
if (bg != noone) {
    var sw_bg = sprite_get_width(bg), sh_bg = sprite_get_height(bg);
    var rw = rect_scene.x2 - rect_scene.x1, rh = rect_scene.y2 - rect_scene.y1;
    var sc = max(rw / sw_bg, rh / sh_bg);
    var cx = rect_scene.x1 + rw * 0.5, cy = rect_scene.y1 + rh * 0.5;
    draw_sprite_ext(bg, 0, cx, cy, sc, sc, 0, c_white, 1);
}

// Colocados
var placed_list = placed_by_scene[current_scene];
for (var k = 0; k < array_length(placed_list); k++) {
    var itm = placed_list[k];
    if (itm.spr != noone) {
        draw_sprite_ext(itm.spr, 0, itm.x, itm.y, itm.scale, itm.scale, 0, c_white, 1);
    } else {
        draw_set_color(c_white);
        draw_text(itm.x, itm.y, itm.name);
    }
}

// Ghost
if (drag_active && drag_sprite != noone) {
    var mx = device_mouse_x_to_gui(0);
    var my = device_mouse_y_to_gui(0);
    var gx = clamp(mx, rect_scene.x1, rect_scene.x2);
    var gy = clamp(my, rect_scene.y1, rect_scene.y2);
    draw_set_alpha(0.7);
    draw_sprite_ext(drag_sprite, 0, gx, gy, drag_scale, drag_scale, 0, c_white, 1);
    draw_set_alpha(1);
}
gpu_set_scissor(0, 0, global.SW, global.SH);

// ---------- CARRUSEL ----------
gpu_set_scissor(rect_scenes.x1, rect_scenes.y1,
                rect_scenes.x2 - rect_scenes.x1,
                rect_scenes.y2 - rect_scenes.y1);

var sx = rect_scenes.x1 + scene_gap + scenes_scroll;
var sy = rect_scenes.y1 + scene_gap;

for (var s = 0; s < scene_count; s++) {
    var x1c = sx, y1c = sy, x2c = sx + scene_thumb_w, y2c = sy + scene_thumb_h;

    // Tarjeta
    var col = (s == current_scene) ? c_white : c_ltgray;
    draw_set_color(col);
    draw_rectangle(x1c, y1c, x2c, y2c, false);
    draw_set_color((s == current_scene) ? c_white : c_black);
    draw_rectangle(x1c, y1c, x2c, y2c, true);

    // Área preview de la tarjeta
    var px1 = x1c + 8, py1 = y1c + 28, px2 = x2c - 8, py2 = y2c - 8;
    draw_set_color(make_color_rgb(70, 70, 70));
    draw_rectangle(px1, py1, px2, py2, false);


   
    if (scene_complete[s] && s < array_length(scene_bg_thumb) && scene_bg_thumb[s] != noone) {
        var th = scene_bg_thumb[s];
        var rw = px2 - px1, rh = py2 - py1;
        var sw = sprite_get_width(th), sh = sprite_get_height(th);
        var sc = max(rw / sw, rh / sh);  // cover
        var cx = (px1 + px2) * 0.5, cy = (py1 + py2) * 0.5;
        draw_sprite_ext(th, 0, cx, cy, sc, sc, 0, c_white, 1);
    }

    // Título
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_black);
    var label = (s < array_length(scene_names)) ? scene_names[s] : ("Scene " + string(s + 1));
    draw_text(x1c + 8, y1c + 6, label);

    // Check si completa
    if (scene_complete[s]) {
        draw_set_color(c_black);
        draw_text(x2c - 20, y1c + 6, "✓");
    }

    sx += scene_thumb_w + scene_gap;
}
gpu_set_scissor(0, 0, global.SW, global.SH);
