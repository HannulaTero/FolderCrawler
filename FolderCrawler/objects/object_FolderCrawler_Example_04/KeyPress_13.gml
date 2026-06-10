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
  
  
  // Dispatch the crawl.
  self.handle = folder_crawl(_result, {
    unsafe : true,
    context : self.images,
    
    // This is called for each found item.
    file : function(_file, _context)
    {
      var _ext = filename_ext(_file.name);
      if (_ext == ".png")
      {
        array_push(_context, _file);
      }
    }
  });
});