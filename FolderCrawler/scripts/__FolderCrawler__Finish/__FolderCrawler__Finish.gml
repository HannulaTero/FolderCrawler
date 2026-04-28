

/**
* Makes crawling finish with successful status.
* Stops crawler, can't be reactivated.
* 
* @context FolderCrawler
*/
function __FolderCrawler__Finish()
{
  time_source_destroy(self.iterator.timeSource);
  ds_map_destroy(self.iterator.fileMapping);
  self.iterator.timeSource = undefined;
  self.iterator.status     = FolderCrawler_Status.SUCCESS;
  self.iterator.Callback(self, self.iterator.userContext);
}