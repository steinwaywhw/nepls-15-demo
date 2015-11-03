

PATSCC=patscc -ccats --tlcalopt-disable -IIATS ${PATSHOMERELOC}

all: simplesession.beam

clean:
	rm *_dats.c
	rm *.erl 
	rm *.beam

simplesession.erl: simplesession.dats
	$(PATSCC) simplesession.dats
	atscc2erl -i simplesession_dats.c > simplesession.erl

simplesession.beam: simplesession.erl 
	erlc simplesession.erl 

