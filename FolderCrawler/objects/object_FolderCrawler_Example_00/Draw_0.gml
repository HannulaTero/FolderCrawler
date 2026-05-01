/// @desc DRAW.

event_inherited();


// Skip if no handle exists.
if (self.handle == undefined)
{
  exit;
}


// Get root and print out the JSON.
// -> Root always exists, but the subfolders might not yet.
var _root = self.handle.GetRoot();
var _json = json_stringify(_root, true);
self.printer.Print($"JSON : {_json}");