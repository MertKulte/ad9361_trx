function set_tx_data(ip_addr, channel_no, data)
    
    [rows, columns] = size(data);
    if(rows ~= 2 || columns < 1 || columns > 4096)
        disp('Invalid data format. Format must be 2 x n, 1<=n<=4096')
        return;
    end
    if(channel_no ~= 1 && channel_no ~= 2)
        disp('Invalid channel number. Allowed channel numbers are 1 and 2.')
        return;
    end
    if(max(data(:)) > 2047 || max(-data(:)) > 2048)
        disp('Invalid data, data points must be between -2048 and 2047.')
        return;
    end
    
    data = int16(data);
    set_data_size_str = ['SET_TX' num2str(channel_no) '_CH_DATA_SIZE' num2str(columns)];
    set_data_str = ['SET_TX' num2str(channel_no) '_DATA'];
    for ii=1:columns
        set_data_str = [set_data_str typecast(data(1,ii),'uint8') typecast(data(2,ii),'uint8')];
    end
    t = tcpip(ip_addr, 7, 'Timeout', 10);
    t.OutputBufferSize = columns*16+50 ;
    try
        fopen(t);
        fwrite(t,uint8(set_data_size_str));
        fwrite(t,uint8(set_data_str));
        fclose(t);
        clear t;
    catch error_msg
        disp(['set_tx_data_size : ' error_msg.message]);
    end
end

