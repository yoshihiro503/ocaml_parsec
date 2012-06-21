##########################
#                        #
# Sub repositories       #
#                        #
##########################

UTIL:=ocaml_util
SUBREPOSITORIES:=$(UTIL)

##########################
#                        #
# Libraries definitions. #
#                        #
##########################

OCAMLLIBS:=-I . -I $(UTIL)

##########################
#                        #
# Variables definitions. #
#                        #
##########################

CAMLLIB:=$(shell $(CAMLBIN)ocamlc.opt -where)
CAMLC:=$(CAMLBIN)ocamlc.opt -c
CAMLOPTC:=$(CAMLBIN)ocamlopt.opt -c
CAMLLINK:=$(CAMLBIN)ocamlc.opt
CAMLOPTLINK:=$(CAMLBIN)ocamlopt.opt

###################################
#                                 #
# Definition of the "all" target. #
#                                 #
###################################

MLFILES:= \
	parsec.ml
CMOFILES:=$(MLFILES:.ml=.cmo)
CMOFILES0:=$(filter-out ,$(CMOFILES))
CMIFILES:=$(MLFILES:.ml=.cmi)
CMIFILES0:=$(filter-out ,$(CMIFILES))
CMXFILES:=$(MLFILES:.ml=.cmx)
CMXSFILES:=$(MLFILES:.ml=.cmxs)
CMXSFILES0:=$(filter-out ,$(CMXSFILES))
OFILES:=$(MLFILES:.ml=.o)

all: $(SUBREPOSITORIES) $(CMOFILES) $(CMXSFILES) 

$(UTIL):
	cd $(UTIL); $(MAKE) all

####################
#                  #
# Special targets. #
#                  #
####################

.PHONY: all opt byte archclean clean install depend html $(SUBREPOSITORIES)

%.cmi: %.mli
	$(CAMLC) $(OCAMLLIBS) $(ZDEBUG) $(ZFLAGS) $<

%.cmo: %.ml
	$(CAMLC) $(OCAMLLIBS) $(ZDEBUG) $(ZFLAGS) $(PP) $<

%.cmx: %.ml
	$(CAMLOPTC) $(OCAMLLIBS) $(ZDEBUG) $(ZFLAGS) $(PP) $<

%.cmxs: %.ml
	$(CAMLOPTLINK) $(OCAMLLIBS) $(ZDEBUG) $(ZFLAGS) -shared -o $@ $(PP) $<

%.cmo: %.ml4
	$(CAMLC) $(OCAMLLIBS) $(ZDEBUG) $(ZFLAGS) $(PP) -impl $<

%.cmx: %.ml4
	$(CAMLOPTC) $(OCAMLLIBS) $(ZDEBUG) $(ZFLAGS) $(PP) -impl $<

%.cmxs: %.ml4
	$(CAMLOPTLINK) $(OCAMLLIBS) $(ZDEBUG) $(ZFLAGS) -shared -o $@ $(PP) -impl $<

%.ml.d: %.ml
	$(CAMLBIN)ocamldep -slash $(OCAMLLIBS) $(PP) "$<" > "$@"

byte:
	$(MAKE) all "OPT:=-byte"

opt:
	$(MAKE) all "OPT:=-opt"

clean:
	rm -f $(CMOFILES) $(CMIFILES) $(CMXFILES) $(CMXSFILES) $(OFILES) $(MLFILES:.ml=.cmo) $(MLFILES:.ml=.cmx) *~
	rm -f $(CMOFILES) $(MLFILES:.ml=.cmi) $(MLFILES:.ml=.ml.d) $(MLFILES:.ml=.cmx) $(MLFILES:.ml=.o)
	cd $(UTIL); $(MAKE) clean

archclean:
	rm -f *.cmx *.o

-include $(MLFILES:.ml=.ml.d)
.SECONDARY: $(MLFILES:.ml=.ml.d)


#API Documents (ocamldoc,coqdoc)
html: $(CMIFILES)
	mkdir -p ocamldoc
	mkdir -p coqdoc
	ocamldoc -d ocamldoc -html $(MLFILES)
	$(MAKE) -f Makefile.coq html
	cp coq/html/* coqdoc/


# Verification (optional)
Makefile.coq: Make.coq
	mv -f Makefile.coq Makefile.coq.bak
	$(COQBIN)coq_makefile -f Make.coq -o Makefile.coq

verification: Makefile.coq
	$(MAKE) -f Makefile.coq
	cp coq/*.ml coq/*.mli ./
