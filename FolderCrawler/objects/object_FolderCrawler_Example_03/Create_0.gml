/// @desc INITIALIZATION.

// Just for drawing stuff.
self.printer = new FolderCrawler_Printer();


// Handle for crawler.
self.handle = undefined;


// Currently active folder, which is being viewed.
// -> When crawling has been done, then it is updated as the root.
// -> In the beginning it holds only the dummy folder.
self.current = new FolderCrawler_Folder(undefined, "...", "...");


// The names of folders and files within current folder.
self.names = [ ];


// Stack of indexes
// -> So when returning up from folder, can restore old position.
self.index = [ 0 ];