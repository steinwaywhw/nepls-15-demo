
all:
	cd CATS && elixirc CML.ex 

clean:
	cd CATS && rm -f *.beam
	cd TEST && rm -f *.beam *.erl


# all:
# 	cd CATS && rm -f *.beam
# 	cd TEST && rm -f *.beam
# 	cd CATS && elixirc CML.ex 
# 	cd TEST && patsopt --tlcalopt-disable -d test.dats | atscc2erl -o test_dats.erl 
# 	cd TEST && erlc test_dats.erl 

# .PHONY: test 
# test:
# 	erl -pz TEST/ CATS/

# Elixir.Channel.beam: CATS/CML.ex
# 	cd CATS && elixirc CML.ex 

# test_dats.erl: test.dats
# 	patsopt --tlcalopt-disable $< | atscc2erl -o $@
# test_dats.beam: test_dats.erl 
# 	erlc $< 


# all: test_dats.beam Elixir.Channel.beam 

# clean: 
# 	rm CATS/*.beam
