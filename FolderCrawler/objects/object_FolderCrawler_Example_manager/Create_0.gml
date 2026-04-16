/// @desc INITIALIZE.


// Handling async requests in GM.
self.dialogRequests = ds_map_create();


// Helper method.
self.GetString = function(
  _message, 
  _default="", 
  _callback=function(_status, _result) {}
)
{
  var _id = get_string_async(_message, _default);
  self.dialogRequests[? _id] = _callback;
  return _id;
};