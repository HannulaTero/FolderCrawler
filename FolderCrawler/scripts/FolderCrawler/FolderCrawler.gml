//=============================================================
// 
#region INFORMATION.
/*
  
  This asset can be used to crawl out larger folder/file-structures 
  without making the game to freeze up by splitting crawling into several frames.
  Crawling will result nested stucture containing structs, which represent files and folders.
  
  
  Use "folder_crawl(path, Callback, params)" to dispatch crawler.
  This will queue up the requests, so if you dispatch many different crawlers,
  then only single of them is active at given time. 
  This is done to avoid concurrent uses of file_find_* (which is important with "unsafe" crawl)
  but also makes frame-budgeting simpler.
  
  
  The resulting structure is build from following structs :
  
    file : { 
      type : String   ---   "file".
      root : Struct   ---   A folder-struct.
      name : String   ---   Name of the file.
      path : String   ---   Absolute path for the file, includes name.
    }
    
    folder : {        
      type    : String  ---   "folder".
      root    : Struct  ---   Either undefined or another folder-struct.
      name    : String  ---   Name of the folder.
      path    : String  ---   Absolute path for the folder, includes name.
      files   : Array   ---   Contains file-structs, which belong to the folder.
      folders : Array   ---   Contains folder-structs, which belong to the folder.
    }
  
  
  Note that sandboxing can affect where can be crawled, 
  so check the project sandbox settings.
  
  As file_find_* has global state, asset avoids spreading its use 
  over several frame, therefore it collects all names within 
  folder at once, and then creates structure and pushes next 
  folders for dispatching. This does mean there is possiblity that
  folder just contains so many files/folders, that game still 
  freezes. This could be avoided, if also use of file_find_* is 
  spread over several frames, which this asset doesn't do.
  
  
*/
#endregion
// 
//=============================================================
// 
#region LICENSE.
/*

  MIT License

  Copyright (c) 2026 Tero Hannula

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.

*/
#endregion
// 
//=============================================================
// 
#region FOLDER CRAWL -FUNCTION.



/**
* Crawls through files and folders within given path.
* 
* Dispatches crawlers one at the time, so there won't be many crawlers
* simultanously active. Rest are kept in pending-queue, waiting for their turn.
* 
* This is asynchronous / non-blocking, so crawling can be split into several frames.
* -> Crawler has time-budget how much it can try iterate.
* -> By default budget is high: 0.90 -> 90% of the frame time.
* 
* Note, because of file_find_* has global state, 
* by default crawler will find all possible names within folder at once without stopping.
* -> This is done to avoid problems, if file_find_* function are used elsewhere.
* -> If single folder has lot of files/folders, this can cause stutter.
* You may toggle "unsafe : true" to avoid this.
* -> It will assume nothing elsewhere touches file_find_* while crawling.
* 
* Optional parameters are:
* - budget      : Real                    --- Relative part of the frame, such as 0.5
* - attributes  : Constant.FileAttribute  --- What file-types are being searched.
* - paused      : Bool                    --- Whether crawler starts in paused state.
* - unsafe      : Bool                    --- Whether crawler can split file_find_* function uses to multiple frames.
* - action      : Function                --- What action does while crawling.
* 
* @param {String}   _path       Root-path where crawling is started.
* @param {Function} _Callback   Signature: function(_success, _result)
* @param {Struct}   _params     Other parameters, such as frame-budget.
*/ 
function folder_crawl(_path, _Callback, _params={ })
{
  // Get the global context.
  var _context = __FolderCrawl_Context();
  
  
  // (Re)Activate the timesource.
  // -> This will ensure the dispatcher is active.
  switch(time_source_get_state(_context.timeSource))
  {
    case time_source_state_initial: time_source_start(_context.timeSource); break;
    case time_source_state_stopped: time_source_start(_context.timeSource); break;
    case time_source_state_paused:  time_source_resume(_context.timeSource); break;
  }
  
  
  // Create crawler with given settings.
  // -> If no other is active, then it will start immediately.
  var _crawler = new FolderCrawler(_path, _Callback, _params);
  if (_context.current == undefined)
  {
    _context.current = _crawler;
  }
  else
  {
    // Push crawler into pending, 
    // dispatcher deals activating them whenever ready.
    ds_queue_enqueue(_context.pending, _crawler);
    _crawler.Pause();
  }
  return _crawler;
}



#endregion
// 
//=============================================================
// 
#region CONSTRUCT : CRAWLER.



