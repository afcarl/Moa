#!/usr/bin/env python
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
"""
Moa script - template related code
"""

import os
import moa.utils.logger
l = moa.utils.logger.l
    
def _check(what):
    """Check if a template exists"""
    templatefile = os.path.join(TEMPLATEDIR, what + '.mk')
    if not os.path.exists(templatefile):
        l.debug("cannot find %s" % templatefile)
        l.error("No template for %s exists" % what)
        sys.exit(1)        
    return True

def list():
    """
    List all known templates
    """
    r = []
    for f in os.listdir(TEMPLATEDIR):
        if f[0] == '.': continue
        if f[0] == '_': continue
        if f[0] == '#': continue
        if f[-1] == '~': continue
        if f == 'gsml': continue
        if not '.mk' in f: continue
        r.append(f.replace('.mk', ''))
    r.sort()
    for r1 in r: print r1
        
def new(what, jid=None):
    """
    Create a new template based makefile in the current dir.
    """
    if os.path.exists("./Makefile"):
        l.debug("Makefile exists!")
        if not options.force:
            l.critical("makefile exists, use force to overwrite")
            sys.exit(1)

    for t in what:
        checkTemplate(t)

    l.debug("Start writing ./Makefile") 
    F = open("./Makefile", 'w')
    F.write("#Moa autogenerated Makefile\n")
    F.write("-include moa.mk\n")
    F.write("MOAMK_INCLUDE=done")
    F.write("\n\n")
    F.write("#Execute these commands first\n")
    F.write("moa_preprocess:\n")
    F.write("\t@echo preprocess commands go here\n\n\n")
    F.write("#Execute these commands last\n")
    F.write("moa_postprocess:\n")
    F.write("\t@echo Postprocess commands go here..\n\n\n")

    F.write("dont_include_moabase=please\n\n")
    
    for t in what:
        F.write("include $(shell echo $$MOABASE)/template/%s.mk\n" % t)

    F.write("include $(shell echo $$MOABASE)/template/__moaBase.mk\n")
    F.close()

    if jid:
        if os.path.exists('moa.mk'):
            moamk = open('moa.mk').readlines()
        else:
            moamk = []
            
        F = open('moa.mk', 'w')
        for line in moamk:
            if not re.match("^jid *="):
                F.write(line)
        F.write("\n")
        F.write("jid=%s" % jid)
        F.close()
        l.debug("Written jid=%s to moa.mk" % jid)
    
    l.info("Written Makefile, try: make help")

