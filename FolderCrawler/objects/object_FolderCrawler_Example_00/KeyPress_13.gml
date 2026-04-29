/// @desc SEARCH WORKING DIRECTORY.


// Get the starting time..
self.timeBegin = get_timer();
self.status = "waiting...";


// Dispatch the crawler.
self.handle = folder_crawl(working_directory);