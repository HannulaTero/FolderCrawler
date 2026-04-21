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
    
    
    // Preparations before dispatch.
    self.timeBegin  = get_timer();
    self.status     = $"waiting...";
    array_resize(self.items, 0);
    
    
    // Dispatch the crawl.
    folder_crawl({
      path : _result, 
      callback : function(_status, _result, _crawler)
      {
        self.timeTaken  = (get_timer() - self.timeBegin);
        self.foundCount = _crawler.itemCount;
        self.structure  = _result;
        self.status     = $"finished! {_status}";
      }, 
      unsafe : true,
      file : function(_item)
      {
        // Whether folder or file.
        if (_item.type != "file")
        {
          return;
        }
        
        // Check for the extension.
        var _ext = filename_ext(_item.name);
        if (_ext != ".png")
        {
          return;
        }
        
        // Push into items.
        array_push(self.items, _item);
      }
    });
  }
);