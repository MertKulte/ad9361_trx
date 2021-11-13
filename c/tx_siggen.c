#include "xil_io.h"
#include "sleep.h"

void tx_siggen_reset(unsigned int base_addr){
	Xil_Out32(base_addr+4, 0x0);
	Xil_Out32(base_addr+8, 0x0);
	Xil_Out32(base_addr+12, 0x0);
	Xil_Out32(base_addr, 0x0);
	return;
}

// channel_no = 0,1 , 0 = disable, 1 enable
void tx_siggen_en_dis_output(unsigned int base_addr, int channel_no, int en_dis){
	int value_holder;
	if(channel_no != 1 && channel_no != 0 && en_dis != 1 && en_dis != 0){
		xil_printf("tx_siggen_end_dis_output error, invalid argument.\r\n");
		return;
	}
	value_holder = Xil_In32(base_addr);
	if(channel_no == 0 && en_dis == 0){
		value_holder = value_holder & 0xFFFFFFFD;
	}
	else if(channel_no == 0 && en_dis == 1){
		value_holder = value_holder | 0x2;
	}
	else if(channel_no == 1 && en_dis == 0){
		value_holder = value_holder & 0xFFFFFFFB;
	}
	else if(channel_no == 1 && en_dis == 1){
		value_holder = value_holder | 0x4;
	}
	Xil_Out32(base_addr, value_holder);
	return;
}

void tx_siggen_set_new_dataset(unsigned int base_addr, int channel_no, int data_size, int data_addr){

	int value_holder;

	if(channel_no != 1 && channel_no != 0){
		xil_printf("tx_siggen_set_new_dataset error, invalid channel no.\r\n");
		return;
	}
	if(data_size < 1 || data_size > 4096){
		xil_printf("tx_siggen_set_new_dataset data size error, data size must be between 1-4096.\r\n");
		return;
	}

	value_holder = Xil_In32(base_addr);
	if(channel_no == 0){
		value_holder = value_holder & 0xFFF000FF;
		value_holder = value_holder | ((data_size-1) << 8);
		value_holder = value_holder | (1 << 3);
		Xil_Out32(base_addr, value_holder);
	}
	else if(channel_no == 1){
		value_holder = value_holder & 0x000FFFFF;
		value_holder = value_holder | ((data_size-1) << 20);
		value_holder = value_holder | (1 << 4);
		Xil_Out32(base_addr, value_holder);
	}

	for(int i=0 ; i < data_size ; i++){
		Xil_Out32(base_addr+12, i << ((channel_no)*12));
		value_holder = Xil_In32(data_addr+4*i);
		Xil_Out32(base_addr+4*(channel_no+1), value_holder);
	}

	value_holder = Xil_In32(base_addr);
	value_holder = value_holder & 0xFFFFFFE7;
	Xil_Out32(base_addr, value_holder);

	return;

}














