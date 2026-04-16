//=============================================================
// 
#region INFORMATION.
/*
  
  This asset can be used to crawl out larger folder/file-structures
  without making the game to freeze up. 
  
  Note that sandboxing can affect where can be crawled, 
  so check the project sandbox settings.
  
  As file_find_* has global state, asset avoids spreading its use 
  over several frame, therefore it collects all names within 
  folder at once, and then creates structure and pushes next 
  folders for dispatching. This does mean there is possiblity that
  folder just contains so many files/folders, that game still 
  freezes. This could be avoided, if also use of file_find_* is 
  spread over several frames, which this asset doesn't do.
  
  You can use either use folder_crawl, or FolderCrawler.
  
  folder_crawl queues up the requests, so only one crawler
  is active at given time. Only accounts crawlers dispatched with it.
  
  FolderCrawler is dispatched directly.
  
  
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
#region FUNCTION : folder_crawl



/**
* Convenience function for dispatching FolderCrawler, not strictly required.
* 
* Dispatches crawlers one at the time, so there won't be many crawlers
* simultanously active. Rest are kept in pending-queue, waiting for their turn.
* 
* @param {String}   _path       Root-path where crawling is started.
* @param {Function} _Callback   Signature: function(_success, _result)
* @param {Struct}   _params     Other parameters, such as frame-budget.
*/ 
function folder_crawl(_path, _Callback, _params={ })
{
  // Currently active crawler dispatched with this function.
  static current = undefined;
  
  
  // How many are waiting to be dispatched.
  static pending = ds_queue_create();
  
  
  // Dispatches 
  static timeSource = time_source_create(
    time_source_global, 1, time_source_units_frames,
    __folder_crawl__dispatcher, [ ], -1
  );
  
  
  // (Re)Activate the timesource.
  switch(time_source_get_state(folder_crawl.timeSource))
  {
    case time_source_state_initial: time_source_start(folder_crawl.timeSource); break;
    case time_source_state_stopped: time_source_start(folder_crawl.timeSource); break;
    case time_source_state_paused:  time_source_resume(folder_crawl.timeSource); break;
  }
  
  
  // Push crawler into pending, dispatcher deals activating them whenever ready.
  var _crawler = new FolderCrawler(_path, _Callback, _params);
  ds_queue_enqueue(folder_crawl.pending, _crawler);
  _crawler.Pause();
  return _crawler;
}



#endregion
// 
//=============================================================
// 
#region CONSTRUCTOR : CRAWLER.



/**
* Crawls through files and folders within given path.
* 
* This is asynchronous / non-blocking, so crawling can be split into several frames.
* -> Crawler has time-budget how much it can try iterate.
* -> By default budget is high: 0.90 -> 90% of the frame time.
* 
* Note, because of file_find_* have global state, crawler will find
* all possible names within folder at once without stopping.
* -> This is done to avoid problems if file_find_* function are used elsewhere.
* -> If single folder has lot of files/folders, this can cause stutter.
* 
* Optional parameters are:
* - budget      : Real                    --- Relative part of the frame, such as 0.5
* - attributes  : Constant.FileAttribute  --- What file-types are being searched.
* - paused      : Bool                    --- Whether crawler starts in paused state.
* 
* @param {String}   _path       Root folder path where crawling is started.
* @param {Function} _Callback   Signature: function(_success, _result)
* @param {Struct}   _params     Other parameters, such as frame-budget.
*/ 
function FolderCrawler(_path, _Callback, _params={ }) constructor
{
  //=============================================================
  // 
  #region DEFINE VARIABLES.
  
  
  
  // What is root-path, where crawling is started.
  self.path = _path;
  
  
  // Called when crawling finished / stops.
  self.Callback = _Callback;
  
  
  // How much time can be used at one frame.
  self.budget = (
    (_params[$ "budget"] ?? self.defaultBudget) * 
    game_get_speed(gamespeed_microseconds)
  );
  
  
  // What is being searched.
  self.attributes = (
    _params[$ "attributes"] ?? self.defaultAttributes
  );
  
  
  // Timesource, which does the iteration loop
  self.timeSource = time_source_create(
    time_source_global, 1, time_source_units_frames,
    method(self, __FolderCrawler__Crawl), [ ], -1
  );
  time_source_start(self.timeSource);
  
  var _paused = (_params[$ "paused"] ?? false);
  if (_paused == true)
  {
    time_source_pause(self.timeSource);
  }
  
  
  // Resulting folder-structure.
  self.result = new FolderCrawler_Folder(
    undefined, "./", self.path
  ); 
  
  
  // Whether crawler has finished / stopped.
  self.finished = false;


  // Holds pending folders, which will be crawled.
  self.stack = [ self.result ];
  

  // The currently active folder, which is being iterated through.
  self.folder = undefined;
  
  
  // File and folder names of the currently active folder.
  self.names = [ ];
  
  
  // How many items have been found.
  self.itemCount = 0;
  
  
  
  #endregion
  // 
  //=============================================================
  // 
  #region DEFINE STATIC VARIABLES.
  
  
  
  // What is default relative frame budget.
  static defaultBudget = 0.90;
  
  
  // What is being searched.
  static defaultAttributes = (os_type == os_windows)
    ? (fa_none | fa_directory)
    : (fa_none);
  
  
  // Used in callback to tell what has happened.
  static status = {
    success : "success",
    stopped : "stopped",
    failure : "failure"
  };
  
  
  
  #endregion
  // 
  //=============================================================
  // 
  #region DEFINE STATIC METHODS.
  
  
  
  /**
  * Returns how many items have found already,
  * useful for debugging etc.
  */ 
  static CurrentCount = function()
  {
    return self.itemCount;
  };
  
  
  
  /**
  * Returns what is currently active target folder, 
  * useful for debugging etc.
  */ 
  static CurrentFolder = function()
  {
    return (self.folder != undefined)
      ? self.folder
      : self.result
  };
  
  
  
  /**
  * Returns what is currently active path, 
  * useful for debugging etc.
  */ 
  static CurrentPath = function()
  {
    return self.CurrentFolder().path;
  };
  
  
  
  /**
  * Returns whether crawler has finished / stopped.
  * 
  * @returns {Bool}
  */ 
  static IsFinished = function()
  {
    return self.finished;
  };



  /**
  * Pauses active crawling, which can be resumed later.
  */
  static Pause = function()
  {
    if (self.IsFinished() == true)
    {
      return;
    }
    
    time_source_pause(self.timeSource);
  };



  /**
  * If crawler has been paused, then resume execution.
  */ 
  static Resume = function()
  {
    if (self.IsFinished() == true)
    {
      return;
    }
  
    time_source_resume(self.timeSource);
  };



  /**
  * Stops crawler, can't be reactivated.
  * 
  * This will do the callback with given status.
  * -> If called by user, assuming "stopped", though can be overridden.
  * 
  * @param {String} _status How finished.
  */
  static Finish = function(_status=self.status.stopped)
  {
    time_source_destroy(self.timeSource);
    self.timeSource = undefined;
    self.finished = true;
    self.Callback(_status, self.result, self);
  };
  
  
  
  #endregion
  // 
  //=============================================================
}



