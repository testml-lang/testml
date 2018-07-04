include ../../.makefile/test-tap.mk

default: help

test: test-tap


#------------------------------------------------------------------------------
# TODO Packaging stuff:
#------------------------------------------------------------------------------
# publish: dist
# 
# dist: distdir
# 
# distdir: pkg
# 
# pkg:
# 	git branch --track $<-perl5 origin/$<-perl5 2>/dev/null || true
# 	git worktree add -f $@ $<-perl5
