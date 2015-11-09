

PATSCC=patscc -ccats --tlcalopt-disable -IIATS ${PATSHOMERELOC}

all: simplesession.beam session.beam untyped.beam

clean:
	rm *_dats.c
	rm *.erl 
	rm *.beam
	cd CML && make clean

simplesession.erl: simplesession.dats
	$(PATSCC) simplesession.dats
	atscc2erl -i simplesession_dats.c > simplesession.erl

simplesession.beam: simplesession.erl 
	erlc simplesession.erl 

session.erl: session.dats 
	$(PATSCC) session.dats 
	atscc2erl -i session_dats.c > session.erl 

session.beam: session.erl
	erlc session.erl 

Elixir.Channel.beam: CML/CATS/CML.ex
	cd CML && make

untyped.erl: untyped.dats Elixir.Channel.beam
	$(PATSCC) untyped.dats
	atscc2erl -i untyped_dats.c > untyped.erl 

untyped.beam: untyped.erl 
	erlc -pz CML/CATS untyped.erl 


testuntyped:
	erl -pz CML/CATS 