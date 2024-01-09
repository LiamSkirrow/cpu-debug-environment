#include <stdlib.h>
#include <iostream>
#include <verilated.h>
#include <verilated_fst_c.h>
#include "../obj_dir/Vwrapper.h"
#include "../obj_dir/Vwrapper___024root.h"
#include "../obj_dir/Vwrapper__Syms.h"

#define MAX_SIM_TIME 100
#define CODE_MEM_SIZE 100
#define DATA_MEM_SIZE 100
vluint64_t sim_time = 0;

int main(int argc, char** argv, char** env) {
    Vwrapper *dut = new Vwrapper;

    Verilated::traceEverOn(true);
    VerilatedFstC *m_trace = new VerilatedFstC;
    dut->trace(m_trace, 5);
    m_trace->open("wrapper_waves.fst");

    while (sim_time < MAX_SIM_TIME) {
        
        // release dut out of reset
        if(sim_time == 0 && dut->CLK100MHZ == 0){
            dut->sw0 = 1;
        } else{
            dut->sw0 = 0;
        }
        
        dut->CLK100MHZ ^= 1;
        dut->eval();
        m_trace->dump(sim_time);
        sim_time++;
    }

    m_trace->close();
    delete dut;
    exit(EXIT_SUCCESS);
}
