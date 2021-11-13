#include "xaxidma.h"
#include "xaxis_switch.h"
#include "xgpiops.h"
#include "ad9361_api.h"

extern XAxiDma RxAxiDma;
extern XAxiDma fftConfigAxiDma;
extern XAxis_Switch AxisSwitch;
extern XGpioPs gpio_instance;
extern struct ad9361_rf_phy *ad9361_phy;

extern AD9361_RXFIRConfig rx_fir_config_768;
extern AD9361_TXFIRConfig tx_fir_config_768;
extern AD9361_RXFIRConfig rx_fir_config_1536;
extern AD9361_TXFIRConfig tx_fir_config_1536;
extern AD9361_RXFIRConfig rx_fir_config_3072;
extern AD9361_TXFIRConfig tx_fir_config_3072;
extern AD9361_RXFIRConfig rx_fir_config_6144;
extern AD9361_TXFIRConfig tx_fir_config_6144;
