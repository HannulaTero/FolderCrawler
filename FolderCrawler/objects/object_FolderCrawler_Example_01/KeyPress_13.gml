/// @desc SEARCH WORKING DIRECTORY.


// Do the dispatch.
self.handle = folder_crawl(working_directory, {
  callback : function(_crawler)
  {
    self.structure  = _crawler.GetRoot();
    self.json       = json_stringify(self.structure, true);
  }
});