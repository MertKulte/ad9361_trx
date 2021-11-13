function set_profile(ip_addr, profile_no)

    if(profile_no ~= 1 && profile_no ~= 2 && profile_no ~= 3 && profile_no ~= 4)
        disp('Invalid profile value. Allowed values are between 1 and 4.')
    end

    set_profile_str = ['SET_PROFILE' num2str(profile_no)];
    
    t = tcpip(ip_addr, 7, 'Timeout', 10);
    try
        fopen(t);
        fwrite(t,uint8(set_profile_str));
        fclose(t);
        clear t;
    catch error_msg
        disp(['set_profile : ' error_msg.message]);
    end
    
end

