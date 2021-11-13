void data_packager_reset(unsigned int base_addr);
void data_packager_set_transfer_size(unsigned int base_addr, int transfer_size);
int data_packager_get_transfer_size(unsigned int base_addr);
void data_packager_start_transfer(unsigned int base_addr);
int data_packager_read_done(unsigned int base_addr);
int data_packager_read_overflow(unsigned int base_addr);
