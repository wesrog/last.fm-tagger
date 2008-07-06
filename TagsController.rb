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

  def tag(sender)
    case NSRunAlertPanel("Confirm", "Are you sure you want to overwrite this tag? It is irreversable, unless you remember it :P", 'OK', 'Cancel', nil)
      when NSAlertDefaultReturn
        tracks = @artistsController.tracks.select { |t| t.artist == @artistsController.artists[@artistsTable.selectedRow][0] }
        @tagStatus.setMaxValue(tracks.length)
        tracks.each do |t|
          NSLog("#{t.genre} = #{@tags[@tagsTable.selectedRow][0]}")
          t.genre = @tags[@tagsTable.selectedRow][0]
          @tagStatus.incrementBy(1)
          @tagStatus.displayIfNeeded
        end
        @tagStatus.incrementBy(tracks.length * -1)
        @artistsController.updateGenre(@tags[@tagsTable.selectedRow][0])
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
    NSRunAlertPanel("Sorry!", "No tags found :(", 'OK', nil, nil) if @tags.empty?
    #NSReleaseAlertPanel
    @queryStatus.stopAnimation(note)
    @tagsTable.reloadData
  rescue OpenURI::HTTPError
    NSLog "404!"
    NSRunAlertPanel("Sorry!", "No tags found :(", 'OK', nil, nil)
    @queryStatus.stopAnimation(note)
    #@tags.release # free memory
    #@tags = NSMutableArray.alloc.init
    @tags = []
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
end
