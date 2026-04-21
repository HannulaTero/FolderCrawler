

/**
* Returns whether crawler has been paused.
* 
* @context FolderCrawler
* @returns {Bool}
*/
function __FolderCrawler__IsPaused()
{
  if (self.IsFinished() == true)
  {
    return false;
  }
  
  var _state = time_source_get_state(self.timeSource);
  return (_state == time_source_state_paused);
}