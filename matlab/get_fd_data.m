function [ch1_data,ch2_data] = get_fd_data(ip_addr, sample_size)

    if(sample_size ~= 8 && sample_size ~= 16 && sample_size ~= 32 && ...
       sample_size ~= 64 && sample_size ~= 128 && sample_size ~= 256 && ...
       sample_size ~= 512 && sample_size ~= 1024 && sample_size ~= 2048 && sample_size ~= 4096)
        disp('Invalid fd data sample size. Allowed numbers are 2^n, n = 3 to 12')
        ch1_data = [];
        ch2_data = [];
        return;
    end
    getdata_str = 'GET_FD_DATA';
    getdata_str = strcat(getdata_str, num2str(sample_size));
    t = tcpip(ip_addr, 7, 'Timeout', 10);
    t.InputBufferSize = sample_size*16 ;
    try
        fopen(t);
        fwrite(t,uint8(getdata_str));
        recv_data = fread(t,sample_size*16);
        fclose(t);
        clear t;
        recv_data_formatted = typecast(uint8(recv_data),'single');
        ch1_data = double(complex(recv_data_formatted(1:4:length(recv_data_formatted)-3),(recv_data_formatted(2:4:length(recv_data_formatted)-2))));
        ch2_data = double(complex(recv_data_formatted(3:4:length(recv_data_formatted)-1),(recv_data_formatted(4:4:length(recv_data_formatted)))));
    catch error_msg
        ch1_data = 0;
        ch2_data = 0;
        disp(['get_fd_data error : ' error_msg.message]);
    end
end

