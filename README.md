# FolderCrawler
## [GameMaker] Asynchronously finding all folder and files within given path.

[On Itchio](https://terohannula.itch.io/foldercrawler)

This asset can be used to crawl out larger folder/file-structures without making the game to freeze up. 

Note that sandboxing can affect where can be crawled, so check the project sandbox settings.

As file_find_* has global state, asset avoids spreading its use over several frame, therefore it collects all names within folder at once, and then creates structure and pushes next folders for dispatching. This does mean there is possiblity that folder just contains so many files/folders, that game still freezes. This could be avoided, if also use of file_find_* is spread over several frames. This can be done by using "unsafe" mode, then crawler trusts user to not touch file_find_* functions while it is doing its stuff.

folder_crawl queues up the requests, so only one crawler is active at given time. Only accounts crawlers dispatched with it. You can use either use folder_crawl, or FolderCrawler-construct directly.

The result is structure made out of Folder and File -constructs, Folder containing arrays for Folder and File contained within. 

## Example of uses:

Simple example:
```gml
folder_crawl("C:\\Users\\user\\files\\github\\FolderCrawler", function(_status, _result)
{
  // Print prettified JSON version of results:
  show_debug_message(json_stringify(_result, true));
}); 

```

There are few convenience methods too, and crawler accepts optional parameters as struct.
```gml
// Preprations
self.path = "C:\\Users\\user\\files\\github";
self.result = undefined;
self.timeStart = get_timer();

// Dispatching a crawler
self.handle = folder_crawl(self.path, function(_status, _result, _crawler)
{
  show_debug_message($"finished with status : {_status}");
  show_debug_message($"found : {_crawler.foundCount} items");
  show_debug_message($"time taken : {(self.timeStart - get_timer()) / 1000} ms");
  self.result = _result;
}, {
  budget : 0.5, // Half of the frame-time is allocated for crawl.
}); 

// Using methods.
self.handle.Pause();
self.handle.Resume();

if (self.handle.IsFinished() == false)
{
  show_debug_message("Still waiting.");
}
```
You may also create crawler directly, same pattern as folder_crawl. The convenience function just helps queueing several requests.
```gml
self.handle = new FolderCrawler(_path, function(_status, _result, _crawler)
{
  // Do stuff here.
}); 
```
