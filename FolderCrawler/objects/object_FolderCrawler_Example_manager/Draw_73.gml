/// @desc DRAW GENERAL INFO.

self.timer += 2;

// Right corner.
var _x = room_width - 128;
var _y = room_height - 128;
var _dir = self.timer;


// Draw information.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_text(32, 32, "Press [NUMBER] to change example.");


// Draw FPS real.
var _fps = string_format(fps_real, 16, 1);
draw_set_font(font_FolderCrawler);
draw_set_halign(fa_right);
draw_set_valign(fa_middle);
draw_text(_x + 32, _y, _fps);


// Draw something moving to indicate not halted.
_x += lengthdir_x(64, _dir);
_y += lengthdir_y(64, _dir);
draw_circle(_x, _y, 8, false);

