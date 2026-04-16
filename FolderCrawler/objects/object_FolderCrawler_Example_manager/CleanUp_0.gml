/// @desc CLEAN-UP.

if (ds_exists(self.dialogRequests, ds_type_map) == true)
{
  ds_map_destroy(self.dialogRequests);
}