

/**
* Adds given name as file unquestionable to the current folder.
* The iteration loop should ensure given name only is file,
* this can be achieven with attributes.
* 
* @context FolderCrawler
* @param {String} _name
*/ 
function __FolderCrawler__Crawl_File(_name)
{
  // Create new file for given path.
  var _path = (self.folderCurrent.path + "\\" + _name);
  var _file = new FolderCrawler_File(self.folderCurrent, _name, _path);
  self.ActionFile(_file, self.userContext);
  self.itemCount += 1;
  
  // Add into current files.
  self.currFiles[? _name] = _file;
}