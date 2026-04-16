/// @desc MOVE WITHIN FOLDERS.

// Don't try, if structure doesn't exist yet.
if (self.current == undefined)
{
  exit;
}


// Update last index in the stack.
// Easier to pop and push back.
if (keyboard_check_pressed(vk_up) == true)
{
  var _index = array_pop(self.index);
  _index -= 1;
  if (_index < 0)
  {
    _index = array_length(self.items) - 1;
  }
  array_push(self.index, _index);
}


if (keyboard_check_pressed(vk_down) == true)
{
  var _index = array_pop(self.index);
  _index += 1;
  if (_index >= array_length(self.items))
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
    self.items = array_concat(
      self.current.folders,
      self.current.files
    );
  }
}


// Move inside the selected folder.
if (keyboard_check_pressed(vk_right) == true)
{
  if (array_length(self.items) > 0)
  {
    var _item = self.items[array_last(self.index)];
    if (_item.type == "folder")
    {
      array_push(self.index, 0);
      self.current = _item;
      self.items = array_concat(
        self.current.folders,
        self.current.files
      );
    }
  }
}
