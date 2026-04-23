/// @desc DRAW 


// Draw the information.
event_inherited();



// Draw the found items.
array_foreach(self.items, function(_file, _index)
{
  self.printer.Print(_file.name);
}, 0, 32);