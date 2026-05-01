```gml
===============================================================
  ___    _    _          ___                 _
 | __|__| |__| |___ _ _ / __|_ _ __ ___ __ _| |___ _ _
 | _/ _ \ / _` / -_) '_| (__| '_/ _` \ V  V / / -_) '_|
 |_|\___/_\__,_\___|_|  \___|_| \__,_|\_/\_/|_\___|_|
  v1.1.0 by Tero Hannula
===============================================================
```

# FolderCrawler
## [GameMaker] Asynchronously finding all folder and files within given path.

[On Itchio](https://terohannula.itch.io/foldercrawler)

===============================================================

This asset can be used to crawl out larger folder/file-structures without making the game to freeze up by splitting crawling into several frames.
Crawling will result nested structure containing structs, which represent files and folders.


Use "folder_crawl(path, params)" to dispatch crawler(s). This will queue up the requests, so only single of them is active at given time.
This is done to avoid concurrent uses of file_find_* (which is important with "unsafe" crawl) but also makes frame-budgeting simpler.

===============================================================

Note that sandboxing can affect where can be crawled, so check the project sandbox settings.
Also note platform related restrictions (HTML5 and GX for example).

As file_find_* has global state, asset avoids spreading its use over several frame, therefore it collects all names within folder at once, and then creates structure and pushes next folders for dispatching.
This does mean there is possibility that folder just contains so many files/folders, that game still freezes.
This could be avoided, if also use of file_find_* is spread over several frames.

===============================================================

The result is structure made out of Folder and File -constructs, Folder containing arrays for Folder and File contained within.

===============================================================

## Example of uses:

Simple example:
```gml
// Dispatch crawler
self.handle = folder_crawl("C:\\Users\\user\\files\\github\\FolderCrawler");

// Get the root folder.
if (self.handle.IsFinished() == true)
{
  var _root = self.handle.GetRoot();
  show_debug_message(json_stringify(_root, true));
}
```

Alternatively do the callback.
```gml
folder_crawl("C:\\Users\\user\\files\\github\\FolderCrawler", {
  callback : function(_crawler, _context)
  {
    var _root = _crawler.GetRoot();
    show_debug_message(json_stringify(, true));
  }
});
```

There are few convenience methods too, and crawler accepts optional parameters as struct.
```gml
{
    mask        : "*",
    unsafe      : false,
    paused      : false,
    context     : undefined,
    budget      : 0.925,
    attributes  : fa_none,
    init        : function(_root, _context) { },
    open        : function(_folder, _context) { },
    file        : function(_file, _context) { },
    folder      : function(_folder, _context) { },
    callback    : function(_crawler, _context) { },
}
```

The resulting structure is build from following structs :
```
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
```
