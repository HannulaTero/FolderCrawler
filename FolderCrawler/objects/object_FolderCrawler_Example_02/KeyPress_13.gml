/// @desc REQUEST PATH.

object_FolderCrawler_Example_manager.GetString(
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
    self.timeBegin = get_timer();
    self.status = "waiting...";
    
    folder_crawl(_result, function(_status, _result, _crawler)
    {
      self.timeTaken  = (get_timer() - self.timeBegin);
      self.foundCount = _crawler.itemCount;
      self.structure  = _result;
      self.status     = $"finished! {_status}";
    });
  }
);