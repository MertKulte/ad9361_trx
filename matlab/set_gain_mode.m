function set_gain_mode(ip_addr, channel_no, gain_mode)
    
    if(channel_no == 1)
        set_gain_mode_str = 'RX1_';
    elseif(channel_no == 2)
        set_gain_mode_str = 'RX2_';
    else
        disp('Invalid channel number. Allowed channel numbers are 1 and 2.')
        return;
    end
    
    if(gain_mode == 1)
        set_gain_mode_str = [set_gain_mode_str 'AUTO'];
    elseif(gain_mode == 2)
        set_gain_mode_str = [set_gain_mode_str 'MANUAL'];
    else
        disp('Invalid gain mode selected. Allowed gain modes are 1 for auto and 2 for manual.')
        return;
    end
    
    t = tcpip(ip_addr, 7, 'Timeout', 1);

    try
        fopen(t);
        fwrite(t,uint8(set_gain_mode_str));
        fclose(t);
        clear t;
    catch error_msg
        disp(['set_gain_mode error : ' error_msg.message]);
    end

end

