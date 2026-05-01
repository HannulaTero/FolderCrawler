


/**
* Just utility for getting string with async-version.
*/

// Helper method.
function FolderCrawler_GetString(
  _message, 
  _default="", 
  _callback=function(_status, _result) {}
)
{
  // To have a global map of requests.
  static requests = ds_map_create();
  
  
  // If doesn't exist, try activating it.
  if (instance_exists(object_FolderCrawler_Example_dialog) == false)
  {
    instance_activate_object(object_FolderCrawler_Example_dialog);
  }
  
  // If still doesn't exist, create it.
  if (instance_exists(object_FolderCrawler_Example_dialog) == false)
  {
    instance_create_depth(0, 0, 0, object_FolderCrawler_Example_dialog);
  }
  
  
  // Assign new request.
  var _id = get_string_async(_message, _default);
  FolderCrawler_GetString.requests[? _id] = _callback;
  return _id;
};