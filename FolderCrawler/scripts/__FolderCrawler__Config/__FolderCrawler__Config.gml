

/**
* Applies given parameters to the crawler.
* 
* @context FolderCrawler
*/ 
function __FolderCrawler__Config(_descriptor=FolderCrawler_Descriptor())
{  
  // 
  var _params = FolderCrawler_Descriptor();
  with _params struct_foreach(_descriptor, function(_key, _item)
  {
    self[$ _key] = _item;
  });
  
  
  // Push the starting path to boot up the iteration loop.
  var _name = __FolderCrawler_GetName(_params.path);
  var _root = new FolderCrawler_Folder(undefined, _name, _params.path);
  array_push(self.folderStack, _root);
  self.folderRoot = _root;
  
  
  // Context for the actions.
  self.userContext = _params.context;
  
  
  // Relative time budget, it is depend of how long frame is.
  self.budget = _params.budget;
  
  
  // Define mask.
  self.mask = ("\\" + _params.mask);
  
  
  // Define attributes.
  self.attributes = _params.attributes;
  
  
  // Define the actions.
  self.ActionInit   = __FolderCrawler_Rescope(other, _descriptor, _params.init);
  self.ActionOpen   = __FolderCrawler_Rescope(other, _descriptor, _params.open);
  self.ActionFile   = __FolderCrawler_Rescope(other, _descriptor, _params.file);
  self.ActionFolder = __FolderCrawler_Rescope(other, _descriptor, _params.folder);
  self.Callback     = __FolderCrawler_Rescope(other, _descriptor, _params.callback);
  
  
  // Select the crawling method and create iterator.
  // -> Timesource does the iteration loop.
  var _Crawl = (_params.unsafe == true)
    ? __FolderCrawler__CrawlUnsafe
    : __FolderCrawler__Crawl;
    
  self.timeSource = time_source_create(
    time_source_global, 1, time_source_units_frames,
    method(self, _Crawl), [ ], -1
  );
  time_source_start(self.timeSource);
  
  
  // Whether start in paused state.
  if (_params.paused == true)
  {
    time_source_pause(self.timeSource);
  }
  
  
  // Do the initialization call.
  self.ActionInit(self.folderCurrent, self.userContext);
}


