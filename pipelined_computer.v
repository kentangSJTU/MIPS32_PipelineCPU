module pipelined_computer(resetn,clock,mem_clock,pc,inst,ealu,malu,walu);
	input resetn,clock,mem_clock;
	output [31:0] pc,inst,ealu,malu,walu;
	//pc: currently IF, inst: currently ID
	//IF
	wire [31:0] bpc,jpc,npc,pc4,ins,inst;
	//ID
	wire [31:0] dpc4,da,db,dimm;
	//EX
	wire [31:0] epc4,ea,eb,eimm;
	//MEM
	wire [31:0] mb,mmo;
	//WB
	wire [31:0] wmo,wdi;
	//register number
	wire [4:0] drn,ern0,ern,mrn,wrn;
	//ALUC
	wire [3:0] daluc,ealuc;
	//PCsource
	wire [1:0] pcsource;
	//freeze PC and IF/ID
	wire wpcir;
	//IF/ID
	wire dwreg,dm2reg,dwmem,daluimm,dshift,djal;
	//ID/EX
	wire ewreg,em2reg,ewmem,ealuimm,eshift,ejal;
	//EX/MEM
	wire mwreg,mm2reg,mwmem;
	//MEM/WB
	wire wwreg,wm2reg;

	//IF/ID/MEM read at negedge of clock.
	pipepc prog_cnt(npc,wpcir,clock,resetn,pc);
	pipeif if_stage(pcsource,pc,bpc,da,jpc,npc,pc4,ins,mem_clock);
	pipeir inst_reg(pc4,ins,wpcir,clock,resetn,dpc4,inst);
	pipeid id_stage(mwreg,mrn,ern,ewreg,em2reg,mm2reg,dpc4,inst,
		wrn,wdi,ealu,malu,mmo,wwreg,clock,resetn,bpc,
		jpc,pcsource,wpcir,dwreg,dm2reg,dwmem,daluc,daluimm,
		da,db,dimm,drn,dshift,djal);
	pipedereg de_reg(dwreg,dm2reg,dwmem,daluc,daluimm,da,db,dimm,
		drn,dshift,djal,dpc4,clock,resetn,ewreg,em2reg,ewmem,ealuc,ealuimm,
		ea,eb,eimm,ern0,eshift,ejal,epc4);
	pipeexe exe_stage(ealuc,ealuimm,ea,eb,eimm,eshift,ern0,epc4,ejal,ern,ealu);
	pipeemreg em_reg(ewreg,em2reg,ewmem,ealu,eb,ern,clock,resetn,mwreg,
		mm2reg,mwmem,malu,mb,mrn);
	pipemem mem_stage(mwmem,malu,mb,clock,mem_clock,mmo);
	pipemwreg mw_reg(mwreg,mm2reg,mmo,malu,mrn,clock,resetn,wwreg,
		wm2reg,wmo,walu,wrn);
	mux2x32 wb_stage(walu,wmo,wm2reg,wdi);
endmodule