#!/usr/bin/perl -w
#
# rss-view.pl - Redland RSS 1.0 test program
#
# $Id$
#
# Copyright (C) 2000 David Beckett - http://purl.org/net/dajobe/
# Institute for Learning and Research Technology, University of Bristol.
#
#    This package is Free Software available under either of two licenses
#    (see FAQS.html to see why):
# 
# 1. The GNU Lesser General Public License (LGPL)
# 
#    See http://www.gnu.org/copyleft/lesser.html or COPYING.LIB for the
#    full license text.
#      _________________________________________________________________
# 
#      Copyright (C) 2000 David Beckett, Institute for Learning and
#      Research Technology, University of Bristol. All Rights Reserved.
# 
#      This library is free software; you can redistribute it and/or
#      modify it under the terms of the GNU Lesser General Public License
#      as published by the Free Software Foundation; either version 2 of
#      the License, or (at your option) any later version.
# 
#      This library is distributed in the hope that it will be useful, but
#      WITHOUT ANY WARRANTY; without even the implied warranty of
#      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
#      Lesser General Public License for more details.
# 
#      You should have received a copy of the GNU Lesser General Public
#      License along with this library; if not, write to the Free Software
#      Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
#      USA
#      _________________________________________________________________
# 
#    NOTE - under Term 3 of the LGPL, you may choose to license the entire
#    library under the GPL. See COPYING for the full license text.
# 
# 2. The Mozilla Public License
# 
#    See http://www.mozilla.org/MPL/MPL-1.1.html or MPL.html for the full
#    license text.
# 
#    Under MPL section 13. I declare that all of the Covered Code is
#    Multiple Licensed:
#      _________________________________________________________________
# 
#      The contents of this file are subject to the Mozilla Public License
#      version 1.1 (the "License"); you may not use this file except in
#      compliance with the License. You may obtain a copy of the License
#      at http://www.mozilla.org/MPL/
# 
#      Software distributed under the License is distributed on an "AS IS"
#      basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
#      the License for the specific language governing rights and
#      limitations under the License.
# 
#      The Initial Developer of the Original Code is David Beckett.
#      Portions created by David Beckett are Copyright (C) 2000 David
#      Beckett, Institute for Learning and Research Technology, University
#      of Bristol. All Rights Reserved.
# 
#      Alternatively, the contents of this file may be used under the
#      terms of the GNU Lesser General Public License, in which case the
#      provisions of the LGPL License are applicable instead of those
#      above. If you wish to allow use of your version of this file only
#      under the terms of the LGPL License and not to allow others to use
#      your version of this file under the MPL, indicate your decision by
#      deleting the provisions above and replace them with the notice and
#      other provisions required by the LGPL License. If you do not delete
#      the provisions above, a recipient may use your version of this file
#      under either the MPL or the LGPL License.
#

use strict;

use RDF;
use RDF::RSS;

die <<"EOT" if @ARGV < 1 || @ARGV > 2;
Usage: $0 <RSS URI> [BASE URI>]

This program excercises the Redland Perl RDF:RSS module which supports
the RSS 1.0 specification, Release Candidate 1
http://www.egroups.com/files/rss-dev/RC1/specification.html

Further information on this format can be found at the RSS-Dev list
page at http://www.egroups.com/group/rss-dev
EOT

my $uri=$ARGV[0];

my $tmp_file;
my $source_uri;
if($uri !~ m%^file:%) {
  use URI::URL;
  use LWP::Simple;
  
  $tmp_file="/tmp/$0-$$.rss";

  my $perl_uri;
  eval "\$perl_uri=new URI::URL('$uri')";
  if($@) {
    die "$0: URI $uri is not supported by Perl\n";
  }
  my $rc=getstore($perl_uri, $tmp_file);
  
  if(!is_success($rc)) {
    die "$0: Failed to fetch URI $uri - HTTP error $rc\n";
    unlink $tmp_file;
  }
  $source_uri="file:$tmp_file";
} else {
  $source_uri=$uri;
}
my $base_uri=$uri;
$base_uri=$ARGV[1] if @ARGV ==2;


my $rss=new RDF::RSS($source_uri, $base_uri);
die "Failed to create RDF::RSS for URI $uri\n" unless $rss;

for my $channel ($rss->channels) {
  print "Found channel with URI ",$channel->uri->as_string,"\n";
  print "  title is ",$channel->title->as_string,"\n";
  print "  link is ",$channel->link->as_string,"\n";
  print "  desc is ",$channel->description->as_string,"\n" if $channel->description;

  my(@items)=$channel->items;
  print "  Found ",scalar(@items)," items in channel\n";

  for my $item (@items) {
    print "  Item with URI ",$item->uri->as_string,"\n";
    print "    title is ",$item->title->as_string,"\n";
    print "    link is ",$item->link->as_string,"\n";
    # RSS 1.0 section 5.5 <item> - description is optional
    print "    desc is ",$item->description->as_string,"\n" if $item->description;
  }

  my $image=$channel->image;
  if($image) {
    print "  Image with URI ",$image->uri->as_string,"\n";
    
    # RSS 1.0 section 5.4 <image> - If present, nothing optional
    print "    title is ",$image->title->as_string,"\n";
    print "    link is ",$image->link->as_string,"\n";
    print "    url is ",$image->url->as_string,"\n" if $image->url;
  }

  my $textinput=$channel->textinput;
  if($textinput) {
    print "  Textinput with URI ",$textinput->uri->as_string,"\n";

    # RSS 1.0 section 5.6 <textinput> - If present, nothing optional
    print "    title is ",$textinput->title->as_string,"\n";
    print "    link is ",$textinput->link->as_string,"\n";
    print "    desc is ",$textinput->description->as_string,"\n";
    print "    name is ",$textinput->name->as_string,"\n";
  }

}

unlink $tmp_file if $tmp_file;