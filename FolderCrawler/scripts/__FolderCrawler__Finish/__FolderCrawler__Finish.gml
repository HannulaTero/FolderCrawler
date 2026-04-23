

/**
* Makes crawling finish with successful status.
* Stops crawler, can't be reactivated.
* 
* @context FolderCrawler
*/
function __FolderCrawler__Finish()
{
  time_source_destroy(self.timeSource);
  ds_map_destroy(self.currFiles);
  self.timeSource = undefined;
  self.status     = FolderCrawler.crawlStates.success;
  self.Callback(self, self.userContext);
}