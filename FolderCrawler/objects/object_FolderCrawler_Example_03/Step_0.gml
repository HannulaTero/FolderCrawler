/// @desc MOVE WITHIN FOLDERS.


var _count = array_length(self.names);


// Update last index in the stack.
if (keyboard_check_pressed(vk_up) == true)
{
  // Easier to pop and push back.
  var _index = array_pop(self.index);
  _index -= 1;
  if (_index < 0)
  {
    _index = _count - 1;
  }
  array_push(self.index, _index);
}


if (keyboard_check_pressed(vk_down) == true)
{
  var _index = array_pop(self.index);
  _index += 1;
  if (_index >= _count)
  {
    _index = 0;
  }
  array_push(self.index, _index);
}


// Move upwards in folder structure.
if (keyboard_check_pressed(vk_left) == true)
{
  if (self.current.root != undefined)
  {
    array_pop(self.index);
    self.current = self.current.root;
    self.names = array_concat(
      struct_get_names(self.current.folders), 
      struct_get_names(self.current.files)
    );
  }
}


// Move inside the selected folder.
if (keyboard_check_pressed(vk_right) == true)
{
  if (_count > 0)
  {
    var _index  = array_last(self.index);
    var _name   = self.names[ _index ];
    var _item   = self.current.folders[$ _name];
    
    if (_item != undefined)
    {
      array_push(self.index, 0);
      self.current = _item;
      self.names = array_concat(
        struct_get_names(_item.folders), 
        struct_get_names(_item.files)
      );
    }
  }
}
