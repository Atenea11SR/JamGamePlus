draw_set_font(Font1);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// Coordenadas de los botones
var jugar_x = 500; var jugar_y = 200;
var creditos_x = 500; var creditos_y = 350;
var salir_x = 500; var salir_y = 500;

// Dibujar botón JUGAR
draw_sprite_ext(playButton, 0, jugar_x, jugar_y, (selected_button==0)?1.1:1, (selected_button==0)?1.1:1, 0, c_white, 1);

// Dibujar botón CRÉDITOS
draw_sprite_ext(creditsButton, 0, creditos_x, creditos_y, (selected_button==1)?1.1:1, (selected_button==1)?1.1:1, 0, c_white, 1);

// Dibujar botón SALIR
draw_sprite_ext(finishButton, 0, salir_x, salir_y, (selected_button==2)?1.1:1, (selected_button==2)?1.1:1, 0, c_white, 1);
