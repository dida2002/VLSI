# VLSI

FAZE INSTRUKCIJE


	      
FETCH	  ->IN X                   	                            ACC<-IN         mem_operandX<-ACC
INST	  ->OUT X            decode_operandX                            OUR<-MDR
	      ->ADD,SUB,MUL,DIV  decode_operandY, decode operandZ   ACC<-OC(Y,Z)    mem_operandX<-ACC
