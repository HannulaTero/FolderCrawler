/// @desc DRAW 


// Draw something indicate game has not frozen.
var _x = 128
var _y = 128;
var _i = 0;
var _h = 16;

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_text(_x, _y + _h * _i++, $"EXAMPLE 03.");
draw_text(_x, _y + _h * _i++, $"---");
draw_text(_x, _y + _h * _i++, $"Press [ENTER] to give a path to crawl.");
draw_text(_x, _y + _h * _i++, $"Press [ARROWS] to walk found structure.");
draw_text(_x, _y + _h * _i++, $"---");
draw_text(_x, _y + _h * _i++, $"Time taken  : {(self.timeTaken / 1000)} ms");
draw_text(_x, _y + _h * _i++, $"Found count : {self.foundCount}");
draw_text(_x, _y + _h * _i++, $"Status      : {self.status}");
draw_text(_x, _y + _h * _i++, $"---");


// Don't try any items, if structure doesn't exist yet.
if (self.current == undefined)
{
  exit;
}

_i += 2;
draw_text(_x, _y + _h * _i++, $"Current : {self.current.path}");
_i += 2;
_x += 32;


// Draw the items.
// Bit of hacky way for now.
var _index = array_last(self.index);
var _items = self.items;
var _count = array_length(_items);
var _lower = max(0, _index - 4);
var _upper = min(_count, _lower + 16);


// Indicate there are more up, non-visible.
if (_lower != 0)
{
  draw_text(_x, _y + _h * _i++, "...");
}


// Draw current items.
for(var i = _lower; i < _upper; i++)
{
  var _item = _items[i];
  
  // Draw cursor.
  if (_item == _items[_index])
  {
    draw_text(_x - 32, _y + _h * _i, ">>");
  }
  
  // Tell whether file or folder.
  var _text = (_item.type == "folder")
    ? $"/ {_item.name}"
    : $"- {_item.name}";
  draw_text(_x, _y + _h * _i++, _text);
}


// Indicate there are more down, non-visible.
if (_upper != _count)
{
  draw_text(_x, _y + _h * _i++, "...");
}



