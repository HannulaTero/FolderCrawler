/// @desc GET DIALOGUE RESPONSE.

// Check whether there exists callback for the id.
var _id = async_load[? "id"];
var _callback = self.dialogRequests[? _id];
if (_callback == undefined)
{
  exit;
}


// Remove index, read result and check the status  
ds_map_delete(self.dialogRequests, _id);
var _result = async_load[? "result"];
var _status = async_load[? "status"];

_status = _status ? "success" : "failed";


// Do the callback.
_callback(_status, _result);
