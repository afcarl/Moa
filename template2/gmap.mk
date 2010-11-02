# 
# Copyright 2009 Mark Fiers, Plant & Food Research
# 
# This file is part of Moa - http://github.com/mfiers/Moa
# 
# Moa is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your
# option) any later version.
# 
# Moa is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
# License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with Moa.  If not, see <http://www.gnu.org/licenses/>.
# 
moa_id = gmap

template_title = Gmap
template_description = Run GMAP on an set of input files (query) \
  vs a database index.

$(call moa_fileset_define,gmap_input,fasta,Sequences to map)

#variables
moa_must_define += gmap_db
gmap_db_help = Gmap db
gmap_db_type = file

moa_may_define += gmap_extra_parameters
gmap_extra_parameters_default = 
gmap_extra_parameters_help = extra parameters to feed to gmap
gmap_extra_parameters_type = string

moa_may_define += gmap_invert_gff
gmap_invert_gff_default = T
gmap_invert_gff_help = Invert the GFF (T/*F*)
gmap_invert_gff_type = set
gmap_invert_gff_allowed = T F

moa_may_define += gmap_gff_source
gmap_gff_source_default = gmap
gmap_gff_source_help = Source field to use in the output GFF
gmap_gff_source_type = string

include $(MOABASE)/template/moa/core.mk

$(call moa_fileset_remap_nodir,gmap_input,gmap_raw,raw)
$(call moa_fileset_remap_nodir,gmap_input,gmap_gff,gff)
$(call moa_fileset_remap_nodir,gmap_input,gmap_genepred,genepred)
ifeq ($(gmap_invert_gff),T)
$(call moa_fileset_remap_nodir,gmap_input,gmap_gff_invert,invert.gff)
endif

gmap_output_raw = $(call moa_fileset_remap,gmap_input,gmap_raw,raw)

.PHONY: gmap
gmap: gmap_message $(gmap_raw_files) $(gmap_gff_files) $(gmap_gff_invert_files) $(gmap_genepred_files) gmap_report

.PHONY: gmap_message
gmap_message:
	$e echo "input files" $(gmap_input_files)
	$e echo "raw files" $(gmap_raw_files)

gmap_report: $(gmap_gff_invert_files)
	$e echo -n "No input sequences " > gmap_report
	$e grep ">" $(gmap_input_files) | wc -l >> gmap_report
	$e echo -n "No files with a hit " >> gmap_report
	$e cat $(gmap_gff_invert_files) | cut -f 1 | grep -v '#' | sort | uniq | wc -l >> gmap_report

$(gmap_gff_files): gmap_dbname=$(shell basename $(gmap_db))
$(gmap_gff_files): %.gff: %.raw
	cat $< \
		| sed "s/$(gmap_dbname)/$(gmap_gff_source)/" \
		| sed "s/cDNA_match/match/" \
		| sed "s/^\([^\t]*\)\(.*\)ID=\([^;]*\).path\([0-9]\+\);Name=\([^;]*\)\(.*\)/\1\2ID=gmap__\1__\3__\4;Name=gmap__\1__\3__\4\6/" \
		| sed "s/Target=/Target=Sequence:/" \
		> $@

$(gmap_gff_invert_files): %.invert.gff: %.gff
	invertGff $< > $@

$(gmap_genepred_files): %.genepred: %.raw
	gmapgff2genepred $< > $@

#output.raw: $(gmap_input_file)
$(gmap_raw_files): %.raw: $(gmap_input_dir)/%.$(gmap_input_extension)
	gmap -D $(shell dirname $(gmap_db)) \
		 -d $(shell basename $(gmap_db)) \
		 $(gmap_extra_parameters) \
		 -A $< -F -f 3 > $@
	gmap -D $(shell dirname $(gmap_db)) \
		 -d $(shell basename $(gmap_db)) \
		 $(gmap_extra_parameters) \
		 $< -A -F -i 10 > output.align

gmap_clean:
	-rm -f output.gff
	-rm -f output.raw

