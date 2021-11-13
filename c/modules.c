#include "xaxidma.h"
#include "xaxis_switch.h"
#include "xgpiops.h"
#include "ad9361_api.h"

XAxiDma RxAxiDma;
XAxiDma fftConfigAxiDma;
XAxis_Switch AxisSwitch;
XGpioPs	gpio_instance;
struct ad9361_rf_phy *ad9361_phy;

AD9361_RXFIRConfig rx_fir_config_1536 = {
	3, // rx
	0, // rx_gain
	1, // rx_dec
	{-440,314,-279,136,130,-504,936,-1337,1593,-1565,1107,-69,-1609,4039,-8004,21837,21837,-8004,4039,-1609,-69,1107,-1565,1593,-1337,936,-504,130,136,-279,314,-440,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, // rx_coef[128]
	32, // rx_coef_size
	{983040000,122880000,61440000,30720000,15360000,15360000}, // rx_path_clks[6]
	15492411 // rx_bandwidth
};

AD9361_TXFIRConfig tx_fir_config_1536 = {
	3, // tx
	0, // tx_gain
	1, // tx_int
	{-406,278,-251,124,115,-450,839,-1203,1441,-1427,1031,-116,-1395,3591,-7184,21131,21131,-7184,3591,-1395,-116,1031,-1427,1441,-1203,839,-450,115,124,-251,278,-406,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, // tx_coef[128]
	32, // tx_coef_size
	{983040000,122880000,61440000,30720000,15360000,15360000}, // tx_path_clks[6]
	15062007 // tx_bandwidth
};

AD9361_RXFIRConfig rx_fir_config_3072 = {
	3, // rx
	0, // rx_gain
	1, // rx_dec
	{-453,328,-290,140,137,-527,976,-1391,1652,-1614,1127,-36,-1716,4227,-8247,21966,21966,-8247,4227,-1716,-36,1127,-1614,1652,-1391,976,-527,137,140,-290,328,-453,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, // rx_coef[128]
	32, // rx_coef_size
	{983040000,245760000,122880000,61440000,30720000,30720000}, // rx_path_clks[6]
	30984823 // rx_bandwidth
};

AD9361_TXFIRConfig tx_fir_config_3072 = {
	3, // tx
	0, // tx_gain
	1, // tx_int
	{-462,367,-325,165,127,-541,1026,-1489,1800,-1805,1335,-213,-1766,4939,-9543,22486,22486,-9543,4939,-1766,-213,1335,-1805,1800,-1489,1026,-541,127,165,-325,367,-462,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, // tx_coef[128]
	32, // tx_coef_size
	{983040000,122880000,61440000,30720000,30720000,30720000}, // tx_path_clks[6]
	33889517 // tx_bandwidth
};

AD9361_RXFIRConfig rx_fir_config_6144 = {
	3, // rx
	0, // rx_gain
	1, // rx_dec
	{-495,416,-337,119,257,-773,1359,-1895,2213,-2119,1400,158,-2778,6762,-12230,24043,24043,-12230,6762,-2778,158,1400,-2119,2213,-1895,1359,-773,257,119,-337,416,-495,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, // rx_coef[128]
	32, // rx_coef_size
	{983040000,245760000,122880000,61440000,61440000,61440000}, // rx_path_clks[6]
	51641372 // rx_bandwidth
};

AD9361_TXFIRConfig tx_fir_config_6144 = {
	3, // tx
	0, // tx_gain
	1, // tx_int
	{-482,388,-343,172,139,-577,1088,-1572,1891,-1881,1363,-155,-1943,5232,-9874,22645,22645,-9874,5232,-1943,-155,1363,-1881,1891,-1572,1088,-577,139,172,-343,388,-482,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, // tx_coef[128]
	32, // tx_coef_size
	{983040000,245760000,122880000,61440000,61440000,61440000}, // tx_path_clks[6]
	33889517 // tx_bandwidth
};
