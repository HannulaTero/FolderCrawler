/// @desc DRAW 


self.printer
  .SetPos(128, 128)
  .Print(self.label)
  .Print($"---")
  .Print($"Press [ENTER] to give a path to crawl.")
  .Print($"---")
  .Print($"Time taken  : {(self.timeTaken / 1000)} ms")
  .Print($"Found count : {self.foundCount}")
  .Print($"Status      : {self.status}")
  .Print($"---");

