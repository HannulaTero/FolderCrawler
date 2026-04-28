

/**
* Stops crawler, can't be reactivated.
* This will do the callback with "failure" status.
* 
* @context FolderCrawler
*/
function __FolderCrawler__Stop()
{
  time_source_destroy(self.iterator.timeSource);
  ds_map_destroy(self.iterator.fileMapping);
  self.iterator.timeSource = undefined;
  self.iterator.status     = FolderCrawler_Status.FAILURE;
  self.iterator.Callback(self, self.iterator.userContext);
}