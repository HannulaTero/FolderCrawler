/// @desc REQUEST PATH & DISPATCH CRAWLER.


// Ask for the path-string, async.
FolderCrawler_GetString("Give a directory", working_directory, function(_status, _result)
{
  // Check get-string success.
  if (_status != "success")
  {
    show_debug_message("Get string failed.");
    return;
  }
  
  
  // Dispatch the crawl into given path.
  self.handle = folder_crawl(_result, {
    unsafe : true,
    callback : function(_crawler, _context)
    {
      self.current = _crawler.GetRoot();
      self.names = array_concat(
        struct_get_names(self.current.folders), 
        struct_get_names(self.current.files)
      );
    }
  });
});