# Empty - use this to create a new makefile
################################################################################
# Main target
maintarget: not doing anything

################################################################################
# Help
moa_ids += empty
moa_title_empty = 
moa_description_empty = 

################################################################################
# Variable definition (non obligatory ones)

################################################################################
# Variable help definition

################################################################################
# moa definitions
#
#targets that the enduser might want to use
moa_targets += 
#varables that NEED to be defined
moa_must_define += 
#varaibles that might be defined
moa_may_define += 		
#Include base moa code - does variable checks & generates help
ifndef dont_include_moabase
	include $(shell echo $$MOABASE)/template/moaBase.mk
endif

################################################################################
# End of the generic part - from here on you're on your own :)
