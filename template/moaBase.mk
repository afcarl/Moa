SHELL := /bin/bash
.PHONY: set show help check prereqs

#see if a local variable set is defined
-include moa.mk

moa_targets += check help show all clean_all prereqs
check_help = Check variable definition
show_help = show defined variables
help_help = This help!
all_help = Recursively run through all subdirectories (use make all \
	action=XXX to run "make XXX" recursively) 
prereqs_help = Check if all prerequisites are present


###########################################################################
#check prerequisites
prereqlist += moa_envsettings
.PHONY: prereqs
prereqs: $(prereqlist)

test:
	echo "hello"
	
#check if MOABASE is defined
moa_envsettings:
	@if env | grep -q MOABASE ; then true; else \
		echo "MOABASE is not defined :(" ; \
		false ;\
	fi

check: prereqs $(addprefix checkvar_, $(moa_must_define))
	@echo "Variable check: everything appears ok"
	
checkvar_%:
	@if [ "$(origin $(subst checkvar_,,$@))" == "undefined" ]; then \
		echo " *** Error $(subst checkvar_,,$@) is undefined" ;\
		exit -1; \
	fi

#wset: $(addprefix storeweka_, $(moa_must_define) $(moa_may_define))

#storeweka_%:
#	if [ "$(origin $(subst storeweka_,,$@))" == "command line" ]; then \
#		echo " *** Set Weka var $(subst storeweka_,,$@) to 'weka get $($(subst storeweka_,,$@))'" ;\
#		echo -n "$(subst storeweka_,,$@)=$$" >> moa.mk ;\
#		echo "(shell weka get $($(subst storeweka_,,$@)))" >> moa.mk ; \
#	fi

set: set_mode =
set: $(addprefix storevar_, $(moa_must_define) $(moa_may_define))

append: set_mode="+"
append: $(addprefix storevar_, $(moa_must_define) $(moa_may_define))

storevar_%:		 
	@if [ "$(origin $(subst storevar_,,$@))" == "command line" ]; then \
		echo " *** Set $(subst storevar_,,$@) to $($(subst storevar_,,$@))" ;\
		echo "$(subst storevar_,,$@)$(set_mode)=$(set_mode)$($(subst storevar_,,$@))" >> moa.mk ;\
	fi
	@if [ "$(origin weka_$(subst storevar_,,$@))" == "command line" ]; then \
		echo " *** Set $(subst storevar_,,$@) to \"weka get $(weka_$(subst storevar_,,$@))\"" ;\
		echo -n "$(subst storevar_,,$@)$(set_mode)=$$" >> moa.mk ;\
		echo "(shell weka get $(weka_$(subst storevar_,,$@)))" >> moa.mk ; \
	fi
		
show: $(addprefix showvar_, $(moa_must_define) $(moa_may_define))

showvar_%:		 
	@echo "$(subst showvar_,,$@) : $($(subst showvar_,,$@))"

#dir traversing
moa_followups ?= $(shell find . -maxdepth 1 -type d -regex "\..+" -exec basename '{}' \; | sort )

.PHONY: $(moa_followups) all clean_all

all_check:
	@echo "would run make $(action)"
	@echo "in the following dirs"
	@echo $(moa_followups)
	
action ?= all
all: $(moa_followups)
	if [ "$(action)" == "all" ]; then \
		echo "running all without action, also run default action" ;\
		$(MAKE) ;\
	fi
	@echo "follows" $(moa_followups)

$(moa_followups):
	@echo "  ###########################"
	@echo "  ## Executing make $(action)"
	@echo "  ##   in $@ " 
	@echo "  ###########################"
	if [ -e $@/Makefile ]; then \
		cd $@ && $(MAKE) $(action) ;\
	fi

###############################################################################
# Help structure
boldOn = \033[0;1m
boldOff = \033[0m
help: moa_help_header \
	moa_help_target_header moa_help_target moa_help_target_footer \
	moa_help_vars_header moa_help_vars moa_help_vars_footer \
	moa_help_output_header moa_help_output moa_help_output_footer
	
moa_help_header:
	@echo -n "=="
	@echo -n "$(moa_title)" | sed "s/./=/g"
	@echo "=="
	@echo -e "= $(boldOn)$(moa_title)$(boldOff) ="
	@echo -n "=="
	@echo -n "$(moa_title)" | sed "s/./=/g"
	@echo "=="
	@echo "$(moa_description)" | fold -s
	@echo

## Help - output section
moa_help_output_header:
	@echo -e "$(boldOn)Outputs$(boldOff)"
	@echo "======="

moa_help_output: $(addprefix moa_output_, $(moa_outputs))

moa_output_%:	
	@if [ "$(origin $@_help)" == "undefined" ]; then \
		echo -en " - $(boldOn)$($@)$(boldOff)" ;\
	else \
		echo -en "- $(boldOn)$($@)$(boldOff): $($(subst helpvar_,,$@)_help)" \
			 |fold -w 60 -s |sed '2,$$s/^/     /' ;\
	fi
	
	
moa_help_output_footer:
	@echo 
	
## Help - target section
moa_help_target_header:
	@echo -e "$(boldOn)Targets$(boldOff)"
	@echo "======="

moa_help_target: $(addprefix moa_target_, $(moa_targets))
	
	
moa_target_%:
	@if [ "$(origin $(subst moa_target_,,$@)_help)" == "undefined" ]; then \
		echo -e " - $(boldOn)$(subst moa_target_,,$@)$(boldOff)" ;\
	else \
		echo -e " - $(boldOn)$(subst moa_target_,,$@)$(boldOff): $($(subst moa_target_,,$@)_help)" \
			| fold -w 60 -s |sed '2,$$s/^/     /' ;\
	fi
	
	
moa_help_target_footer:
	@echo 

## Help - variable section
moa_help_vars_header:
	@echo -e "$(boldOn)Variables$(boldOff)"
	@echo "========="
	
moa_help_vars_footer:
	@echo -e "*these variables $(boldOn)must$(boldOff) be defined"
	@echo 
	
moa_help_vars: moa_help_vars_must moa_help_vars_may

moa_help_vars_must: help_prefix="*"
moa_help_vars_must: $(addprefix helpvar_, $(moa_must_define))

moa_help_vars_may: help_prefix=""
moa_help_vars_may: $(addprefix helpvar_, $(moa_may_define))

helpvar_%:	
	@if [ "$(origin $(subst helpvar_,,$@)_help)" == "undefined" ]; then \
		@echo -en " - $(boldOn)$(help_prefix)$(subst helpvar_,,$@)$(boldOff)" ;\
	else \
		echo -e " - $(boldOn)$(help_prefix)$(subst helpvar_,,$@)$(boldOff): $($(subst helpvar_,,$@)_help)" \
			| fold -w 60 -s | sed '2,$$s/^/     /' ;\
	fi
		
		