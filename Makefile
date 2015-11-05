

PATSCC=patscc -ccats --tlcalopt-disable -IIATS ${PATSHOMERELOC}

all: simplesession.beam depsession.beam

clean:
	rm *_dats.c
	rm *.erl 
	rm *.beam

simplesession.erl: simplesession.dats
	$(PATSCC) simplesession.dats
	atscc2erl -i simplesession_dats.c > simplesession.erl

simplesession.beam: simplesession.erl 
	erlc simplesession.erl 

depsession.erl: depsession.dats 
	# patscc -tcats -IIATS ${PATSHOMERELOC} depsession.dats
	$(PATSCC) depsession.dats 
	atscc2erl -i depsession_dats.c > depsession.erl 

depsession.beam: depsession.erl
	erlc depsession.erl 