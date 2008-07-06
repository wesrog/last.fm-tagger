#
#  Artist.rb
#  last.fm-tagger
#
#  Created by Wes Rogers on 7/5/08.
#  Copyright (c) 2008 __MyCompanyName__. All rights reserved.
#

require 'cgi'
require 'net/http'

class Artist

  def initialize(name, genre)
    @name, @genre = name, genre
  end
  
  def name
    URI.escape(CGI.escape(@name.to_s)).to_s
  end
  
  def genre
    genre
  end
  
  def full
    [@name, @genre]
  end
  
end
