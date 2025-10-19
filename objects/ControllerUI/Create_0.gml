// =====================================================
// ControllerUI — CREATE
// =====================================================

// Resolución de referencia (GUI fija)
global.SW = 1920;
global.SH = 1080;

// Paneles base
rect_scene  = {x1:64,  y1:110, x2:960,  y2:500};  // escena
rect_assets = {x1:980, y1:110, x2:1300, y2:700};  // paleta derecha
rect_scenes = {x1:64,  y1:520, x2:960,  y2:700};  // carrusel inferior

// Título
title_text = "RUMPELSTINKIN";

// Colores
col_bg    = make_color_rgb(112,121,104);
col_panel = make_color_rgb(60,55,55);
col_title = c_black;

// Paleta / lista de assets
asset_scroll           = 0;
asset_cell_h           = 96;
asset_cell_margin      = 8;
asset_scroll_step      = 24;
asset_dragging         = false;
asset_drag_start_y     = 0;
asset_drag_start_scroll= 0;

// Falta agregar los otros sprites
assets = [
    { name:"Rey",   spr:king, scale:0.30 },
    { name:"Rumpelstinkin",   spr:Rumpel,   preview:1.0, scale:0.25 },
    { name:"Padre",     spr:father, scale:0.30  },
    { name:"Reina con bebe",    spr:noone },
    { name:"Guardia",  spr:noone },
    { name:"Princesa", spr:princess, scale:0.30 },
    { name:"Princesa pobre",   spr:noone },
    { name:"Guardia",   spr:noone },
    { name:"Objeto",   spr:noone },
    { name:"Objeto",   spr:noone }
];

// Carrusel
scene_count           = 6;
current_scene         = 0;
scenes_scroll         = 0;
scene_thumb_w         = 220;
scene_thumb_h         = 140;
scene_gap             = 16;
scenes_scroll_step    = 48;
drag_scrolling_scenes = false;
drag_start_x          = 0;
drag_start_scroll     = 0;

scene_names = ["Escena 1","Escena 2","Escena 3","Escena 4","Escena 5","Escena 6"];

// Solo 3 tarjetas visibles: recalcular rect del carrusel
var visible_cards = 3;
var carrusel_w    = (visible_cards * scene_thumb_w) + ((visible_cards + 1) * scene_gap);

var carrusel_x1 = rect_scene.x1;
var carrusel_y1 = rect_scene.y2 + 20;
var carrusel_x2 = carrusel_x1 + carrusel_w;
var carrusel_y2 = carrusel_y1 + scene_thumb_h + (2 * scene_gap);

rect_scenes = { x1:carrusel_x1, y1:carrusel_y1, x2:carrusel_x2, y2:carrusel_y2 };

// Drag & Drop runtime
drag_active      = false;
drag_asset_index = -1;
drag_sprite      = noone;
drag_scale       = 1;
drag_offx        = 0;
drag_offy        = 0;

// Colocados por escena (arrays independientes)
placed_by_scene = array_create(scene_count);
for (var i = 0; i < scene_count; i++) {
    placed_by_scene[i] = [];
}

// Reglas por escena (falta ajustar nombres exactos)
scene_rules = [
    ["Molino", "Reina", "Guardia"], // 1
    ["Duende", "Reina"],            // 2 
    ["Duende", "Reina", "Bebe"],    // 3
    ["Duende", "Reina", "Bebe"],    // 4
    ["Guardia"],                    // 5
    ["Reina", "Bebe", "Duende"]     // 6
];

// Estado de completitud
scene_complete = array_create(scene_count);
for (var j = 0; j < scene_count; j++) scene_complete[j] = false;

// Bloqueo de avance hacia escenas futuras
lock_progression = true;


// Moviendo item existente
moving_item_index = -1;
moving_offset_x   = 0;
moving_offset_y   = 0;
