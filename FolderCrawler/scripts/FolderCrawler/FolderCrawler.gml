

/**
* Structure which does the crawling.
* This is also handle for checking states and finishing it early.
* 
* Read the descriptor for the possible arguments.
*/ 
function FolderCrawler(_descriptor=FolderCrawler_Descriptor()) constructor
{
  //=============================================================
  // 
  #region PUBLIC METHODS.
  
  
  
  // Debug methods, related, checking what crawler is currently doing.
  static DebugCount   = __FolderCrawler__DebugCount;
  static DebugFolder  = __FolderCrawler__DebugFolder;
  static DebugNext    = __FolderCrawler__DebugNext;
  static DebugPath    = __FolderCrawler__DebugPath;
  
  
  // Usual methods.
  static Finish     = __FolderCrawler__Finish;
  static GetRoot    = __FolderCrawler__GetRoot;
  static GetStatus  = __FolderCrawler__GetStatus;
  static IsFinished = __FolderCrawler__IsFinished;
  static IsPaused   = __FolderCrawler__IsPaused;
  static Pause      = __FolderCrawler__Pause;
  static Resume     = __FolderCrawler__Resume;
  static Stop       = __FolderCrawler__Stop;
  
  
  // The function signatures for different actions..
  static DefaultActionInit    = __FolderCrawler__DefaultActionInit;
  static DefaultActionOpen    = __FolderCrawler__DefaultActionOpen;
  static DefaultActionFile    = __FolderCrawler__DefaultActionFile;
  static DefaultActionFolder  = __FolderCrawler__DefaultActionFolder;
  static DefaultCallback      = __FolderCrawler__DefaultCallback;
  
  
  
  #endregion
  // 
  //=============================================================
  // 
  #region PRIVATE STATIC VARIABLES.
  
  
  
  // To tell what is the current status.
  static crawlStates = {
    pending : "pending",
    success : "success",
    failure : "failure"
  };
  
  
  // What is default relative frame budget.
  // @ignore
  static defaultBudget = 0.90;
  
  
  // What is mask used for searching - by default all.
  // @ignore
  static defaultMask = "\\*";
  
  
  // What attributes is being searched.
  // @ignore
  static defaultAttributes = (fa_none | fa_directory);
  
  
  
  #endregion
  // 
  //=============================================================
  // 
  #region PRIVATE VARIABLES.
  
  
  
  // What is the action when crawling is initialized.
  // @ignore
  self.ActionInit = self.DefaultActionInit;
  
  
  // What is the action for folders while crawling.
  // @ignore
  self.ActionFolder = self.DefaultActionFolder;
  
  
  // What is the action for files while crawling.
  // @ignore
  self.ActionFile = self.DefaultActionFile;
  
  
  // Called when crawling finished / stops.
  // @ignore
  self.Callback = self.DefaultCallback;
  
  
  // How much time can be used at one frame.
  // @ignore
  self.budget = self.defaultBudget;
  
  
  // What search mask.
  // @ignore
  self.mask = self.defaultMask;
  
  
  // What attributes are used while searching.
  // @ignore
  self.attributes = self.defaultAttributes;
  
  
  // Select the crawling method and create iterator.
  // Timesource does the iteration loop.
  // @ignore
  self.timeSource = undefined;
  
  
  // Context, which is passed to the actions.
  // @ignore
  self.userContext = undefined; 
  
  
  // What is the crawling status.
  // @ignore
  self.status = FolderCrawler.crawlStates.pending;


  // Holds pending folder paths, which will be crawled.
  // @ignore
  self.folderStack = [ ];
  

  // The currently active folder, which is being iterated through.
  // @ignore
  self.folderCurrent = undefined;
  

  // The root folder, where crawling begin.
  // @ignore
  self.folderRoot = undefined;
  
  
  // File and folder names of the currently active folder.
  // -> Used for the "safe" iterations.
  // @ignore
  self.pendingNames = [ ];
  
  
  // Next name in "unsafe" iteration.
  // @ignore
  self.nextName = "";
  
  
  // What action is being taken.
  // @ignore
  self.AddItem = undefined;
  
  
  // Contains the found files in the current iteration.
  // In 2nd pass this is used to determine, whether given name is folder.
  // @ignore
  self.currFiles = ds_map_create();
  
  
  // How many items have been found.
  // @ignore
  self.itemCount = 0;
  
  
  // Define the variables.
  __FolderCrawler__Config(_descriptor);
  
  
  
  #endregion
  // 
  //=============================================================
}

