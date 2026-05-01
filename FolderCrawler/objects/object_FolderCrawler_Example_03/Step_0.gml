/// @desc MOVE WITHIN FOLDERS.

// Don't try, if structure doesn't exist yet.
if (self.current == undefined)
&& (self.structure == undefined)
{
  exit;
}


// Give the structure starting position if not defined.
if (self.current == undefined)
{
  self.current = self.structure;
}


// Update last index in the stack.
if (keyboard_check_pressed(vk_up) == true)
{
  // Easier to pop and push back.
  var _index = array_pop(self.index);
  _index -= 1;
  if (_index < 0)
  {
    _index = array_length(self.current.folders) - 1;
  }
  array_push(self.index, _index);
}


if (keyboard_check_pressed(vk_down) == true)
{
  var _index = array_pop(self.index);
  _index += 1;
  if (_index >= array_length(self.current.folders))
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
  }
}


// Move inside the selected folder.
if (keyboard_check_pressed(vk_right) == true)
{
  if (array_length(self.current.folders) > 0)
  {
    var _index = array_last(self.index);
    var _item = self.current.folders[_index];
    if (_item.type == "folder")
    {
      array_push(self.index, 0);
      self.current = _item;
    }
  }
}