/**
* Structure which does the crawling.
* 
* @param {String}   _path
* @param {Function} _Callback
*/ 
function FolderCrawler(_path, _Callback, _params={ }) constructor
{
  //=============================================================
  // 
  #region PUBLIC METHODS.
  
  
  // Debug methods, related, checking what crawler is currently doing.
  static CurrentCount   = __FolderCrawler_CurrentCount;
  static CurrentFolder  = __FolderCrawler_CurrentFolder;
  static CurrentPath    = __FolderCrawler_CurrentPath;
  
  
  // Pausing and resuming related.
  static IsPaused = __FolderCrawler_IsPaused;
  static Pause    = __FolderCrawler_Pause;
  static Resume   = __FolderCrawler_Resume;
  
  
  // Finishing related.
  static IsFinished = __FolderCrawler_IsFinished;
  static Finish     = __FolderCrawler_Finish;
  
  
  
  #endregion
  // 
  //=============================================================
  // 
  #region PRIVATE STATIC VARIABLES.
  
  
  
  // Used in callback to tell what has happened.
  static status = {
    success : "success",
    stopped : "stopped",
    failure : "failure"
  };
  
  
  // What is default relative frame budget.
  // @ignore
  static defaultBudget = 0.90;
  
  
  // What is being searched.
  // @ignore
  static defaultAttributes = (fa_none | fa_directory);
  
  
  // What is default action while crawling.
  // @ignore
  static defaultAction = function(_file)
  {
    // Does nothing.
  };
  
  
  
  #endregion
  // 
  //=============================================================
  // 
  #region PRIVATE DECLARE VARIABLES.
  
  
  
  // What is root-path, where crawling is started.
  // @ignore
  self.path = _path;
  
  
  // Called when crawling finished / stops.
  // @ignore
  self.Callback = _Callback;
  
  
  // How much time can be used at one frame.
  // @ignore
  self.budget = 0;
  
  
  // What is being searched.
  // @ignore
  self.attributes = self.defaultAttributes;
  
  
  // What is the action done when crawling.
  // @ignore
  self.Action = self.defaultAction;
  
  
  // Select the crawling method and create iterator.
  // Timesource does the iteration loop.
  // @ignore
  self.timeSource = undefined;
  
  
  // The result of the crawl.
  // @ignore
  self.result = undefined; 
  
  
  // Whether crawler has finished / stopped.
  // @ignore
  self.finished = false;


  // Holds pending folders, which will be crawled.
  // @ignore
  self.stack = [ ];
  

  // The currently active folder, which is being iterated through.
  // @ignore
  self.folder = undefined;
  
  
  // File and folder names of the currently active folder.
  // -> Used for the "safe" iterations.
  // @ignore
  self.names = [ ];
  
  
  // Next item in iteraation.
  // -> Used for the "unsafe" iterations.
  // @ignore
  self.next = "";
  
  
  // How many items have been found.
  // @ignore
  self.itemCount = 0;
  
  
  // Define the variables.
  __FolderCrawler__Config(_params);
  
  
  
  #endregion
  // 
  //=============================================================
}




#endregion
// 
//=============================================================
// 
#region CONSTRUCT : FOLDER.



/**
* Creates struct, which holds folder path and name, and references to underlying folders and files.
* 
* @param {Struct.FolderCrawler_Folder | Undefined} _root
* @param {String} _name
* @param {String} _path
*/
function FolderCrawler_Folder(_root, _name, _path) constructor
{
  // The construct type.
  self.type = "folder";
  
  
  // The root folder.
  self.root = _root;
  
  
  // Folder name.
  self.name = _name;
  
  
  // Absolute path, including the name.
  self.path = _path;
  
  
  // Holds file-constructs.
  self.files = [ ];
  
  
  // Holds other folders-constructs.
  self.folders = [ ];
}



#endregion
// 
//=============================================================
// 
#region CONSTRUCT : FILE.



/**
* Creates struct, which holds file path and name.
* 
* @param {Struct.FolderCrawler_Folder | Undefined} _root 
* @param {String} _name
* @param {String} _path
*/
function FolderCrawler_File(_root, _name, _path) constructor
{
  // The construct type.
  self.type = "file";
  
  
  // The root folder.
  self.root = _root;
  
  
  // The file name, including the extension.
  self.name = _name;
  
  
  // Absolute path, including the name.
  self.path = _path;
}



#endregion
// 
//=============================================================
// 
#region INTERNAL : GLOBAL CONTEXT.



/**
* Returns the global context used internally.
*/ 
function __FolderCrawl_Context()
{
  static context = {
    // Currently active crawler.
    current : undefined,
    
    // The queue of awaiting crawlers.
    pending : ds_queue_create(),
    
    // The dispatcher loop, handles dequeueing next crawler.
    timeSource : time_source_create(
      time_source_global, 1, time_source_units_frames,
      __FolderCrawl_Dispatch, [ ], -1
    )
  };
  return context;
}



