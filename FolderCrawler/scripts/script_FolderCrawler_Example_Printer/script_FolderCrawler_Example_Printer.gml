


/**
* Just utility for drawing text.
*/
function FolderCrawler_Printer() constructor
{
  self.font = font_FolderCrawler;
  self.x = 0;
  self.y = 0;
  
  
  static SetPos = function(_x, _y)
  {
    self.x = _x;
    self.y = _y;
    return self;
  };
  
  
  static Print = function(_message)
  {
    draw_set_font(self.font);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_text(self.x, self.y, _message);
    self.y += 1.25 * string_height(_message);
    return self;
  };
}