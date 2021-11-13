/*
 * Copyright (C) 2009 - 2018 Xilinx, Inc.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 3. The name of the author may not be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
 * SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
 * OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
 * IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
 * OF SUCH DAMAGE.
 *
 */

#include <stdio.h>
#include <string.h>

#include "lwip/err.h"
#include "lwip/tcp.h"
#if defined (__arm__) || defined (__aarch64__)
#include "xil_printf.h"
#endif

#include "data_packager.h"
#include "modules.h"
#include "math.h"
#include "tx_siggen.h"

static int bytes_total = 0;
static int bytes_sent = 0;
static int total_received = 0;
static int receive_in_progress_ch1 = 0;
static int receive_in_progress_ch2 = 0;
static int tx1_data_size = 1024;
static int tx2_data_size = 1024;

#define RX_BUFFER_BASE 0x01300000
#define TX_BUFFER_BASE 0x02300000

int transfer_data() {
	return 0;
}

void print_app_header()
{
#if (LWIP_IPV6==0)
	xil_printf("\n\r\n\r-----lwIP TCP echo server ------\n\r");
#else
	xil_printf("\n\r\n\r-----lwIPv6 TCP echo server ------\n\r");
#endif
	xil_printf("TCP packets sent to port 6001 will be echoed back\n\r");
}

static err_t send_callback(void *arg, struct tcp_pcb *tpcb, u16_t len)
{
	int offset;
	if(bytes_total == bytes_sent){
		return 0;
	}
	else{
		u8 *RxBufferPtr;
		RxBufferPtr = (u8 *)RX_BUFFER_BASE;
		if(bytes_total - bytes_sent > tpcb->snd_buf){
			offset = bytes_sent;
			bytes_sent = bytes_sent + tpcb->snd_buf-(tpcb->snd_buf%8);
			tcp_write(tpcb, RxBufferPtr+offset, tpcb->snd_buf-(tpcb->snd_buf%8), 3);
			tcp_output(tpcb);
			return 0;
		}
		else{
			int bytes_to_send = bytes_total-bytes_sent;
			offset = bytes_sent;
			bytes_sent = bytes_total;
			tcp_write(tpcb, RxBufferPtr+offset, bytes_to_send, 3);
			tcp_output(tpcb);
			return 0;
		}
	}
}

err_t recv_callback(void *arg, struct tcp_pcb *tpcb,
                               struct pbuf *p, err_t err)
{
	int command_value;
	char dest[30];

	u8 *RxBufferPtr;
	RxBufferPtr = (u8 *)RX_BUFFER_BASE;
	u8 *TxBufferPtr;
	TxBufferPtr = (u8 *)TX_BUFFER_BASE;

	bytes_sent = 0;
	bytes_total = 0;

	char tx1_data[4096*4];
	char tx2_data[4096*4];

	/* do not read the packet if we are not in ESTABLISHED state */
	if (!p) {
		tcp_close(tpcb);
		tcp_recv(tpcb, NULL);
		return ERR_OK;
	}

	/* indicate that the packet has been received */
	tcp_recved(tpcb, p->len);

