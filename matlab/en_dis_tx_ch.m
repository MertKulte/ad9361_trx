function en_dis_tx_ch(ip_addr, channel_no, en_dis)
    
    if(en_dis == 0)
        en_dis_tx_str = 'DIS_TX';
    elseif(en_dis == 1)
        en_dis_tx_str = 'EN_TX';
    else
        disp('Invalid en_dis value. Allowed values are 0 and 1.')
        return;
    end

    if(channel_no == 1)
        en_dis_tx_str = [en_dis_tx_str '1_OUTPUT'];
    elseif(channel_no == 2)
        en_dis_tx_str =[en_dis_tx_str '2_OUTPUT'];
    else
        disp('Invalid channel number. Allowed channel numbers are 1 and 2.')
        return;
    end

    t = tcpip(ip_addr, 7, 'Timeout', 1);

    try
        fopen(t);
        fwrite(t,uint8(en_dis_tx_str));
        fclose(t);
        clear t;
    catch error_msg
        disp(['en_dis_tx_ch error : ' error_msg.message]);
    end
end