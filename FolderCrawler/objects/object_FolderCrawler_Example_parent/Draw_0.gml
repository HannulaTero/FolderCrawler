/// @desc DRAW 


if (self.handle != undefined)
{
  self.timeTaken  = self.handle.DebugTime();
  self.foundCount = self.handle.DebugCount();
  self.status     = self.handle.GetStatusName();
}


self.printer
  .SetPos(32, 128)
  .Print(self.label)
  .Print($"---")
  .Print($"Press [ENTER] to give a path to crawl.")
  .Print($"---")
  .Print($"Time taken  : {(self.timeTaken / 1000)} ms")
  .Print($"Crawl count : {self.foundCount}")
  .Print($"Status      : {self.status}")
  .Print($"---");

