// Navegar arriba
if (keyboard_check_pressed(vk_up)) {
    selected_button -= 1;
    if (selected_button < 0) selected_button = 2; // va al último botón
}

// Navegar abajo
if (keyboard_check_pressed(vk_down)) {
    selected_button += 1;
    if (selected_button > 2) selected_button = 0; // vuelve al primero
}

// Acción con Enter
if (keyboard_check_pressed(vk_enter)) {
    if (selected_button == 0) {
        global.final_obtenido = ""; // reiniciar antes de jugar
        room_goto(Level1);
        global.room = Level1;
        instance_destroy();
    } else if (selected_button == 1) {
        room_goto(CreditsRoom);
        instance_destroy();
    } else if (selected_button == 2) {
        game_end();
    }
}
