#
# Test code for Redland Tcl interface
#
# $Id$
#
# Copyright (C) 2001 David Beckett - http://purl.org/net/dajobe/
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


lappend auto_path .

package require redland

librdf_init_world "" NULL

set storage [librdf_new_storage "hashes" "test" {new='yes',hash-type='bdb',dir='.'}]
if {"$storage" == "NULL"} then {
  error "Failed to create RDF storage"
}

set model [librdf_new_model $storage ""]
if {"$model" == "NULL"} then {
  librdf_free_storage $storage
  error "Failed to create RDF model"
}


set statement [librdf_new_statement_from_nodes [librdf_new_node_from_uri_string "http://purl.org/net/dajobe/"] [librdf_new_node_from_uri_string "http://purl.org/dc/elements/1.1/creator"] [librdf_new_node_from_literal "Dave Beckett" "" 0 0]]
if {"$statement" == "NULL"} then {
  librdf_free_model $model
  librdf_free_storage $storage
  error "failed to create RDF statement"
}

librdf_model_add_statement $model $statement


# Match against an empty statement - find everything
set statement [librdf_new_statement_from_nodes NULL NULL NULL]

# after this statement should not be touched since find_statements is using it
set stream [librdf_model_find_statements $model $statement]

while {! [librdf_stream_end $stream]} {
  set statement2 [librdf_stream_next $stream]
  puts [concat "found statement:" [librdf_statement_to_string $statement2]]
}
librdf_free_stream $stream
librdf_free_statement $statement


librdf_free_model $model
librdf_free_storage $storage

librdf_destroy_world