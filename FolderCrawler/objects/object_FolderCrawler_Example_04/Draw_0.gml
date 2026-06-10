/// @desc DRAW 


// Preparations.
var _timeTaken = (self.handle != undefined)
  ? self.handle.DebugTime() 
  : 0;


// Draw initial information
self.printer
  .SetPos(32, 128)
  .Print($"Example [4] utilizes parameters, finds all png's")
  .Print($"---")
  .Print($"Press [ENTER] to give a path and crawl.")
  .Print($"---")



// Print information about current folder.
self.printer.SetPos(768, 64);
self.printer.Print($"\n")
  .Print($" -> Time taken   : {_timeTaken / 1000} ms")
  .Print($"\n")
  .Print($"PNG-FILES =========");


// Draw the found images.
array_foreach(self.images, function(_file, _index)
{
  self.printer.Print(_file.name);
}, 0, 32);