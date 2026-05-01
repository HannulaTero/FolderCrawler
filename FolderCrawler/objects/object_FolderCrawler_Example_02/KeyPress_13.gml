/// @desc REQUEST PATH & DISPATCH CRAWLER.


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
    
    
    // Dispatch the crawl.
    self.handle = folder_crawl(_result, {
      callback : function(_crawler, _context)
      {
        // Could do other stuff too.
        self.structure = _crawler.GetRoot();
      }
    });
  }
);