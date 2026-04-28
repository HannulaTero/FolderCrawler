/// @desc REQUEST PATH.


// Ask for the path-string, async.
FolderCrawler_GetString(
  "Give a directory", 
  working_directory,
  function(_status, _result)
  {
    // Check get-string success.
    if (_status != "success")
    {
      show_debug_message("Get string failed.");
      return;
    }
    
    
    // Preparations.
    self.timeBegin = get_timer();
    self.status = "waiting...";
    
    
    // Dispatch the crawl.
    folder_crawl(_result, {
      callback : function(_crawler, _context)
      {
        self.timeTaken  = (get_timer() - self.timeBegin);
        self.foundCount = _crawler.DebugCount();
        self.status     = _crawler.GetStatusName();
        self.structure  = _crawler.GetRoot();
        self.json       = json_stringify(self.structure, true);
      }
    });
  }
);