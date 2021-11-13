#include "math.h"
#include "xil_printf.h"
#include "xil_io.h"

void data_packager_reset(unsigned int base_addr){
	int value_holder;
	//value_holder = REG_READ(base_addr);
	//xil_printf("Value before reset = %X", value_holder);
	Xil_Out32(base_addr, 0x0);
	value_holder = Xil_In32(base_addr);
	if(value_holder != 0x2){
		xil_printf("Data packager reset failed.\r\n");
	}
	//xil_printf("Value after reset = %X", value_holder);
	return;
}

int data_packager_get_transfer_size(unsigned int base_addr){
	int value_holder;
	value_holder = Xil_In32(base_addr+0x8);
	return value_holder;
}

void data_packager_set_transfer_size(unsigned int base_addr, int transfer_size){
	int value_holder;
	value_holder = Xil_In32(base_addr);
	if((value_holder & 0x1) == 1){
		xil_printf("Data packager is running. Can't change transfer size.\r\n");
		return;
	}
	else if((value_holder & 0x2) >> 1 == 0){
		xil_printf("Data packager is in reset state. Can't change transfer size.\r\n");
		return;
	}
	else{
		Xil_Out32(base_addr+0x8, transfer_size);
	}
	if(data_packager_get_transfer_size(base_addr) != transfer_size){
		xil_printf("Data packager transfer size set failed. %d \r\n",data_packager_get_transfer_size(base_addr));
		return;
	}
	//xil_printf("Data packager set transfer size successfull.");
	return;
}



void data_packager_start_transfer(unsigned int base_addr){ //kod eklenecek
	int value_holder;
	value_holder = Xil_In32(base_addr);
	value_holder = value_holder | 0x1;
	Xil_Out32(base_addr,value_holder);
	return;
}

int data_packager_read_done(unsigned int base_addr){


}
int data_packager_read_overflow(unsigned int base_addr){

}
