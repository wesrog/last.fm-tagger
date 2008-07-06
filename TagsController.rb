#
#  TagsArray.rb
#  last.fm-tagger2
#
#  Created by Wes Rogers on 7/5/08.
#  Copyright (c) 2008 633k.net. All rights reserved.
#

require 'open-uri'
require 'rexml/document'

include REXML

class TagsController < NSArrayController
  ib_outlets :tagsTable, :artistsController, :artistsTable, :queryStatus, :tagStatus
  ib_action :tag

  def initialize
    #@tags = NSArray.alloc.init
    @tags = []
  end
  
  def awakeFromNib
    @tagStatus.setUsesThreadedAnimation(true)
  end

  def tag(sender)
    case NSRunAlertPanel("Confirm", "Are you sure you want to overwrite this tag? It is irreversable, unless you remember it :P", 'OK', 'Cancel', nil)
      when NSAlertDefaultReturn
        tracks = @artistsController.tracks.select { |tr| tr.artist.downcase == @artistsController.artists[@artistsTable.selectedRow][0].downcase }.sort_by { |tra| tra.trackNumber }
        @tagStatus.setMaxValue(tracks.length)
        NSLog("found #{tracks.length} tracks to tag")
        tracks.each do |t|
          unless t.artist != @artistsController.artists[@artistsTable.selectedRow][0]
            NSLog("#{t.artist} = #{t.genre} = #{@tags[@tagsTable.selectedRow][0]}")
            t.genre = @tags[@tagsTable.selectedRow][0]
            @tagStatus.incrementBy(1)
            @tagStatus.displayIfNeeded
          else
            NSLog("trying to update wrong artist!")
          end
        end
        @tagStatus.incrementBy(tracks.length * -1) # reset progress indicator
        #@artistsController.updateGenre(@tags[@tagsTable.selectedRow][0])
        #@artistsController.loadPlaylist(sender)
      when NSAlertAlternateReturn
        return
    end
    #NSReleaseAlertPanel
  end

  def tableViewSelectionDidChange(note)
    #@tags.release # free memory
    #@tags = NSMutableArray.alloc.init
    @tags.clear
    @queryStatus.startAnimation(note)
    url = "http://ws.audioscrobbler.com/1.0/artist/#{Artist.new(@artistsController.artists[@artistsTable.selectedRow][0], nil).name.to_s}/toptags.xml"
    puts url.to_s
    doc = Document.new(open(url.to_s))
    doc.root.elements.to_a("//tag").each do |tag|
      @tags << [tag.elements.to_a("name")[0].text, tag.elements.to_a("count")[0].text]
    end
    alert_no_tags_found if @tags.empty?
    #NSReleaseAlertPanel
    @queryStatus.stopAnimation(note)
    @tagsTable.reloadData
  rescue OpenURI::HTTPError
    NSLog "404!"
    alert_no_tags_found
    @queryStatus.stopAnimation(note)
    #@tags.release # free memory
    #@tags = NSMutableArray.alloc.init
    @tags.clear
  end
  
  def numberOfRowsInTableView(sender)
    @tags.length
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
