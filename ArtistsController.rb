#
#  ArtistsArray.rb
#  last.fm-tagger
#
#  Created by Wes Rogers on 7/5/08.
#  Copyright (c) 2008 633k.net. All rights reserved.
#

class ArtistsController < NSArrayController
  ib_outlets :artistsTable, :playlistsController, :queryStatus
  ib_action :loadPlaylist
  ib_action :reloadPlaylistData
  
  attr_accessor :artists
  attr_reader :tracks, :playlist
    
  def initialize
    @iTunes = SBApplication.applicationWithBundleIdentifier_("com.apple.iTunes")
    @artists = NSArray.alloc.init
  end
  
  def loadPlaylist(sender)
    @queryStatus.startAnimation(sender)  
    @playlist = @iTunes.sources.first.userPlaylists.select { |p| p.name == @playlistsController.titleOfSelectedItem }
    if @playlist.first.smart == 1
      NSRunCriticalAlertPanel("Invalid Playlist", "You are trying to load a smart playlist, please choose another one.", 'OK', nil, nil)
    elsif @playlist.first.tracks.count > 2500
      NSRunCriticalAlertPanel("Playlist Too Large", "You are trying to load a playlist with over 2500 tracks. Please remove some tracks or select another playlist.", 'OK', nil, nil)
    else
      @tracks = @playlist.first.tracks
      @artists = NSArray.alloc.initWithArray(@tracks.map { |t| Artist.new(t.artist, t.genre).full }.uniq)
      @artistsTable.reloadData
    end
    @queryStatus.stopAnimation(sender)
  end
  
  def reloadPlaylistData(sender)
    loadPlaylist(sender)
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
