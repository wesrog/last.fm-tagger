#
#  AppController.rb
#  last.fm-tagger
#
#  Created by Wes Rogers on 7/6/08.
#  Copyright (c) 2008 633k.net. All rights reserved.
#

class AppController < NSObject
  ib_outlet :tagStatus
  
  def windowWillClose(note)
    NSApp.terminate(self)
  end

  def awakeFromNib
    @tagStatus.setUsesThreadedAnimation(true)
  end
end
