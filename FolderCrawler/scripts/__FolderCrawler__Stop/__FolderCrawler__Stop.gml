

/**
* Stops crawler, can't be reactivated.
* This will do the callback with "failure" status.
* 
* @context FolderCrawler
*/
function __FolderCrawler__Stop()
{
  time_source_destroy(self.timeSource);
  ds_map_destroy(self.currFiles);
  self.timeSource = undefined;
  self.status     = FolderCrawler.crawlStates.failure;
  self.Callback(self, self.userContext);
}