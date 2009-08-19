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
# upload to gbrowse, only used as an extension to an analysis
# i.e. should be included by another makefile
# 
# The embedding makefile should define what needs to be 
# uploaded, i.e. a list of fasta / gff files
# this goes in the variale gbrowse_upload_files
#
moa_title = Library for uploading data to GBrowse
moa_description = A library that aids in uploading FASTA and GFF		\
  to a Generic Genome Browser database. This template is only to be		\
  used embedded in another template. This library expects that the		\
  following variables are preset; gup_fasta_dir, gup_gff_dir, gffsource	\
  gup_upload_fasta, gup_upload_gff

moa_ids += upload2gbrowse
moa_upload2gbrowse_help = Upload to gbrowse

moa_additional_targets += initGbrowse gupLock gupUnlock
moa_initGbrowse_help = Clean & initalize a gbrowse database. 			\
	**Warning: all data will be lost!**
moa_gupLock_help = Prevent this job from uploading anything to the 		\
	Generic Genome Browser database
moa_gupUnlock_help = Allow this job to upload to the Generic Genome		\
	Browser database

moa_must_define += gup_user gup_db gup_gffsource
gup_user_help = gbrowse db user. If not defined, this defaults to 'moa'.
gup_db_help = gbrowse database. If not defined, this defaults to 'moa'.
gup_gffsource_help = the gff source field, used in batch operations

moa_may_define += gup_gff_extension gup_fasta_extension
gup_fasta_extension_help = extension of the FASTA files to upload (.fasta)
gup_gff_extension_help = extension of the GFF files to upload (.gff)

moa_may_define += marks_extensions
marks_extensions_help = Add some extensions to the Gbrowse database to \
  be initalized, for use by Mark.

include $(shell echo $$MOABASE)/template/moaBase.mk

gup_gff_extension ?= gff
gup_fasta_extension ?= fasta

gup_gff_dir ?= ./gff
gup_fasta_dir ?= ./fasta

#Per default we're not uploading. you really need to set this.
gup_upload_fasta ?= F
gup_upload_gff ?= F

marks_extensions ?= F

#see if this job is locked from uploading
gup_locked = $(shell if [ -f ./gup_lock ]; then echo "T"; else echo "F"; fi)

#This is a safe way to only expand


