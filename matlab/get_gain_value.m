function gain_value = get_gain_value(ip_addr, channel_no)

    if(channel_no == 1)
        command_str = 'GET_RX1_GAIN';
    elseif(channel_no == 2)
        command_str = 'GET_RX2_GAIN';
    else
        disp('Invalid channel number. Allowed channel numbers are 1 and 2.')
        return;
    end
    
    t = tcpip(ip_addr, 7);
    fopen(t);
    fwrite(t,uint8(command_str));          
    recv_data = fread(t,4);
    recv_data = typecast(uint8(recv_data),'int32'); 
    fclose(t); 
    clear t;
    gain_value = double(recv_data);

end

