

/**
* Adds given name as folder to the current folder, but only if 
* it is a folder - this is decided whether it can be found in files. 
* 
* @context FolderCrawler
* @param {String} _name
*/ 
function __FolderCrawler__Crawl_Folder(_name)
{
  // Check whether it is a file.
  if (ds_map_exists(self.currFiles, _name) == true)
  {
    return;
  }
  
  // Otherwise create new folder for given path.
  var _path = (self.folderCurrent.path + "\\" + _name);
  var _folder = new FolderCrawler_Folder(self.folderCurrent, _name, _path);
  array_push(self.folderStack, _folder);
  self.ActionFolder(_folder, self.userContext);
  self.itemCount += 1;
}