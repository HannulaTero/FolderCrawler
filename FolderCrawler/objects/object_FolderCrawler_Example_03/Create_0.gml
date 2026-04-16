/// @desc INITIALIZATION.


//
self.timeBegin = get_timer();


//
self.timeTaken = 0;


//
self.foundCount = 0;


// 
self.status = "nothing";


//
self.structure = undefined;


// Currently active folder, which is being viewed.
self.current = undefined;


// Bit of hacky way,
// This should contain concat arrays of both folders and files from current folder.
self.items = [ ];


// Stack of indexes
// -> So when returning up from folder, can restore old position.
self.index = [ 0 ];