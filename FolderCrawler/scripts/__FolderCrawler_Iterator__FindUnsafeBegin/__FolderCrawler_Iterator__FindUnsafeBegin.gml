

/**
* 
* 
* @context __FolderCrawler_Iterator
* @param {String}                 _mask
* @param {Constant.FileAttribute} _attr
*/ 
function __FolderCrawler_Iterator__FindUnsafeBegin(_mask, _attr)
{
  self.nextName = file_find_first(_mask, _attr);
}