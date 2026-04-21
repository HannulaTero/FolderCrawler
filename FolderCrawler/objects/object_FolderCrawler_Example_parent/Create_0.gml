/// @desc COMMON.


// The label of the example.
self.label = "Example [X]"


// Just for drawing stuff.
self.printer = new FolderCrawler_Printer();


// When crawling started.
self.timeBegin = get_timer();


// Showing how long it took.
self.timeTaken = 0;


// How many items found during the drawl.
self.foundCount = 0;


// Status of the crawling.
self.status = "nothing";


// What is the overall structure.
self.structure = undefined;


// JSON version of the structure.
self.json = "";