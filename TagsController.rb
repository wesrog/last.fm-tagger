#
#  TagsArray.rb
#  last.fm-tagger
#
#  Created by Wes Rogers on 7/5/08.
#  Copyright (c) 2008 633k.net. All rights reserved.
#

require 'open-uri'
require 'rexml/document'

include REXML

class TagsController < NSArrayController
  ib_outlets :tagsTable, :artistsController, :artistsTable, :queryStatus, :tagStatus, :statusLabel, :taggedTracksCountLabel
  ib_action :tag

  def initialize
    #@tags = NSArray.alloc.init
    #@tags = []
  end
  
  def tag(sender)
    tracks_length = @tracks.length
    case NSRunAlertPanel("Confirm", "Are you sure you want to overwrite this tag for #{tracks_length} tracks?", 'OK', 'Cancel', nil)
      when NSAlertDefaultReturn
        @tagStatus.setMaxValue(tracks_length)
        NSLog("found #{tracks_length} tracks to tag")
        @tracks.each_with_index do |t, i|
          NSLog("#{t.artist} - #{t.genre} = #{@tags[@tagsTable.selectedRow][0]}")
          @statusLabel.setStringValue("Status: writing \"#{t.name}\"")
          @statusLabel.displayIfNeeded
          @taggedTracksCountLabel.setStringValue("#{i+1}/#{tracks_length}")
          @taggedTracksCountLabel.displayIfNeeded
          t.genre = @tags[@tagsTable.selectedRow][0]
          @tagStatus.incrementBy(1)
          @tagStatus.displayIfNeeded
        end
        @statusLabel.setStringValue('Done!')
        #tracks.dealloc()
        @tagStatus.incrementBy(tracks_length * -1) # reset progress indicator
        @artistsController.updateGenre(@tags[@tagsTable.selectedRow][0])
        #@artistsController.loadPlaylist(sender)
      when NSAlertAlternateReturn
        return
    end
    #NSReleaseAlertPanel
  end

  def tableViewSelectionDidChange(note)
    @selected_artist = @artistsController.artists[@artistsTable.selectedRow][0]
    @queryStatus.startAnimation(note)
    url = "http://ws.audioscrobbler.com/1.0/artist/#{Artist.new(@selected_artist, nil).name.to_s}/toptags.xml"
    NSLog("Querying: #{url}")
    NSLog("Building track list for artist...")
    @tracks = @artistsController.tracks.select { |tr| tr.artist.to_s.strip.downcase == @selected_artist.to_s.strip.downcase }    
    doc = Document.new(open(url.to_s))
    @tags = NSMutableArray.alloc.init
    doc.root.elements.to_a("//tag").each do |tag|
      @tags.addObject(NSArray.arrayWithObjects(tag.elements.to_a("name")[0].text.to_s, tag.elements.to_a("count")[0].text.to_s, nil))
    end
    alert_no_tags_found if @tags.empty?
    #NSReleaseAlertPanel
    @queryStatus.stopAnimation(note)
    @tagsTable.reloadData
  rescue OpenURI::HTTPError
    NSLog "404!"
    alert_no_tags_found
    @queryStatus.stopAnimation(note)
  end
  
  def numberOfRowsInTableView(sender)
    @tags.length if @tags
  end

  def tableView_objectValueForTableColumn_row(sender, col, row)
    if col == @tagsTable.tableColumns.to_a[0]
      @tags[row][0]
    else
      @tags[row][1]
    end
  end
  
  private
  
  def alert_no_tags_found
    NSRunAlertPanel("Sorry!", "No tags found :(", 'OK', nil, nil)
  end
end
