// =====================================================
// ControllerUI — CREATE
// =====================================================

global.SW = 1920;
global.SH = 1080;

// Paneles
rect_scene   = {x1:64,  y1:110, x2:960,  y2:500};
rect_assets  = {x1:980, y1:110, x2:1300, y2:700};
rect_scenes  = {x1:64,  y1:520, x2:960,  y2:700};
rect_keyword = {x1:64,  y1:56,  x2:1300, y2:100};

title_text = "RUMPELSTINKIN";

// Colores
col_bg    = make_color_rgb(112,121,104);
col_panel = make_color_rgb(60,55,55);
col_title = c_black;

// Paleta / lista de assets
asset_scroll            = 0;
asset_cell_h            = 96;
asset_cell_margin       = 8;
asset_scroll_step       = 24;
asset_dragging          = false;
asset_drag_start_y      = 0;
asset_drag_start_scroll = 0;

assets = [
    { name:"King",            spr:king,          scale:0.27, spr_preview:king_mini,        preview_scale:1.0 },
    { name:"Rumpelstinkin",   spr:Rumpel,        scale:0.25, spr_preview:rumple_mini,      preview_scale:1.0 },
    { name:"Father",          spr:father,        scale:0.30, spr_preview:dad_mini,         preview_scale:1.0 },
    { name:"Queen with baby", spr:queenBaby,     scale:0.28, spr_preview:queen_baby_mini,  preview_scale:1.0 },
    { name:"Poor Princess",   spr:princess,      scale:0.28, spr_preview:princess_poor_mini, preview_scale:1.0 },
    { name:"Queen",           spr:queen,         scale:0.28, spr_preview:queen_mini},
	{ name:"Soldier",           spr:soldier,     scale:0.28, spr_preview:soldier}
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

scene_names = ["Scene 1","Scene 2","Scene 3","Scene 4","Scene 5","Scene 6"];

// Solo 3 tarjetas visibles: recalcular rect del carrusel
var visible_cards = 3;
var carrusel_w  = (visible_cards * scene_thumb_w) + ((visible_cards + 1) * scene_gap);
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

// Colocados por escena
placed_by_scene = array_create(scene_count);
for (var i = 0; i < scene_count; i++) placed_by_scene[i] = [];

// Reglas por escena
scene_rules = [
    ["King", "Poor Princess", "Father"],               // 1
    ["Rumpelstinkin", "Poor Princess"],                // 2
    ["Rumpelstinkin",  "Queen with baby"],     // 3
    ["Rumpelstinkin", "Queen with baby"],     // 4
    ["Rumpelstinkin","Soldier"],                                          // 5
    ["Queen with baby", "Rumpelstinkin"]      // 6
];

// Palabras clave (ahorcado por escena)
scene_keywords = ["DECEIVE","DESPAIR","DEAL","RECLAIM","EAVESDROP","VICTORY"];

// Máscaras y segmentos por escena
keyword_masks    = array_create(scene_count);
keyword_segments = array_create(scene_count);
for (var s = 0; s < scene_count; s++) {
    keyword_masks[s]    = ui_make_mask_from_phrase(scene_keywords[s]);
    var parts           = array_length(scene_rules[s]); // N assets requeridos en esa escena
    keyword_segments[s] = ui_make_segments_for_phrase(scene_keywords[s], parts);
}

/// Fondos por escena 
scene_bg = array_create(scene_count, noone);

scene_bg[0] = kingdomRoom;   // Scene 1
scene_bg[1] = spr_bg_straw; // Scene 2
scene_bg[2] = spr_bg_straw; 
scene_bg[3] = spr_bg_straw;
scene_bg[4] = house;
scene_bg[5] = spr_bg_straw;

// Estado de completitud
scene_complete = array_create(scene_count);
for (var j = 0; j < scene_count; j++) scene_complete[j] = false;

// Bloqueo de avance
lock_progression = false;

// Mover/eliminar colocados
moving_item_index = -1;
moving_offset_x   = 0;
moving_offset_y   = 0;

auto_advance_on_complete = true; //  auto-advance

// sprites mini para el carrusel (mostrar solo si la escena está completa)
scene_bg_thumb = array_create(scene_count, noone);
scene_bg_thumb[0] = spr_scene01_mini; // Scene01_Mini
scene_bg_thumb[1] = spr_scene02_mini; // Scene02_Mini
scene_bg_thumb[2] = spr_scene03_mini; // ...
scene_bg_thumb[3] = spr_scene04_mini;
scene_bg_thumb[4] = spr_scene05_mini;
scene_bg_thumb[5] = spr_scene04_mini;
