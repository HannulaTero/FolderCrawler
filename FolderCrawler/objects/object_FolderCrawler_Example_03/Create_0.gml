/// @desc INITIALIZATION.

event_inherited();


// 
self.label = "Example [3] same as before, but allows moving through folders"


// Currently active folder, which is being viewed.
self.current = undefined;


// Stack of indexes
// -> So when returning up from folder, can restore old position.
self.index = [ 0 ];