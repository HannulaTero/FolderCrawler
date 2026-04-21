

/**
* Returns what path is being currently crawled.
* 
* @context FolderCrawler
* @returns {String}
*/ 
function __FolderCrawler__DebugPath()
{
  return (self.folderCurrent != undefined)
    ? self.folderCurrent.path
    : "";
}