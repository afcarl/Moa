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
moa_ids += blastdb
moa_title_blastdb = Create a BLAST database 
moa_blastdb_help = Takes either a set of fasta files or a single	\
  multi-fasta input file and creates a BLAST database.

moa_must_define += bdb_name
bdb_name_help = Database name to create.

moa_may_define += bdb_input_dir bdb_input_extension bdb_fasta_file
bdb_input_dir_help = Dir with the input fasta files, defaults to ./fasta
bdb_input_dir_default_attrib = fastadir
bdb_input_extension_help = extension of the input sequence files, defaults to fasta
bdb_fasta_file_help = The file with all FASTA sequences for the blastdb		\
  concatenated. This can be used as an alternative to defining			\
  "bdb_input_dir" and "bdb_input_dir_extension". Morover. If all your	\
  sequences are already in a single file, then using this parameter		\
  prevents duplication of that file.

#Variable: protein
moa_may_define += bdb_protein 
bdb_protein_help = Protein database? (T)rue) or not (F)alse (default: F)

#Include base moa code - does variable checks & generates help
include $(shell echo $$MOABASE)/template/moaBase.mk

# End of the generic part - from here on you're on your own :)

bdb_input_dir ?= ./fasta
bdb_input_extension ?= fasta

bdb_doconcat = F
ifndef $(bdb_fasta_file)
  bdb_doconcat = T
  bdb_fasta_file ?= $(bdb_name).fasta
  input_files ?= $(wildcard $(bdb_input_dir)/*.$(bdb_input_extension))
else
  bdb_doconcat = F
endif

moa_register_extra += blastdb fastafile idlist
moa_register_blastdb = $(shell echo `pwd`/$(bdb_name))
moa_register_fastafile = $(bdb_fasta_file)
moa_register_idlist = $(shell echo `pwd`/$(bdb_name).list)

#the rest of the variable definitions 
bdb_protein ?= F

ifeq ("$(bdb_protein)", "F")
	one_blast_db_file = $(bdb_name).nhr
else
	one_blast_db_file = $(bdb_name).phr
endif

.PHONY: blastdb_prepare
blastdb_prepare:

.PHONY: blastdb_post
blastdb_post: create_id_list

.PHONY: blastdb
blastdb: $(one_blast_db_file)

$(one_blast_db_file): $(bdb_fasta_file)
	@echo "Creating $@"
	formatdb -i $< -p $(bdb_protein) -o T -n $(bdb_name)

$(bdb_fasta_file): $(input_files)
	if [[ "$(bdb_doconcat)" == "T" ]]; then 			\
		find $(bdb_input_dir) -type f 					\
	 		-name "*.$(bdb_input_extension)" 			\
			| xargs -n 100 cat 							\
			> $(bdb_fasta_file);						\
		fi

.PHONY: create_id_list
create_id_list: $(bdb_name).list

$(bdb_name).list: $(bdb_fasta_file)
	grep ">" $(bdb_fasta_file) | cut -c2- | sed 's/ /\t/' | sort > $(bdb_name).list

blastdb_clean:	
	-if [ $(bdb_protein) == "F" ]; then \
		rm $(bdb_name).n?? ;\
	else \
		rm $(bdb_name).p?? ;\
	fi
	-rm $(fasta_file)
	-rm $(bdb_name).list
	-rm formatdb.log
