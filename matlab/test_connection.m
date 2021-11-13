function conn_ok = test_connection(ip_addr)

    testconn_str = 'TEST_CONN';
    t = tcpip(ip_addr, 7, 'Timeout', 1);
    recv_data = [];
    try
        fopen(t);
        fwrite(t,uint8(testconn_str));
        recv_data = fread(t, 7);
        fclose(t);
        clear t;
    catch error_msg
        conn_ok = -1;
        disp(['test_connection error : ' error_msg.message]);
    end
    conn_ok = char(recv_data');
end

