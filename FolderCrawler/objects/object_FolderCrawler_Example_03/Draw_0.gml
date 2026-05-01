/// @desc DRAW 


// Draw the information.
event_inherited();



// Don't draw any items, if structure doesn't exist yet.
if (self.current == undefined)
{
  exit;
}


// Print information about current folder.
self.printer.SetPos(768, 64);
self.printer.Print($"\n")
  .Print($"Current folder : {self.current.path}")
  .Print($" -> Folder count : {array_length(self.current.folders)}")
  .Print($" -> File count   : {array_length(self.current.files)}")
  .Print($"\n")
  .Print($"FOLDERS =========");


// Draw the folders.
// -> Only draw some of the folders, not all.
var _index = array_last(self.index);
var _items = self.current.folders;
var _count = array_length(_items);
var _lower = max(0, _index - 4);
var _upper = min(_count, _lower + 8);


// Indicate there are more up, non-visible.
if (_lower != 0)
{
  self.printer.Print("...");
}


// Draw current items.
for(var i = _lower; i < _upper; i++)
{
  var _item = _items[i];
  
  // Whether has a cursor.
  var _cursor = (_item == _items[_index])
    ? ">> " 
    : "   "
  
  self.printer.Print($"{_cursor} / {_item.name}");
}


// Indicate there are more down, non-visible.
if (_upper != _count)
{
  self.printer.Print("...");
}



// Draw the files.
self.printer.SetPos(768, 460);
self.printer.Print("FILES =========");
_items = self.current.files;
_count = array_length(_items);
_upper = min(8, _count);
for(var i = 0; i < _upper; i++)
{
  self.printer.Print($" - {_items[i].name}");
}

if (_count != _upper)
{
  self.printer.Print("...");
}