#endregion
// 
//=============================================================
// 
#region INTERNAL : DISPATCHER.



/**
* For dispatching crawlers in ordered manner.
*/ 
function __FolderCrawl_Dispatch()
{
  // Get the context, hwhich holds global states.
  var _context = __FolderCrawl_Context();
  
  
  // Check whether there is currently active crawler,
  // and whether it has already finished.
  if (_context.current != undefined)
  && (_context.current.IsFinished() == false)
  {
    return;
  }
  
  
  // Get next crawler.
  _context.current = ds_queue_dequeue(_context.pending);
  
  
  // If the is no active crawler, then there are no pending crawlers left.
  // -> Pause the timesource for dispatcher.
  if (_context.current == undefined)
  {
    time_source_pause(_context.timeSource);
    return;
  }
  
  
  // Otherwise activate the crawler.
  _context.current.Resume();
}



#endregion
// 
//=============================================================
// 
#region FOLDER CRAWLER : CONFIGURATING



/**
* Applies given parameters to the crawler.
* 
* @context FolderCrawler
*/ 
function __FolderCrawler__Config(_params={ })
{
  // Preparations.
  var _unsafe     = (_params[$ "unsafe"]      ?? false);
  var _paused     = (_params[$ "paused"]      ?? false);
  var _budget     = (_params[$ "budget"]      ?? self.defaultBudget);
  var _action     = (_params[$ "action"]      ?? self.defaultAction);
  var _attributes = (_params[$ "attributes"]  ?? self.defaultAttributes);
  
  
  // Resulting folder-structure.
  self.result = new FolderCrawler_Folder(undefined, "./", self.path); 


  // Holds pending folders, which will be crawled.
  array_push(self.stack, self.result);
  
  
  // Time budget is depend of how long frame is.
  self.budget = (_budget * game_get_speed(gamespeed_microseconds));
  
  
  // Define attributes.
  self.attributes = _attributes;
  
  
  // Define custom action.
  self.Action = _action;
  
  
  // Select the crawling method and create iterator.
  // -> Timesource does the iteration loop.
  var _Crawl = (_unsafe == true)
    ? __FolderCrawler__CrawlUnsafe
    : __FolderCrawler__Crawl;
    
  self.timeSource = time_source_create(
    time_source_global, 1, time_source_units_frames,
    method(self, _Crawl), [ ], -1
  );
  time_source_start(self.timeSource);
  
  
  // Whether start in paused state.
  if (_paused == true)
  {
    time_source_pause(self.timeSource);
  }
}



#endregion
// 
//=============================================================
// 
#region FOLDER CRAWLER METHODS : DEBUG.


/**
* Returns how many items have found already,
* useful for debugging etc.
* 
* @context FolderCrawler
*/ 
function __FolderCrawler_CurrentCount()
{
  return self.itemCount;
}



/**
* Returns what is currently active target folder, 
* useful for debugging etc.
* 
* @context FolderCrawler
*/ 
function __FolderCrawler_CurrentFolder()
{
  return (self.folder != undefined)
    ? self.folder
    : self.result
}



/**
* Returns what is currently active path, 
* useful for debugging etc.
* 
* @context FolderCrawler
*/ 
function __FolderCrawler_CurrentPath()
{
  return self.CurrentFolder().path;
}




#endregion
// 
//=============================================================
// 
#region FOLDER CRAWLER METHODS : PAUSING.



/**
* Returns whether crawler has been paused.
* 
* @context FolderCrawler
* @returns {Bool}
*/
function __FolderCrawler_IsPaused()
{
  if (self.IsFinished() == true)
  {
    return false;
  }
  
  var _state = time_source_get_state(self.timeSource);
  return (_state == time_source_state_paused);
};



/**
* Pauses active crawling, which can be resumed later.
* 
* @context FolderCrawler
*/
function __FolderCrawler_Pause()
{
  if (self.IsFinished() == true)
  {
    return;
  }
    
  time_source_pause(self.timeSource);
};



/**
* If crawler has been paused, then resume execution.
* 
* @context FolderCrawler
*/ 
function __FolderCrawler_Resume()
{
  if (self.IsFinished() == true)
  {
    return;
  }
  
  time_source_resume(self.timeSource);
};




#endregion
// 
//=============================================================
// 
#region FOLDER CRAWLER METHODS : FINISHING.


  
/**
* Returns whether crawler has finished / stopped.
* 
* @context FolderCrawler
* @returns {Bool}
*/ 
function __FolderCrawler_IsFinished()
{
  return self.finished;
}



