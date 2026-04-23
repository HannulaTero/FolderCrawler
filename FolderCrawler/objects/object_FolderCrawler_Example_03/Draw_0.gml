/// @desc DRAW 


// Draw the information.
event_inherited();



// Don't draw any items, if structure doesn't exist yet.
if (self.current == undefined)
{
  exit;
}


// Print information about current folder.
self.printer.Print($"\n")
  .Print($"Current folder : {self.current.path}")
  .Print($" -> Folder count : {array_length(self.current.folders)}")
  .Print($" -> File count   : {array_length(self.current.files)}")
  .Print($"\n");


// Draw the folders.
// -> Only draw some of the folders, not all.
var _index = array_last(self.index);
var _items = self.current.folders;
var _count = array_length(_items);
var _lower = max(0, _index - 4);
var _upper = min(_count, _lower + 16);


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
    : ""
  
  // Tell whether file or folder.
  var _text = (_item.type == "folder")
    ? $"{_cursor} / {_item.name}"
    : $"{_cursor} - {_item.name}";
  
  self.printer.Print(_text);
}


// Indicate there are more down, non-visible.
if (_upper != _count)
{
  self.printer.Print("...");
}



