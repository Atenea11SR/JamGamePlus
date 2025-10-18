// Resolución de referencia 
global.SW = 1920;
global.SH = 1080;

// Rectángulos (x1,y1,x2,y2) — ajusta medidas si querés
rect_scene  = {x1:64,  y1:110, x2:960,  y2:500}; // panel grande (escena)
rect_assets = {x1:980, y1:110, x2:1300, y2:700}; // paleta derecha
rect_scenes = {x1:64,  y1:520, x2:960,  y2:700}; // carrusel inferior

title_text = "RUMPELSTINKIN";

// Colores
col_bg     = make_color_rgb(112,121,104); // verde/gris del wireframe
col_panel  = make_color_rgb(60,55,55);    // paneles oscuros
col_title  = c_black;

//Variables para assets
// Panel de Assets 
asset_scroll = 0;         
asset_cell_h = 96;        
asset_cell_margin = 8;    
asset_scroll_step = 24;    
asset_dragging = false;
asset_drag_start_y = 0;
asset_drag_start_scroll = 0;

// Lista temporal de assets (placeholders)
assets = [
    { name:"Molino", spr:noone },
    { name:"Duende",  spr:Rumpel, preview:1.0,  scale: 0.25 },
    { name:"Bebe",  spr:noone },
    { name:"Reina", spr:noone },
    { name:"Guardia", spr:noone },
    { name:"Objeto", spr:noone },
    { name:"Objeto", spr:noone },
    { name:"Objeto", spr:noone },
    { name:"Objeto", spr:noone },
    { name:"Objeto", spr:noone },
];

//  Carrusel de escenas 
scene_count    = 6;        
current_scene  = 0;        
scenes_scroll  = 0;        
scene_thumb_w  = 220;     
scene_thumb_h  = 140;      
scene_gap      = 16;       
scenes_scroll_step = 48;  
drag_scrolling_scenes = false;
drag_start_x = 0;
drag_start_scroll = 0;

//  nombres 
scene_names = ["Escena 1","Escena 2","Escena 3","Escena 4","Escena 5","Escena 6"];


//  SOLO 3 TARJETAS VISIBLES
var visible_cards = 3;
var carrusel_w = (visible_cards * scene_thumb_w) + ((visible_cards + 1) * scene_gap);


var carrusel_x1 = rect_scene.x1;                 
var carrusel_y1 = rect_scene.y2 + 20;           
var carrusel_x2 = carrusel_x1 + carrusel_w;     
var carrusel_y2 = carrusel_y1 + scene_thumb_h + (2 * scene_gap); 

rect_scenes = { x1:carrusel_x1, y1:carrusel_y1, x2:carrusel_x2, y2:carrusel_y2 };