/**
* Stops crawler, can't be reactivated.
* This will do the callback with given status.
* 
* @context FolderCrawler
* @param {String} _status How finished.
*/
function __FolderCrawler_Finish(_status)
{
  time_source_destroy(self.timeSource);
  self.timeSource = undefined;
  self.finished = true;
  self.Callback(_status, self.result, self);
}



#endregion
// 
//=============================================================
// 
#region FUNCTION : THE CRAWL



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
  // Iterate until frame-budget has been exhausted.
  var _timeTarget = (get_timer() + self.budget);
  while(get_timer() < _timeTarget)
  {
    if (self.folder != undefined)
    {
      // Iterate through items in current folder.
      // -> These are names which have already been collected with file-find.
      // -> So these are not dealing with global state anymore, 
      //    and therefore can quit when frame budget is exceeded.
      while(array_length(self.names) > 0)
      {
        // To not exceed the frame budget.
        // -> Do early quit.
        if (get_timer() >= _timeTarget)
        {
          return;
        }
        
        // Get the next item path.
        var _name = array_pop(self.names);
        var _path = (self.folder.path + "\\" + _name);
        var _item = undefined;
        
        // Create structure for the found item.
        if (directory_exists(_path) == true)
        {
          _item = new FolderCrawler_Folder(self.folder, _name, _path);
          array_push(self.folder.folders, _item);
          array_push(self.stack, _item);
        }
        else
        {
          _item = new FolderCrawler_File(self.folder, _name, _path);
          array_push(self.folder.files, _item);
        }
        
        // Call the action.
        self.Action(_item);
        self.itemCount += 1;
      }
    }
    
    
    // NOTE! 
    // Following should not be reachable until self.names is empty!
    // -> Previous loop iterates it empty (can extend to several frames).
    
    
    // Pop next iteration target.
    // -> This will be next name-iterations target.
    self.folder = array_pop(self.stack);
      
      
    // Check if no more items left -> end the loop.
    if (self.folder == undefined)
    {
      self.Finish(self.status.success);
      return;
    }
  
  
    // Iterate through the current path items.
    // -> Done in single step because file-finding has global state.
    // -> After all names have been found, loop will returns back.
    var _name = file_find_first(
      (self.folder.path + "\\*"), 
      (self.attributes)
    );
    while(_name != "")
    {
      array_push(self.names, _name);
      _name = file_find_next();
    }
    file_find_close();
  }
}



#endregion
// 
//=============================================================
// 
#region FUNCTION : THE UNSAFE CRAWL



/**
* Crawls through folders and files, quits whenever time budget is spent.
* Should not be called by the user. The timesource should handle this.
* 
* This is "unsafe" version, as it will assume being only one using file_find_* functions.
* -> This allows splitting use of these functions, and avoid stutters with large folders.
* 
* @context FolderCrawler
* @returns {Undefined}
*/ 
function __FolderCrawler__CrawlUnsafe()
{
  // Iterate until frame-budget has been exhausted.
  var _timeTarget = (get_timer() + self.budget);
  while(get_timer() < _timeTarget)
  {
    // Iterate through through all names within folder.
    // -> This uses global state of file_find_* functions.
    // -> Assumes none else tampers with it while doing iterations.
    while(self.next != "")
    {
      // To not exceed the frame budget.
      // -> Do early quit.
      if (get_timer() >= _timeTarget)
      {
        return;
      }
        
      // Get the next item path.
      var _name = self.next;
      var _path = (self.folder.path + "\\" + _name);
      var _item = undefined;
        
      // Create structure for the found item.
      if (directory_exists(_path) == true)
      {
        _item = new FolderCrawler_Folder(self.folder, _name, _path);
        array_push(self.folder.folders, _item);
        array_push(self.stack, _item);
      }
      else
      {
        _item = new FolderCrawler_File(self.folder, _name, _path);
        array_push(self.folder.files, _item);
      }
        
      // Call the action.
      self.Action(_item);
      self.next = file_find_next();
      self.itemCount += 1;
    }
    
    
    // Pop next iteration target.
    // -> This will be next name-iterations target.
    self.folder = array_pop(self.stack);
    file_find_close();
    
    
    // Check if no more items left -> end the loop.
    if (self.folder == undefined)
    {
      self.Finish(self.status.success);
      return;
    }
    
    
    // Preparate for the next iteration.
    self.next = file_find_first(
      (self.folder.path + "\\*"), 
      (self.attributes)
    );
  }
}



#endregion
// 
//=============================================================