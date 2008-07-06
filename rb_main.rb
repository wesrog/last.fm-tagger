#
#  rb_main.rb
#  last.fm-tagger2
#
#  Created by Wes Rogers on 7/5/08.
#  Copyright (c) 2008 633k.net. All rights reserved.
#

require 'osx/cocoa'

include OSX

require_framework 'ScriptingBridge'

def rb_main_init
  path = OSX::NSBundle.mainBundle.resourcePath.fileSystemRepresentation
  rbfiles = Dir.entries(path).select {|x| /\.rb\z/ =~ x}
  rbfiles -= [ File.basename(__FILE__) ]
  rbfiles.each do |path|
    require( File.basename(path) )
  end
end

if $0 == __FILE__ then
  rb_main_init
  OSX.NSApplicationMain(0, nil)
end
