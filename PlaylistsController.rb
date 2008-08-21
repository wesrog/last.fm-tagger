#
#  PlaylistsArray.rb
#  last.fm-tagger
#
#  Created by Wes Rogers on 7/5/08.
#  Copyright (c) 2008 633k.net. All rights reserved.
#

class PlaylistsController < NSArrayController
  ib_outlets :playlistsPopUp
  ib_action :reloadPlaylists
  
  def initialize
    @iTunes = SBApplication.applicationWithBundleIdentifier_("com.apple.iTunes")
  end
  
  def awakeFromNib
    @playlistsPopUp.addItemsWithTitles(@iTunes.sources.first.userPlaylists.reject { |p| p.smart == 1 }.map { |p| p.name })
  end
  
  def reloadPlaylists
    @playlistsPopUp.removeAllItems
    @playlistsPopUp.addItemsWithTitles(@iTunes.sources.first.userPlaylists.reject { |p| p.smart == 1 }.map { |p| p.name })
  end
end
