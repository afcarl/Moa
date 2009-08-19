################################################################################
#
#    Copyright 2009 Mark Fiers
#
#    This file is part of Moa 
#
#    Moa is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Moa is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with Moa.  If not, see <http://www.gnu.org/licenses/>.
#
#    See: http://github.com/mfiers/Moa/
#
# Use the include

moa_title = Upload data to GBrowse
moa_description = This template takes GFF and FASTA files and uploads	\
   these to a Generic Genome Browser database.

moa_must_define += gup_gffsource
moa_may_define += gup_fasta_dir gup_gff_dir

gup_gffsource_help = gff "source" of the data to upload
gup_fasta_dir_help = input directory with fasta files to upload to gbrowse
gup_gff_dir_help = input directory with gff files to upload to gbrowse

moa_must_define += gup_upload_fasta gup_upload_gff
gup_upload_gff_help = Perform gff upload (T/F)
gup_upload_fasta_help = Perform fasta upload (T/F)

#The rest of the functionality is implemented here:
include $(shell echo $$MOABASE)/template/__upload2gbrowse.mk