	if(strncmp(p->payload, "TEST_CONN", 9)==0){
		char vna_version[7] = "CONN_OK";
		tcp_write(tpcb, &vna_version, sizeof(vna_version), 1);
		tcp_output(tpcb);
	}
	else if(strncmp(p->payload, "GET_TD_DATA", 11)==0){

		// Get the sample size variable from the command.
		strncpy(dest, &(((char*)p->payload)[11]), (p->len)-11);
		dest[(p->len)-11] = '\0';
		sscanf(dest, "%d", &command_value);

		// Number of total bytes that needs to be transferred.
		// I1, Q1, I2, Q2, all 32 bit single variables per sample, total of 128 byte.
		bytes_total = command_value*16;

		// Set AXI Interconnect IP to directly send data.
		XAxisScr_RegUpdateDisable(&AxisSwitch);
		XAxisScr_MiPortDisableAll(&AxisSwitch);
		XAxisScr_MiPortEnable(&AxisSwitch, 0, 0);
		XAxisScr_RegUpdateEnable(&AxisSwitch);

		// Data transfer sequence
		XAxiDma_Reset(&RxAxiDma);
		data_packager_reset(XPAR_DATA_PACKAGER_0_BASEADDR);
		data_packager_set_transfer_size(XPAR_DATA_PACKAGER_0_BASEADDR, command_value);

		XAxiDma_SimpleTransfer(&RxAxiDma,(UINTPTR) RxBufferPtr, command_value*16, XAXIDMA_DEVICE_TO_DMA);
		data_packager_start_transfer(XPAR_DATA_PACKAGER_0_BASEADDR);
		Xil_DCacheFlush();

		while(XAxiDma_Busy(&RxAxiDma,XAXIDMA_DEVICE_TO_DMA)){

		}

		// Invalidate cache to get correct results.
		Xil_DCacheInvalidate();
		Xil_ICacheInvalidate();

		// Send the data back
		bytes_sent = (tpcb->snd_buf)-((tpcb->snd_buf)%8);
		tcp_write(tpcb, RxBufferPtr, bytes_sent, 3);
		tcp_output(tpcb);

	}
	else if(strncmp(p->payload, "GET_FD_DATA", 11)==0){

		// Get the sample size variable from the command.
		strncpy(dest, &(((char*)p->payload)[11]), (p->len)-11);
		dest[(p->len)-11] = '\0';
		sscanf(dest, "%d", &command_value);

		// Check if command value is in the range of valid numbers.
		if(command_value != 8 && command_value != 16 && command_value != 32 \
		   && command_value != 64 && command_value != 128 && command_value != 256 \
		   && command_value != 512 && command_value != 1024 && command_value != 2048 && command_value != 4096){

			char invalid_sample_size[56] = "Invalid sample size. Sample size must be between 2^3-12.";
			tcp_write(tpcb, &invalid_sample_size, sizeof(invalid_sample_size), 1);
			tcp_output(tpcb);

		}
		else{

			// Number of total bytes that needs to be transferred.
			// I1, Q1, I2, Q2, all 32 bit single variables per sample, total of 128 byte.
			bytes_total = command_value*16;

			// Reset FFT IP before setting new FFT size.
			XGpioPs_WritePin(&gpio_instance, 117, 0);
			XGpioPs_WritePin(&gpio_instance, 117, 1);

			// Send new FFT config via fftConfigAxiDma
			XAxiDma_Reset(&fftConfigAxiDma);

			Xil_Out32(TX_BUFFER_BASE, (int)log2((double)command_value));
			Xil_DCacheFlush();
			XAxiDma_SimpleTransfer(&fftConfigAxiDma,(UINTPTR) TxBufferPtr, 4, XAXIDMA_DMA_TO_DEVICE);
			Xil_DCacheFlush();
			if(XAxiDma_Busy(&fftConfigAxiDma, XAXIDMA_DMA_TO_DEVICE)){

			}

			// Set AXI Interconnect IP to use FFT IP.
			XAxisScr_RegUpdateDisable(&AxisSwitch);
			XAxisScr_MiPortDisableAll(&AxisSwitch);
			XAxisScr_MiPortEnable(&AxisSwitch, 0, 1);
			XAxisScr_MiPortEnable(&AxisSwitch, 1, 0);
			XAxisScr_RegUpdateEnable(&AxisSwitch);

			// Data transfer sequence
			XAxiDma_Reset(&RxAxiDma);
			data_packager_reset(XPAR_DATA_PACKAGER_0_BASEADDR);
			data_packager_set_transfer_size(XPAR_DATA_PACKAGER_0_BASEADDR, command_value);

			XAxiDma_SimpleTransfer(&RxAxiDma,(UINTPTR) RxBufferPtr, command_value*16, XAXIDMA_DEVICE_TO_DMA);
			data_packager_start_transfer(XPAR_DATA_PACKAGER_0_BASEADDR);
			Xil_DCacheFlush();

			while(XAxiDma_Busy(&RxAxiDma,XAXIDMA_DEVICE_TO_DMA)){

			}

			// Invalidate cache to get correct results.
			Xil_DCacheInvalidate();
			Xil_ICacheInvalidate();

			// Send the data back
			bytes_sent = (tpcb->snd_buf)-((tpcb->snd_buf)%8);
			tcp_write(tpcb, RxBufferPtr, bytes_sent, 3);
			tcp_output(tpcb);

		}

	}
	else if(strncmp(p->payload, "SET_TX1_CH_DATA_SIZE", 20)==0){

		// Get the sample size variable from the command.
		strncpy(dest, &(((char*)p->payload)[20]), (p->len)-20);
		dest[(p->len)-20] = '\0';
		sscanf(dest, "%d", &command_value);

		tx1_data_size = command_value;
		xil_printf("Setting tx1 data size %d\r\n", tx1_data_size);

	}
	else if(strncmp(p->payload, "SET_TX2_CH_DATA_SIZE", 20)==0){

		// Get the sample size variable from the command.
		strncpy(dest, &(((char*)p->payload)[20]), (p->len)-20);
		dest[(p->len)-20] = '\0';
		sscanf(dest, "%d", &command_value);

		tx2_data_size = command_value;
		xil_printf("Setting tx2 data size %d\r\n", tx2_data_size);

	}
	else if(strncmp(p->payload, "SET_TX1_DATA", 12)==0 || receive_in_progress_ch1 == 1){
		//xil_printf("%d %d\r\n", (p->len), p->tot_len);
		if(receive_in_progress_ch1 == 0){
			memcpy(tx1_data+total_received, (p->payload)+12, p->len-12);
			total_received = total_received + (p->len)-12;
		}
		else{
			memcpy(tx1_data+total_received, p->payload, p->len);
			total_received = total_received + (p->len);
		}

		xil_printf("%d \r\n", total_received);

		if(total_received < tx1_data_size*4){
			receive_in_progress_ch1 = 1;
		}
		else{
			total_received = 0;
			receive_in_progress_ch1 = 0;
			//xil_printf(" \r\n\r\nPrinting data \r\n\r\n");
			for(int i=0;i<tx1_data_size;i++){
				//int value_holder = Xil_In32((unsigned int)tx1_data+4*i);
				//xil_printf("%d %d\r\n", (int16_t)(value_holder & 0xFFFF), (int16_t)((value_holder & 0xFFFF0000)>>16));
			}

			tx_siggen_set_new_dataset(XPAR_AD9361_TX_SIGNAL_GEN_0_BASEADDR, 0, tx1_data_size, (int)tx1_data);
		}
	}
	else if(strncmp(p->payload, "SET_TX2_DATA", 12)==0 || receive_in_progress_ch2 == 1){
		//xil_printf("%d %d\r\n", (p->len), p->tot_len);
		if(receive_in_progress_ch2 == 0){
			memcpy(tx2_data+total_received, (p->payload)+12, p->len-12);
			total_received = total_received + (p->len)-12;
		}
		else{
			memcpy(tx2_data+total_received, p->payload, p->len);
			total_received = total_received + (p->len);
		}

		xil_printf("%d \r\n", total_received);

		if(total_received < tx2_data_size*4){
			receive_in_progress_ch2 = 1;
		}
		else{
			total_received = 0;
			receive_in_progress_ch2 = 0;
			//xil_printf(" \r\n\r\nPrinting data \r\n\r\n");
			for(int i=0;i<tx2_data_size;i++){
				//int value_holder = Xil_In32((unsigned int)tx2_data+4*i);
				//xil_printf("%d %d\r\n", (int16_t)(value_holder & 0xFFFF), (int16_t)((value_holder & 0xFFFF0000)>>16));
			}

			tx_siggen_set_new_dataset(XPAR_AD9361_TX_SIGNAL_GEN_0_BASEADDR, 1, tx2_data_size, (int)tx2_data);
		}
	}
	else if(strncmp(p->payload, "EN_TX1_OUTPUT", 13)==0){
		tx_siggen_en_dis_output(XPAR_AD9361_TX_SIGNAL_GEN_0_BASEADDR, 0, 1);
	}
	else if(strncmp(p->payload, "EN_TX2_OUTPUT", 13)==0){
		tx_siggen_en_dis_output(XPAR_AD9361_TX_SIGNAL_GEN_0_BASEADDR, 1, 1);
	}
	else if(strncmp(p->payload, "DIS_TX1_OUTPUT", 13)==0){
		tx_siggen_en_dis_output(XPAR_AD9361_TX_SIGNAL_GEN_0_BASEADDR, 0, 0);
	}
	else if(strncmp(p->payload, "DIS_TX2_OUTPUT", 13)==0){
		tx_siggen_en_dis_output(XPAR_AD9361_TX_SIGNAL_GEN_0_BASEADDR, 1, 0);
	}
	else if(strncmp(p->payload, "SET_PROFILE", 11)==0){
		strncpy(dest, &(((char*)p->payload)[11]), (p->len)-11);
		dest[(p->len)-11] = '\0';
		sscanf(dest, "%d", &command_value);

		ad9361_set_trx_fir_en_dis (ad9361_phy, 0);

		if(command_value == 1){
			ad9361_trx_load_enable_fir(ad9361_phy, rx_fir_config_1536, tx_fir_config_1536);
		}
		else if(command_value == 2){
			ad9361_trx_load_enable_fir(ad9361_phy, rx_fir_config_3072, tx_fir_config_3072);
		}
		else{
			ad9361_trx_load_enable_fir(ad9361_phy, rx_fir_config_6144, tx_fir_config_6144);
		}
		uint32_t sampling_freq_hz;
		ad9361_get_tx_sampling_freq (ad9361_phy, &sampling_freq_hz);
		xil_printf("%d\r\n", sampling_freq_hz);
	}
	else if(strncmp(p->payload,"SET_LO_FREQ",11)==0){
		uint64_t lo_freq_hz;
		strncpy(dest, &(((char*)p->payload)[11]), (p->len)-11);
		sscanf(dest, "%llu", &lo_freq_hz);
		printf("%llu\r\n", lo_freq_hz);
		xil_printf("Setting lo %f\r\n",lo_freq_hz);
		ad9361_set_rx_lo_freq(ad9361_phy, lo_freq_hz);
		ad9361_set_tx_lo_freq(ad9361_phy, lo_freq_hz);
		ad9361_get_rx_lo_freq(ad9361_phy, &lo_freq_hz);
		tcp_write(tpcb, &lo_freq_hz, sizeof(lo_freq_hz), 1);
	}
	else if(strncmp(p->payload,"GET_LO_FREQ",11)==0){
		uint64_t lo_freq_hz;
		//lo_freq_hz = 3000000000;
		//ad9361_set_rx_lo_freq(ad9361_phy, lo_freq_hz);
		//ad9361_set_tx_lo_freq(ad9361_phy, lo_freq_hz);
		ad9361_get_rx_lo_freq(ad9361_phy, &lo_freq_hz);
		tcp_write(tpcb, &lo_freq_hz, sizeof(lo_freq_hz), 1);
	}
	else if(strncmp(p->payload,"RX1_AUTO",8)==0){
		ad9361_set_rx_gain_control_mode(ad9361_phy, RX1, RF_GAIN_SLOWATTACK_AGC);
	}
	else if(strncmp(p->payload,"RX2_AUTO",8)==0){
		ad9361_set_rx_gain_control_mode(ad9361_phy, RX2, RF_GAIN_SLOWATTACK_AGC);
	}
	else if(strncmp(p->payload,"RX1_MANUAL",10)==0){
		ad9361_set_rx_gain_control_mode(ad9361_phy, RX1, RF_GAIN_MGC);
	}
	else if(strncmp(p->payload,"RX2_MANUAL",10)==0){
		ad9361_set_rx_gain_control_mode(ad9361_phy, RX2, RF_GAIN_MGC);
	}
	else if(strncmp(p->payload,"GET_RX1_GAIN",12)==0){
		int32_t gain_db;
		ad9361_get_rx_rf_gain (ad9361_phy, 0, &gain_db);
		tcp_write(tpcb, &gain_db, sizeof(gain_db), 1);
	}
	else if(strncmp(p->payload,"GET_RX2_GAIN",12)==0){
		int32_t gain_db;
		ad9361_get_rx_rf_gain (ad9361_phy, 1, &gain_db);
		tcp_write(tpcb, &gain_db, sizeof(gain_db), 1);
	}
	else if(strncmp(p->payload, "SET_RX1_GAIN",12)==0){
		strncpy(dest, &(((char*)p->payload)[12]), (p->len)-12);
		sscanf(dest, "%d", &command_value);
		xil_printf("Setting gain = %d\r\n", command_value);
		ad9361_set_rx_rf_gain (ad9361_phy, 0, command_value);
		int32_t gain_db;
		ad9361_get_rx_rf_gain (ad9361_phy, 0, &gain_db);
		tcp_write(tpcb, &gain_db, sizeof(gain_db), 1);
	}
	else if(strncmp(p->payload, "SET_RX2_GAIN",12)==0){
		strncpy(dest, &(((char*)p->payload)[12]), (p->len)-12);
		sscanf(dest, "%d", &command_value);
		xil_printf("Setting gain = %d\r\n", command_value);
		ad9361_set_rx_rf_gain (ad9361_phy, 1, command_value);
		int32_t gain_db;
		ad9361_get_rx_rf_gain (ad9361_phy, 1, &gain_db);
		tcp_write(tpcb, &gain_db, sizeof(gain_db), 1);
	}
	else{
		char unknown_command[25] = "Unknown command received.";
		tcp_write(tpcb, &unknown_command, sizeof(unknown_command), 1);
		xil_printf("Unknown\r\n");
	}

