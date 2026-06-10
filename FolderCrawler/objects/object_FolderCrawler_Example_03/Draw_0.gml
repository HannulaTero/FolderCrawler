/// @desc DRAW 


// Preparations.
var _timeTaken = (self.handle != undefined)
  ? self.handle.DebugTime() 
  : 0;


// Draw initial information
self.printer
  .SetPos(32, 128)
  .Print($"Example [3] same as before, but allows moving through folders")
  .Print($"---")
  .Print($"Press [ENTER] to give a path and crawl.")
  .Print($"---")



// Print information about current folder.
self.printer.SetPos(768, 64);
self.printer.Print($"\n")
  .Print($"Current folder : {self.current.path}")
  .Print($" -> Folder count : {struct_names_count(self.current.folders)}")
  .Print($" -> File count   : {struct_names_count(self.current.files)}")
  .Print($" -> Time taken   : {_timeTaken / 1000} ms")
  .Print($"\n")
  .Print($"ITEMS =========");


// Draw the items.
// -> Only draw some of them, not all.
var _index = array_last(self.index);
var _count = array_length(self.names);
var _lower = max(0, _index - 4);
var _upper = min(_count, _lower + 8);


// Indicate there are more upward, non-visible.
if (_lower != 0)
{
  self.printer.Print("...");
}


// Draw current items.
for(var i = _lower; i < _upper; i++)
{
  // Get the name and item.
  var _name = self.names[i];
  var _item = (
    self.current.folders[$ _name] ?? 
    self.current.files[$ _name]
  );
  
  // Whether has a cursor.
  var _cursor = (_name == self.names[_index])
    ? ">> " 
    : "   "
  
  // Whether is folder or not.
  var _type = (_item.type == "folder")
    ? " / " 
    : " - "
  
  // Print the item.
  self.printer.Print($"{_cursor}{_type}{_name}");
}


// Indicate there are more downward, non-visible.
if (_upper != _count)
{
  self.printer.Print("...");
}

