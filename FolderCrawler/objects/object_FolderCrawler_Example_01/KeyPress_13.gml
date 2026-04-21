/// @desc SEARCH WORKING DIRECTORY.


// Get the starting time..
self.timeBegin = get_timer();
self.status = "waiting...";


// Do the dispatch.
folder_crawl({
  path : working_directory, 
  callback : function(_crawler)
  {
    self.timeTaken  = (get_timer() - self.timeBegin);
    self.foundCount = _crawler.DebugCount();
    self.status     = _crawler.GetStatus();
    self.structure  = _crawler.GetRoot();
    self.json       = json_stringify(self.structure, true);
  }
});