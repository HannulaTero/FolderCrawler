/// @desc DRAW 


// Draw something indicate game has not frozen.
var _x = 128
var _y = 128;
var _i = 0;
var _h = 16;

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_text(_x, _y + _h * _i++, $"EXAMPLE 01.");
draw_text(_x, _y + _h * _i++, $"---");
draw_text(_x, _y + _h * _i++, $"Press [ENTER] to crawl working_directory.");
draw_text(_x, _y + _h * _i++, $"---");
draw_text(_x, _y + _h * _i++, $"Time taken  : {(self.timeTaken / 1000)} ms");
draw_text(_x, _y + _h * _i++, $"Found count : {self.foundCount}");

