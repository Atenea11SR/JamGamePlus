// Fondo de toda la pantalla
draw_clear(col_bg);

// Título
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_set_color(col_title);
draw_text(global.SW * 0.5, 24, title_text);

// Panel ESCENA
draw_set_color(col_panel);
draw_rectangle(rect_scene.x1, rect_scene.y1, rect_scene.x2, rect_scene.y2, false);

// Panel ASSETS (derecha)
draw_rectangle(rect_assets.x1, rect_assets.y1, rect_assets.x2, rect_assets.y2, false);

// Panel CARRUSEL (abajo)
draw_rectangle(rect_scenes.x1, rect_scenes.y1, rect_scenes.x2, rect_scenes.y2, false);

//  bordes finos para que se noten
draw_set_color(c_black);
draw_rectangle(rect_scene.x1, rect_scene.y1, rect_scene.x2, rect_scene.y2, true);
draw_rectangle(rect_assets.x1, rect_assets.y1, rect_assets.x2, rect_assets.y2, true);
draw_rectangle(rect_scenes.x1, rect_scenes.y1, rect_scenes.x2, rect_scenes.y2, true);


///PALETA DE ASSETS
gpu_set_scissor(
    rect_assets.x1, rect_assets.y1,
    rect_assets.x2 - rect_assets.x1,
    rect_assets.y2 - rect_assets.y1
);

// Punto inicial de dibujo dentro del panel
var ax = rect_assets.x1 + asset_cell_margin;
var ay = rect_assets.y1 + asset_cell_margin + asset_scroll;

// Recorrer cada asset
for (var i = 0; i < array_length(assets); i++) {
    // Rect de la celda
    var x1 = ax;
    var y1 = ay;
    var x2 = rect_assets.x2 - asset_cell_margin;
    var y2 = ay + asset_cell_h;

    // Caja de fondo
    draw_set_color(make_color_rgb(90, 90, 90));
    draw_rectangle(x1, y1, x2, y2, false);

    // Mini área de thumbnai a la izquierda
var thumb = 72;
var tx1 = x1 + 8, ty1 = y1 + 8;    
var tw  = thumb, th  = thumb;     
var cx  = tx1 + tw * 0.5;         
var cy  = ty1 + th * 0.5;          

// Fondo del cuadro del thumbnail
draw_set_color(make_color_rgb(60, 60, 60));
draw_rectangle(tx1, ty1, tx1 + tw, ty1 + th, false);

// Si hay sprite, dibujarlo escalado al cuadro
if (assets[i].spr != noone) {
    var s  = assets[i].spr;
    var sw = sprite_get_width(s);
    var sh = sprite_get_height(s);

   
    var fit = min(tw / sw, th / sh) * 0.9;

   
    if (!is_undefined(assets[i].scale)) fit *= assets[i].scale;

   
    var ox = sprite_get_xoffset(s);
    var oy = sprite_get_yoffset(s);
    var dx = (ox - sw * 0.5) * fit;
    var dy = (oy - sh * 0.5) * fit;

    draw_sprite_ext(s, 0, cx - dx, cy - dy, fit, fit, 0, c_white, 1);
}



    // Nombre
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    draw_text(x1 + 8 + thumb + 12, (y1 + y2) * 0.5, assets[i].name);

    ay += asset_cell_h + asset_cell_margin;
}

gpu_set_scissor(0, 0, global.SW, global.SH);


//CARRUSEL DE ESCENAS (Clipping + Scroll Horizontal) 
gpu_set_scissor(
    rect_scenes.x1, rect_scenes.y1,
    rect_scenes.x2 - rect_scenes.x1,
    rect_scenes.y2 - rect_scenes.y1
);

var sx = rect_scenes.x1 + scene_gap + scenes_scroll;
var sy = rect_scenes.y1 + scene_gap;

for (var s = 0; s < scene_count; s++) {
    var x1 = sx;
    var y1 = sy;
    var x2 = sx + scene_thumb_w;
    var y2 = sy + scene_thumb_h;

    // Fondo de tarjeta
    var col = (s == current_scene) ? c_white : c_ltgray;
    draw_set_color(col);
    draw_rectangle(x1, y1, x2, y2, false);

    // Borde
    draw_set_color((s == current_scene) ? c_white : c_black);
    draw_rectangle(x1, y1, x2, y2, true);

    // Preview (placeholder)
    draw_set_color(make_color_rgb(70, 70, 70));
    draw_rectangle(x1 + 8, y1 + 28, x2 - 8, y2 - 8, false);

    // Título de escena
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_black);
    var label = (s < array_length(scene_names)) ? scene_names[s] : ("Escena " + string(s + 1));
    draw_text(x1 + 8, y1 + 6, label);

    sx += scene_thumb_w + scene_gap;
}

gpu_set_scissor(0, 0, global.SW, global.SH);
