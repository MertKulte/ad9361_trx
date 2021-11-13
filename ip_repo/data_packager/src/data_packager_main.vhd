----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.07.2020 22:06:33
-- Design Name: 
-- Module Name: data_packager_main - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_packager_main is
    port ( s_clk            : in  std_logic;
           m_clk            : in  std_logic;
           resetn           : in  std_logic;
           s_axis_tdata     : in  std_logic_vector(63 downto 0);
           s_axis_tvalid    : in  std_logic;
           m_axis_tdata     : out std_logic_vector(63 downto 0); 
           m_axis_tvalid    : out std_logic;
           m_axis_tready    : in  std_logic;
           m_axis_tlast     : out std_logic;
           start_transfer   : in  std_logic;
           transfer_size    : in  std_logic_vector(31 downto 0);
           axi_resetn       : in  std_logic;
           done             : out std_logic;
           fifo_overflow    : out std_logic
         );
end data_packager_main;

architecture behavioral of data_packager_main is

    component data_packager_async_fifo
        port (
            wr_rst_busy     : out std_logic;
            rd_rst_busy     : out std_logic;
            m_aclk          : in  std_logic;
            s_aclk          : in  std_logic;
            s_aresetn       : in  std_logic;
            s_axis_tvalid   : in  std_logic;
            s_axis_tready   : out std_logic;
            s_axis_tdata    : in  std_logic_vector(63 downto 0);
            m_axis_tvalid   : out std_logic;
            m_axis_tready   : in  std_logic;
            m_axis_tdata    : out std_logic_vector(63 downto 0)
        );
    end component;
    
    component data_packager_sync_fifo
        port (
            wr_rst_busy     : out std_logic;
            rd_rst_busy     : out std_logic;
            s_aclk          : in  std_logic;
            s_aresetn       : in  std_logic;
            s_axis_tvalid   : in  std_logic;
            s_axis_tready   : out std_logic;
            s_axis_tdata    : in  std_logic_vector(63 downto 0);
            s_axis_tlast    : in  std_logic;
            m_axis_tvalid   : out std_logic;
            m_axis_tready   : in  std_logic;
            m_axis_tdata    : out std_logic_vector(63 downto 0);
            m_axis_tlast    : out std_logic
        );
    end component;
    
    signal data_counter                 : integer                           := 0;
    
    signal fifo_async_m_axis_tdata      : std_logic_vector(63 downto 0);
    signal fifo_async_m_axis_tvalid     : std_logic;
    
    signal fifo_sync_s_axis_tdata       : std_logic_vector(63 downto 0)     := (others => '0');
    signal fifo_sync_s_axis_tvalid      : std_logic                         := '1';
    signal fifo_sync_s_axis_tready      : std_logic;
    signal fifo_sync_s_axis_tlast       : std_logic                         := '0';
    
    type state_type is (RESET, IDLE, START_TRANS, TRANSFER_COMPLETED); 
    signal state                        : state_type                        := RESET;    
    
    signal transfer_size_int            : integer                           := 1024;
    
    signal resetn_combined              : std_logic;

begin

    resetn_combined <= resetn and axi_resetn;

    main_process : process (m_clk) begin
        if(rising_edge(m_clk)) then
            if(resetn_combined = '0') then
                data_counter        <= 0;
                state               <= RESET;
                fifo_sync_s_axis_tdata   <= (others => '0');
                fifo_sync_s_axis_tvalid  <= '0';
                fifo_sync_s_axis_tlast   <= '0';
                done                <= '0';     
            else
                case state is
                    when RESET =>
                        data_counter        <= 0;
                        state               <= IDLE;
                        fifo_sync_s_axis_tdata   <= (others => '0');
                        fifo_sync_s_axis_tvalid  <= '0';
                        fifo_sync_s_axis_tlast   <= '0';
                        done                <= '0';
                    when IDLE => 
                        transfer_size_int <= to_integer(unsigned(transfer_size));
                        if(start_transfer = '1') then  
                            state               <= START_TRANS;
                        end if;
                    when START_TRANS =>
                        if(fifo_async_m_axis_tvalid = '1') then
                            if(data_counter = transfer_size_int-1) then
                                data_counter        <= 0;
                                fifo_sync_s_axis_tlast   <= '1';
                                state               <= TRANSFER_COMPLETED;
                            else
                                data_counter        <= data_counter + 1;
                                fifo_sync_s_axis_tlast   <= '0';
                            end if;
                            fifo_sync_s_axis_tdata   <= fifo_async_m_axis_tdata;
                            fifo_sync_s_axis_tvalid  <= '1';                       
                        else
                            fifo_sync_s_axis_tvalid  <= '0';      
                        end if;
                    when TRANSFER_COMPLETED =>
                        fifo_sync_s_axis_tvalid  <= '0'; 
                        fifo_sync_s_axis_tlast   <= '0';
                        done                <= '1';
                        if(start_transfer = '0') then
                            state           <= IDLE;
                            done            <= '0';
                        end if;
                    when others =>
                        state           <= RESET;
                end case;
            end if;
        end if;
    end process main_process;
    
    fifo_overflow_detect : process (m_clk) begin
        if(rising_edge(m_clk)) then
            if(resetn_combined = '0') then
                fifo_overflow <= '0';
            else
                if(fifo_sync_s_axis_tvalid = '1' and fifo_sync_s_axis_tready = '0') then
                    fifo_overflow <= '1';
                end if;
            end if;
        end if;
    end process fifo_overflow_detect;
    
    data_packager_async_fifo_i : data_packager_async_fifo port map(
        wr_rst_busy     => open,   
        rd_rst_busy     => open,
        m_aclk          => m_clk,
        s_aclk          => s_clk,
        s_aresetn       => '1',
        s_axis_tvalid   => s_axis_tvalid,
        s_axis_tready   => open,
        s_axis_tdata    => s_axis_tdata,
        m_axis_tvalid   => fifo_async_m_axis_tvalid,
        m_axis_tready   => '1',
        m_axis_tdata    => fifo_async_m_axis_tdata
    );
    
    data_packager_sync_fifo_i : data_packager_sync_fifo port map(
        wr_rst_busy     => open,  
        rd_rst_busy     => open,
        s_aclk          => m_clk,
        s_aresetn       => resetn_combined,
        s_axis_tvalid   => fifo_sync_s_axis_tvalid,
        s_axis_tready   => fifo_sync_s_axis_tready,
        s_axis_tdata    => fifo_sync_s_axis_tdata,
        s_axis_tlast    => fifo_sync_s_axis_tlast, 
        m_axis_tvalid   => m_axis_tvalid,
        m_axis_tready   => m_axis_tready,
        m_axis_tdata    => m_axis_tdata, 
        m_axis_tlast    => m_axis_tlast
    );

end behavioral;
