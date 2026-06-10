/// @desc DRAW.


// Preparations.
var _timeTaken  = 0;
var _foundCount = 0;
var _status     = "...";


// Get information.
if (self.handle != undefined)
{
  _timeTaken  = self.handle.DebugTime();
  _foundCount = self.handle.DebugCount();
  _status     = self.handle.GetStatusName();
}


// Print the information.
self.printer
  .SetPos(32, 128)
  .Print($"Example [0] Crawl the 'working_directory'")
  .Print($"---")
  .Print($"Press [ENTER] to crawl.")
  .Print($"---")
  .Print($"Status         : {_status}")
  .Print($"Time taken     : {(_timeTaken / 1000)} ms")
  .Print($"Found files    : {_foundCount}")
  .Print($"Found folders  : {_foundCount}")
  .Print($"---");


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