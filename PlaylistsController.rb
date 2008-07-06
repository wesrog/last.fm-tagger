#
#  PlaylistsArray.rb
#  last.fm-tagger2
#
#  Created by Wes Rogers on 7/5/08.
#  Copyright (c) 2008 633k.net. All rights reserved.
#

class PlaylistsController < NSArrayController
  ib_outlets :playlistsPopUp
  
  def initialize
    @iTunes = SBApplication.applicationWithBundleIdentifier_("com.apple.iTunes")
  end
  
  def awakeFromNib
    @playlistsPopUp.addItemsWithTitles(@iTunes.sources.first.userPlaylists.reject { |p| p.smart == 1 }.map { |p| p.name })
  end
end
