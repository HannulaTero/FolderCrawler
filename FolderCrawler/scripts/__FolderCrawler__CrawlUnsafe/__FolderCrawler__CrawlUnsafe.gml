

/**
* Crawls through folders and files, quits whenever time budget is spent.
* Should not be called by the user. The timesource should handle this.
* 
* This is "unsafe" version, as it will assume being only one using file_find_* functions.
* -> This allows splitting use of these functions, and avoid stutters with large folders.
* 
* @context FolderCrawler
*/ 
function __FolderCrawler__CrawlUnsafe()
{
  // Get the time budget.
  var _speed = game_get_speed(gamespeed_microseconds);
  var _budget = self.budget * _speed;
  var _timeTarget = (get_timer() + _budget);
  
  
  // Iterate until frame-budget has been exhausted.
  while(get_timer() < _timeTarget)
  {
    // Iterate through through all names within folder.
    // -> This uses global state of file_find_* functions.
    // -> Assumes none else tampers with it while doing iterations.
    while(self.nextName != "")
    {
      // To not exceed the frame budget -> Do early quit.
      if (get_timer() >= _timeTarget)
      {
        return;
      }
      
      
      // Get the next item path.
      var _name = (self.nextName);
      var _path = (self.folderCurrent.path + "\\" + _name);
      self.itemCount += 1;
      
        
      // Create structure for the found item.
      if (directory_exists(_path) == true)
      {
        var _folder = new FolderCrawler_Folder(self.folderCurrent, _name, _path);
        array_push(self.folderStack, _folder);
        self.ActionFolder(_folder, self.userContext);
      }
      else
      {
        var _file = new FolderCrawler_File(self.folderCurrent, _name, _path);
        self.ActionFile(_file, self.userContext);
      }
      
        
      // Move to the next.
      self.nextName = file_find_next();
    }
    
    
    // Pop next iteration target.
    // -> This will be next name-iterations target.
    self.folderCurrent = array_pop(self.folderStack);
    file_find_close();
    
    
    // Check if no more items left -> end the loop.
    if (self.folderCurrent == undefined)
    {
      self.Finish();
      return;
    }
    
    
    // Preparate for the next iteration.
    self.nextName = file_find_first(
      (self.folderCurrent.path + self.defaultMask), 
      (self.attributes)
    );
    
    
    // Call action that next folder is being opened.
    self.ActionOpen(self.folderCurrent, self.userContext);
  }
}