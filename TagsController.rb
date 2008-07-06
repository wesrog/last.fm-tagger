#
#  TagsArray.rb
#  last.fm-tagger2
#
#  Created by Wes Rogers on 7/5/08.
#  Copyright (c) 2008 633k.net. All rights reserved.
#

require 'cgi'
require 'open-uri'
require 'rexml/document'
require 'net/http'

include REXML

class TagsController < NSArrayController
  ib_outlets :tagsTable, :artistsController, :artistsTable, :queryStatus, :tagStatus
  ib_action :tag

  def initialize
    @tags = NSMutableArray.alloc.init
  end

  def tag(sender)
    tracks = @artistsController.tracks.select { |t| t.artist == @artistsController.artists[@artistsTable.selectedRow][0] }
    @tagStatus.setMaxValue(tracks.length)
    tracks.each do |t|
      t.genre = @tags[@tagsTable.selectedRow][0].to_s.downcase
      @tagStatus.incrementBy(1)
      @tagStatus.displayIfNeeded
    end
    @tagStatus.incrementBy(tracks.length * -1)
    @artistsController.updateGenre(@tags[@tagsTable.selectedRow][0])
    NSLog("#{@artistsController.artists[@artistsTable.selectedRow][0]} = #{@tags[@tagsTable.selectedRow][0]}")
  end

  def tableViewSelectionDidChange(note)
    @tags.release # free memory
    @tags = NSMutableArray.alloc.init
    track = @artistsController.artists[@artistsTable.selectedRow]
    @queryStatus.startAnimation(note)
    doc = Document.new(open("http://ws.audioscrobbler.com/1.0/artist/#{URI.escape(track[0])}/toptags.xml"))
    doc.root.elements.to_a("//tag").each do |tag|
      @tags << [tag.elements.to_a("name")[0].text, tag.elements.to_a("count")[0].text]
    end
    @tagsTable.reloadData
    @queryStatus.stopAnimation(note)
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
