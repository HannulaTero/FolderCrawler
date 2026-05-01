/// @desc CHANGE EXAMPLE.

if (keyboard_check_pressed(vk_anykey) == true)
{
  // Parse the input key.
  var _char = keyboard_lastchar;
  var _byte = ord(_char);
  var _index = (_byte - ord("0"));
  keyboard_lastchar = "";
  
  
  // If valid index, then change example.
  if (_index >= 0)
  && (_index < array_length(self.examples))
  {
    instance_destroy(object_FolderCrawler_Example_parent);
    instance_create_depth(0, 0, 0, self.examples[_index]);
  }
}