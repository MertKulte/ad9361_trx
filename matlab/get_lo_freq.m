function lo_freq = get_lo_freq(ip_addr)

    t = tcpip(ip_addr, 7, 'Timeout', 10);
    try
        fopen(t);
        fwrite(t,uint8('GET_LO_FREQ'));
        recv_data = fread(t,8);
        lo_freq = double(typecast(uint8(recv_data),'int64'));
        fclose(t); 
        return
    catch
        disp(['get_lo_freq : ' error_msg.message]);
    end
    clear t;
    lo_freq = 0;

end