	/* echo back the payload */
	/* in this case, we assume that the payload is < TCP_SND_BUF */
//	if (tcp_sndbuf(tpcb) > p->len) {
//		err = tcp_write(tpcb, p->payload, p->len, 1);
//	} else
//		xil_printf("no space in tcp_sndbuf\n\r");

	/* free the received pbuf */
	pbuf_free(p);

	return ERR_OK;
}

err_t accept_callback(void *arg, struct tcp_pcb *newpcb, err_t err)
{
	static int connection = 1;

	/* set the receive callback for this connection */
	tcp_recv(newpcb, recv_callback);
	tcp_sent(newpcb, send_callback);

	/* just use an integer number indicating the connection id as the
	   callback argument */
	tcp_arg(newpcb, (void*)(UINTPTR)connection);

	/* increment for subsequent accepted connections */
	connection++;

	return ERR_OK;
}


int start_application()
{
	struct tcp_pcb *pcb;
	err_t err;
	unsigned port = 7;

	/* create new TCP PCB structure */
	pcb = tcp_new_ip_type(IPADDR_TYPE_ANY);
	if (!pcb) {
		xil_printf("Error creating PCB. Out of Memory\n\r");
		return -1;
	}

	/* bind to specified @port */
	err = tcp_bind(pcb, IP_ANY_TYPE, port);
	if (err != ERR_OK) {
		xil_printf("Unable to bind to port %d: err = %d\n\r", port, err);
		return -2;
	}

	/* we do not need any arguments to callback functions */
	tcp_arg(pcb, NULL);

	/* listen for connections */
	pcb = tcp_listen(pcb);
	if (!pcb) {
		xil_printf("Out of memory while tcp_listen\n\r");
		return -3;
	}

	/* specify callback to use for incoming connections */
	tcp_accept(pcb, accept_callback);

	xil_printf("TCP echo server started @ port %d\n\r", port);

	return 0;
}
