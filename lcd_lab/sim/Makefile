WORK = ${WORKAREA}/target/lcd_lab 

all : clean elab run 

elab : 
    vcs -full64 -sverilog       \
    -f $(WORK)/svtb/tb_file.f   \
    -f $(WORK)/rtl/rtl_file.f   \
    -timescale=1ps/1ps          \
    -debug_access+all           \
	-l elab.log                 \
    -P ${VERDI_HOME}/share/PLI/VCS/LINUX64/novas.tab \
       ${VERDI_HOME}/share/PLI/VCS/LINUX64/pli.a     \
    -cm line+cond+fsm+branch+tgl -gui 
run :
    ./simv +top -l run.log -cm line+cond+fsm+branch+tgl 
clean :
    \rm -rf elab.log run.log simv simv.daidir ucli.key inter.vpd *.fsdb* *.vdb *.log simv.cst urgReport novas.conf novas.rc vc_hdrs.h DVEfiles 
wave : 
    verdi -top top -f $(WORK)/svtb/tb_file.f -f $(WORK)/rtl/rtl_file.f -ssf lcd.fsdb