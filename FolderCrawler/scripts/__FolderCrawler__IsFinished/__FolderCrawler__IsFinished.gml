

/**
* Returns whether crawler has finished / stopped.
* 
* @context FolderCrawler
* @returns {Bool}
*/ 
function __FolderCrawler__IsFinished()
{
  return (self.status != FolderCrawler.crawlStates.pending);
}