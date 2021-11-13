function lo_freq_returned = set_lo_freq(ip_addr, lo_freq)

    set_lo_freq_str = ['SET_LO_FREQ', num2str(lo_freq)];
    t = tcpip(ip_addr, 7, 'Timeout', 10);
    try
        fopen(t);
        fwrite(t,uint8(set_lo_freq_str));
        recv_data = fread(t,8);
        lo_freq_returned = double(typecast(uint8(recv_data),'int64'));
        fclose(t); 
        return
    catch
        disp(['set_lo_freq : ' error_msg.message]);
    end
    clear t;
    lo_freq_returned = 0;

end

