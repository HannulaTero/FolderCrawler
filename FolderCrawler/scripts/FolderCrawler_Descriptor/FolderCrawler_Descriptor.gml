

/**
* The descriptor signature for the crawler.
* 
*
* This defines possible arguments for the crawler,
* and their expected types as default values.
*/ 
function FolderCrawler_Descriptor()
{
  return {
    path        : working_directory,
    mask        : "*",
    unsafe      : false,
    paused      : false,
    context     : undefined,
    budget      : FolderCrawler.defaultBudget,
    attributes  : FolderCrawler.defaultAttributes,
    init        : __FolderCrawler__DefaultActionInit,
    open        : __FolderCrawler__DefaultActionOpen,
    file        : __FolderCrawler__DefaultActionFile,
    folder      : __FolderCrawler__DefaultActionFolder,
    callback    : __FolderCrawler__DefaultCallback,
  };
}