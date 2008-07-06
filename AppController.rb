#
#  AppController.rb
#  last.fm-tagger
#
#  Created by Wes Rogers on 7/6/08.
#  Copyright (c) 2008 __MyCompanyName__. All rights reserved.
#

class AppController < NSObject
  def windowWillClose(note)
    NSApp.terminate(self)
  end
end