#endregion
// 
//=============================================================
// 
#region CONSTRUCTOR : Folder.



/**
* Holds folder path and name, and references to underlying folders and files.
* 
* @param {Struct.FolderCrawler_Folder | Undefined} _root
* @param {String} _name
* @param {String} _path
*/
function FolderCrawler_Folder(_root, _name, _path) constructor
{
  // The construct type, for convenience.
  static type = "folder";
  
  
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
#region CONSTRUCTOR : File.



/**
* Holds file path and name.
* 
* @param {Struct.FolderCrawler_Folder} _root
* @param {String} _name
* @param {String} _path
*/
function FolderCrawler_File(_root, _name, _path) constructor
{
  // The construct type, for convenience.
  static type = "file";
  
  
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
#region HELPER : folder_crawl dispatcher.



/**
* For dispatching crawlers in ordered manner.
*/ 
function __folder_crawl__dispatcher()
{    
  // Check whether there is currently active crawler,
  // and whether it has already finished.
  if (folder_crawl.current != undefined)
  && (folder_crawl.current.IsFinished() == false)
  {
    return;
  }
  
  
  // Get next crawler.
  folder_crawl.current = ds_queue_dequeue(folder_crawl.pending);
  
  
  // If the is no active crawler, then there are no pending crawlers left.
  // -> Pause the timesource for dispatcher.
  if (folder_crawl.current == undefined)
  {
    time_source_pause(folder_crawl.timeSource);
    return;
  }
  
  
  // Otherwise activate the crawler.
  folder_crawl.current.Resume();
}



#endregion
// 
//=============================================================
// 
#region FUNCTION : THE CRAWL



/**
* Crawls through folders and files, quits whenever time budget is spent.
* Should not be called by the user. The timesource should handle this.
* 
* @context FolderCrawler
* @returns {Undefined}
*/ 
function __FolderCrawler__Crawl()
{
  // Preparations.
  // -> It's slightly faster to access local variables.
  // -> Can be outside the loop, as references stay the same.
  var _names = self.names;
  var _stack = self.stack;
      
      
  // Iterate until frame-budget has been exhausted.
  var _timeTarget = (get_timer() + self.budget);
  while(get_timer() < _timeTarget)
  {
    if (self.folder != undefined)
    {
      // Preparations.
      // -> It's slightly faster to access local variables.
      // -> Kept inside the loop, as folder changes.
      var _root     = self.folder;
      var _curr     = _root.path;
      var _files    = _root.files;
      var _folders  = _root.folders;
      
    
      // Iterate through items in current folder.
      // -> These are names which have already been collected with file-find.
      // -> So these are not dealing with global state anymore, 
      //    and therefore can quit when frame budget is exceeded.
      while(array_length(_names) > 0)
      {
        // To not exceed the frame budget.
        // -> Do early quit.
        if (get_timer() >= _timeTarget)
        {
          return;
        }
        
        
        // Create structures for the found items.
        self.itemCount += 1;
        var _name = array_pop(_names);
        var _path = (_curr + "\\" + _name);
        if (directory_exists(_path) == true)
        {
          var _folder = new FolderCrawler_Folder(_root, _name, _path);
          array_push(_folders, _folder);
          array_push(_stack, _folder);
        }
        else
        {
          var _file = new FolderCrawler_File(_root, _name, _path);
          array_push(_files, _file);
        }
      }
    }
    
    
    // NOTE! 
    // Following should not be reachable until self.names is empty!
    // -> Previous loop iterates it empty (can extend to several frames).
    
    
    // Pop next iteration target.
    // -> This will be next name-iterations target.
    self.folder = array_pop(_stack);
  
  
    // Iterate through the current path items.
    // -> Done in single step because file-finding has global state.
    // -> After all names have been found, loop will returns back.
    if (self.folder != undefined)
    {
      // Preparations. Bit faster to access local variables.
      var _name = file_find_first(
        (self.folder.path + "\\*"), 
        (self.attributes)
      );
        
        
      // Iterate through all items within the folder.
      while(_name != "")
      {
        array_push(_names, _name);
        _name = file_find_next();
      }
      file_find_close();
    }
      
      
    // Check if no more items left -> end the loop.
    if (self.folder == undefined)
    && (array_length(_names) <= 0)
    {
      self.Finish(self.status.success);
      return;
    }
  }
}



#endregion
// 
//=============================================================