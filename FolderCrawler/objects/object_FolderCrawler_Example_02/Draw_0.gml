/// @desc DRAW.


// Draw initial information
self.printer
  .SetPos(32, 128)
  .Print($"Example [2] Give a path as a string.")
  .Print($"---")
  .Print($"Press [ENTER] to give a path and crawl.")
  .Print($"---")


// Don't draw any items, if handle doesn't exist yet.
if (self.handle == undefined)
{
  exit;
}


// Print information about current folder.
self.printer.Print($"\n")
  .Print($"Root folder : {self.handle.GetRoot().path}")
  .Print($" -> Folder count : {self.handle.DebugCountFolders()}")
  .Print($" -> File count   : {self.handle.DebugCountFiles()}")
  .Print($" -> Time taken   : {self.handle.DebugTime() / 1000} ms")
  .Print($"\n");