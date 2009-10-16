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
moa_main_target: check clean_fasta

################################################################################
# Definitions
# targets that the enduser might want to use
moa_targets += clean_fasta
clean_fasta_help = Cleanup of a FASTA file (in place!)

# Help
moa_ids += clean_fasta
moa_title_cleanfasta = clean Fasta
moa_description_cleanfasta = Convert files to unix format and convert all characters \
 that are not an A,C,G,T or N to N. 

# Output definition
moa_outputs += clean_fasta
moa_output_clean_fasta = ./fasta/*.fasta
moa_output_clean_fasta_help = Cleaned fasta files

#varables that NEED to be defined
moa_may_define += cf_input_dir
input_dir_help = list of directories with the input files

moa_may_define += cf_input_extension sed_command
input_extension_help = extension to the fasta files (default .fasta)
sed_command_help = The sed command cleaning the code, defaults to \
  '/^>/!s/[^ACGTNacgtn]/N/g'

#Include base moa code - does variable checks & generates help
include $(shell echo $$MOABASE)/template/moaBase.mk

################################################################################

cf_input_extension ?= fasta
cf_input_dir ?= ./fasta
sed_command ?= /^>/!s/[^ACGTNacgtn]/N/g

cf_output_files = $(wildcard $(cf_input_dir)/*.$(cf_input_extension))

.phony: clean_fasta_prepare
clean_fasta_prepare:
	-mkdir fasta		

.PHONY: clean_fasta
clean_fasta: 
	$(MAKE) clean_fasta_run

clean_fasta_run: $(addprefix cfs_, $(notdir $(cf_output_files)))
	@echo $(cf_output_files)
	#@echo $(cf_input_dir)/*.$(cf_input_extension)
	touch clean_fasta_run

cfs_%:
	cat $(cf_input_dir)/$* | sed '$(sed_command)' > $(cf_input_dir)/$*.tmp
	mv $(cf_input_dir)/$*.tmp $(cf_input_dir)/$*

.PHONY: clean_fasta_clean
clean_fasta_clean: