

/**
* Crawls through folders and files, quits whenever time budget is spent.
* Should not be called by the user. The timesource should handle this.
* This does use file_find_* in one go to avoid issues, which may introduce stutters with large folders.
* 
* @context FolderCrawler
* @returns {Undefined}
*/ 
function __FolderCrawler__Crawl()
{
  // Get the time budget.
  var _speed = game_get_speed(gamespeed_microseconds);
  var _budget = self.budget * _speed;
  var _timeTarget = (get_timer() + _budget);
  
  
  // Iterate until frame-budget has been exhausted.
  while(get_timer() < _timeTarget)
  {
    // Iterate through items in current folder.
    // -> These are names which have already been collected with file-find.
    // -> So these are not dealing with global state anymore, 
    //    and therefore can quit when frame budget is exceeded.
    while(array_length(self.pendingNames) > 0)
    {
      // To not exceed the frame budget.
      // -> Do early quit.
      if (get_timer() >= _timeTarget)
      {
        return;
      }
        
        
      // Get the next item path.
      var _name = array_pop(self.pendingNames);
      var _path = (self.folderCurrent.path + "\\" + _name);
      var _item = undefined;
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
  
  
    // Iterate through the current path items.
    // -> Done in single step because file-finding has global state.
    // -> After all names have been found, loop will return back.
    var _name = file_find_first(
      (self.folderCurrent.path + self.defaultMask), 
      (self.attributes)
    );
    while(_name != "")
    {
      array_push(self.pendingNames, _name);
      _name = file_find_next();
    }
    file_find_close();
  }
  
  
  // Call action that next folder is being opened.
  self.ActionOpen(self.folderCurrent, self.userContext);
}