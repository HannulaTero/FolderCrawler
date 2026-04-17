/// @desc CHANGE EXAMPLE.

if (keyboard_check_pressed(vk_anykey) == true)
{
  switch(keyboard_key)
  {
    case ord("1"): {
      instance_destroy(object_FolderCrawler_Example_parent);
      instance_create_depth(0, 0, 0, object_FolderCrawler_Example_01);
      break;
    }
    
    case ord("2"): {
      instance_destroy(object_FolderCrawler_Example_parent);
      instance_create_depth(0, 0, 0, object_FolderCrawler_Example_02);
      break;
    }
    
    case ord("3"): {
      instance_destroy(object_FolderCrawler_Example_parent);
      instance_create_depth(0, 0, 0, object_FolderCrawler_Example_03);
      break;
    }
    
    case ord("4"): {
      instance_destroy(object_FolderCrawler_Example_parent);
      instance_create_depth(0, 0, 0, object_FolderCrawler_Example_04);
      break;
    }
  }
}