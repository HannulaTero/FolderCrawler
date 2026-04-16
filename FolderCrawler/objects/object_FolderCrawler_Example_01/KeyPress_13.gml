/// @desc SEARCH WORKING DIRECTORY.

self.timeBegin = get_timer();

folder_crawl(working_directory, function(_status, _result, _crawler)
{
  self.timeTaken  = (get_timer() - self.timeBegin);
  self.foundCount = _crawler.itemCount;
  self.structure  = _result;
});