$(warning phase $(gup_phase_two) locked $(gup_locked) upload_gff $(gup_upload_gff))
ifeq "$(gup_phase_two)" "T"
ifneq "$(gup_locked)" "T"
ifeq "$(gup_upload_gff)" "T"
$(warning Reading Gff)
gup_input_gff := $(wildcard $(gup_gff_dir)/*.$(gup_gff_extension))
endif
endif
endif

ifeq "$(gup_phase_two)" "T"
ifneq "$(gup_locked)" "T"
ifeq "$(gup_upload_fasta)" "T"
$(warning Reading Fasta)
gup_input_gff := $(wildcard $(gup_fasta_dir)/*.$(gup_fasta_extension))
endif
endif
endif

# function to delete the results of one, a few and all input files
# if sticking to a few rules this should work for most analyses.
gup_delete_single ?= bp_seqfeature_delete.pl -d $(gup_db) \
  -u $(gup_user) -n $(gup_gffsource)_`basename $< .gff`

#delete a few files (file list in $?)
gup_delete_few ?= bp_seqfeature_delete.pl -d $(gup_db) 				\
	-u $(gup_user)													\
	-n $(addsuffix *\",												\
		$(addprefix \"$(gup_gffsource)_, 								\
			$(shell 												\
				for f in $(cs); 									\
					do basename $$f .$(gup_gff_extension); 			\
				done ) 												\
			) 														\
		)

#delete all: Note, this will probably not work, the current version 
# of bp_seqfeature_delete.pl seems to be broken
gup_delete_all ?= bp_seqfeature_delete.pl -d $(gup_db) 				\
						-u $(gup_user) -n $(gup_gffsource)_*

# the default upload target runs make upload. This is to make sure
# that possible files created by the rest of this makefile are read
# correctly. I'm under the impression that this should be possible by
# secondary expanssion. but could not get this to work properly. If
# anybody has a bright idea.. please.

.PHONY: upload2gbrowse_prepare
upload2gbrowse_prepare: 

.PHONY: upload2gbrowse
upload2gbrowse:
	@echo "new instance of make -> make sure that all created"
	@echo "files are actually recognized"
	if [ $(gup_locked) != "T" ]; then 						\
		$(MAKE) upload2gbrowse2  gup_phase_two=T; 		\
	else 													\
		$(call echo,No upload to Gbrowse: GUP-LOCKED!);		\
	fi
	echo "End of make upload2gbrowse2"


.PHONY: upload2gbrowse_post
upload2gbrowse_post: 

test: test_fasta test_gff

test_fasta: $(gup_input_fasta)
	@echo "identified $(words $(gup_input_fasta)) fasta files"
	@echo "of which $(words $?) are scheduled to be uploaded"

test_gff: $(gup_input_gff)
	@echo "identified $(words $(gup_input_gff)) fasta files"
	@echo "of which $(words $?) are scheduled to be uploaded"

# Lock / unlock this job from uploading to/from the database
.PHONY: gupLock
gupLock:
	touch gup_lock
.PHONY: gupUnlock
gupUnlock:
	rm gup_lock


## Do the actual upload
.PHONY: upload2gbrowse2
upload2gbrowse2: upload_fasta upload_gff
	@echo "finished with upload to gbrowse" 

upload_fasta: $(gup_input_fasta)
	@# $(foreach st, $(shell seq 1 500 $(words $?)), 				\
	    $(eval cs=$(wordlist $(st),									\
						$(shell echo $$(( $(st) + 999 )) ),			\
						$?))										\
		$(shell bp_seqfeature_load.pl -d $(gup_db) -u $(gup_user) 	\
							-f $(cs))								\
	)

upload_gff: $(gup_input_gff)
	@# $(foreach st, $(shell seq 1 500 $(words $?)), 				\
	    $(eval cs=$(wordlist $(st),									\
						$(shell echo $$(( $(st) + 999 )) ),			\
						$?))										\
		$(shell $(gup_delete_few)); 								\
		$(shell bp_seqfeature_load.pl -d $(gup_db) -u $(gup_user) 	\
							-f $(cs))								\
	)

.PHONY: upload2gbrowse_clean
upload2gbrowse_clean: $(gup_input_gff)
	@echo "executing upload2gbrowse_clean" 
	$(gup_delete_all)
	-rm upload_gff
	-rm upload_fasta


##
## initGbrowse functionality
##


initGbrowse: mark_add_1 = 									\
	ALTER TABLE $(gup_db).name								\
	ADD COLUMN `pid` int(10) NOT NULL AUTO_INCREMENT,		\
	ADD PRIMARY KEY (`pid`)

initGbrowse: mark_add_2 =									\
	ALTER TABLE $(gup_db).attribute 						\
	ADD COLUMN `pid` int(10) NOT NULL AUTO_INCREMENT, 		\
	ADD PRIMARY KEY (`pid`)

initGbrowse: mark_add_3 = 									\
	ALTER TABLE $(gup_db).parent2child						\
	ADD COLUMN `pid` int(10) NOT NULL AUTO_INCREMENT, 		\
	ADD PRIMARY KEY (`pid`)

initGbrowse:
	bp_seqfeature_load.pl -d $(gup_db) -u $(gup_user) -c
	if [ "$(marks_extensions)" == "T" ]; then 				\
		mysql -u$(gup_user) -e '$(mark_add_1)';				\
		mysql -u$(gup_user) -e '$(mark_add_2)';				\
		mysql -u$(gup_user) -e '$(mark_add_3)';				\
	fi
	touch lock



