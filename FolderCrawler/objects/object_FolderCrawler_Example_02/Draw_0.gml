// Inherit the parent event
event_inherited();


// Don't draw any items, if structure doesn't exist yet.
if (self.structure == undefined)
{
  exit;
}


// Print information about current folder.
self.printer.Print($"\n")
  .Print($"Root folder : {self.structure.path}")
  .Print($" -> Folder count : {struct_names_count(self.structure.folders)}")
  .Print($" -> File count   : {struct_names_count(self.structure.files)}")
  .Print($"\n");