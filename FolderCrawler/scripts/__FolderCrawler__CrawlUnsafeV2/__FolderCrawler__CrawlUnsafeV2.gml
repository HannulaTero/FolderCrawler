

/**
* Crawls through folders and files, quits whenever time budget is spent.
* Should not be called by the user. The timesource should handle this.
* 
* This is "unsafe" version, as it will assume being only one using file_find_* functions.
* -> This allows splitting use of these functions, and avoid stutters with large folders.
* 
* "directory_exists" -function is SLOW
* -> This implementation tries to avoid using it by iterating twice.
* -> file_find_next is also slow, but iterating twice is still faster.
* 
* In GM you can't iterate through only folders.
* So this is done in two passes:
* -> First, find only target files. (add to map)
* -> Second, find these files + folders. (check whether on map)
* 
* @context FolderCrawler
*/ 
function __FolderCrawler__CrawlUnsafeV2()
{
  // Get the time budget.
  var _speed = game_get_speed(gamespeed_microseconds);
  var _budget = self.budget * _speed;
  var _timeTarget = (get_timer() + _budget);
  
  
  // Iterate until frame-budget has been exhausted.
  while(get_timer() < _timeTarget)
  {
    // Add items until finished or time is up.
    while(self.nextName != "")
    {
      if (get_timer() >= _timeTarget) return;
      self.AddItem(self.nextName);
      self.nextName = file_find_next();
    }
    
    
    // No more items.
    file_find_close();
    
    
    // Check whether was iterating through files.
    // -> If yes, then swap to iterating through the folders.
    // -> Previously iterated through only the files.
    // -> Now iterating through both (in GM can't iterate only folders).
    if (self.AddItem == __FolderCrawler__Crawl_File)
    {
      self.AddItem = __FolderCrawler__Crawl_Folder;
      self.nextName = file_find_first(
        (self.folderCurrent.path + self.defaultMask), 
        (self.attributes | fa_directory)
      );
      continue;
    }
    
    
    // Pop next iteration target.
    // -> This will be next name-iterations target.
    self.folderCurrent = array_pop(self.folderStack);
    
    
    // Check if no more items left -> end the loop.
    if (self.folderCurrent == undefined)
    {
      self.Finish();
      return;
    }
    
    
    // Call action that next folder is being opened.
    self.ActionOpen(self.folderCurrent, self.userContext);
    
    
    // Start iterating through the files.
    // -> This excludes the folders.
    ds_map_clear(self.currFiles);
    self.AddItem = __FolderCrawler__Crawl_File;
    self.nextName = file_find_first(
      (self.folderCurrent.path + self.mask), 
      (self.attributes & (~fa_directory))
    );
  }
}