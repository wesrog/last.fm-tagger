#
#  ArtistsArray.rb
#  last.fm-tagger2
#
#  Created by Wes Rogers on 7/5/08.
#  Copyright (c) 2008 633k.net. All rights reserved.
#

class ArtistsController < NSArrayController
  ib_outlets :artistsTable, :playlistsController, :queryStatus
  ib_action :loadPlaylist
  
  attr_accessor :artists
  attr_reader :tracks, :playlist
    
  def initialize
    @iTunes = SBApplication.applicationWithBundleIdentifier_("com.apple.iTunes")
    @artists = []
  end
  
  def loadPlaylist(sender)
    @queryStatus.startAnimation(sender)  
    @playlist = @iTunes.sources.first.userPlaylists.select { |p| p.name == @playlistsController.titleOfSelectedItem }
    @tracks = @playlist.first.tracks
    @artists = NSArray.alloc.initWithArray(@tracks.map { |t| Artist.new(t.artist, t.genre).full }.uniq)
    @artistsTable.reloadData
    @queryStatus.stopAnimation(sender)
  end
  
  def updateGenre(genre)
    @artists[@artistsTable.selectedRow][1] = genre
    @artistsTable.reloadData
  end

  def numberOfRowsInTableView(sender)
    @artists.length
  end
  
  def tableView_objectValueForTableColumn_row(sender, col, row)
    if col == @artistsTable.tableColumns.to_a[0]
      @artists[row][0]
    else
      @artists[row][1]
    end
  end
end
