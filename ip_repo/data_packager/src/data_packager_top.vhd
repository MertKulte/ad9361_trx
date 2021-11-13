----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.07.2020 22:06:33
-- Design Name: 
-- Module Name: data_packager_top - Behavioral
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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity data_packager_top is
    generic (
            C_S_AXI_DATA_WIDTH	: integer	:= 32;
            C_S_AXI_ADDR_WIDTH	: integer	:= 4
        );
    port ( s_clk                : in  std_logic;     
           m_clk                : in  std_logic;                     
           resetn               : in  std_logic;                    
           s_axis_tdata         : in  std_logic_vector(63 downto 0);
           s_axis_tvalid        : in  std_logic;                    
           m_axis_tdata         : out std_logic_vector(63 downto 0);
           m_axis_tvalid        : out std_logic;                    
           m_axis_tready        : in  std_logic;                    
           m_axis_tlast         : out std_logic;
           s_axi_awaddr         : in  std_logic_vector(c_s_axi_addr_width-1 downto 0);    
           s_axi_awprot         : in  std_logic_vector(2 downto 0);                       
           s_axi_awvalid        : in  std_logic;                                          
           s_axi_awready        : out std_logic;                                          
           s_axi_wdata          : in  std_logic_vector(c_s_axi_data_width-1 downto 0);    
           s_axi_wstrb          : in  std_logic_vector((c_s_axi_data_width/8)-1 downto 0);
           s_axi_wvalid         : in  std_logic;                                          
           s_axi_wready         : out std_logic;                                          
           s_axi_bresp          : out std_logic_vector(1 downto 0);                       
           s_axi_bvalid         : out std_logic;                                          
           s_axi_bready         : in  std_logic;                                          
           s_axi_araddr         : in  std_logic_vector(c_s_axi_addr_width-1 downto 0);    
           s_axi_arprot         : in  std_logic_vector(2 downto 0);                       
           s_axi_arvalid        : in  std_logic;                                          
           s_axi_arready        : out std_logic;                                          
           s_axi_rdata          : out std_logic_vector(c_s_axi_data_width-1 downto 0);    
           s_axi_rresp          : out std_logic_vector(1 downto 0);                       
           s_axi_rvalid         : out std_logic;                                          
           s_axi_rready         : in  std_logic                                                                
         );
end data_packager_top;

architecture Behavioral of data_packager_top is

    component data_packager_axi is
        generic (
            C_S_AXI_DATA_WIDTH	: integer	:= 32;
            C_S_AXI_ADDR_WIDTH	: integer	:= 4
        );
        port (
            start_transfer      : out std_logic;
            transfer_size       : out std_logic_vector(31 downto 0);
            axi_resetn          : out std_logic;
            done                : in  std_logic;   
            fifo_overflow       : in  std_logic;
            s_axi_aclk	        : in  std_logic;
            s_axi_aresetn       : in  std_logic;
            s_axi_awaddr        : in  std_logic_vector(c_s_axi_addr_width-1 downto 0);
            s_axi_awprot        : in  std_logic_vector(2 downto 0);
            s_axi_awvalid       : in  std_logic;
            s_axi_awready       : out std_logic;
            s_axi_wdata         : in  std_logic_vector(c_s_axi_data_width-1 downto 0); 
            s_axi_wstrb         : in  std_logic_vector((c_s_axi_data_width/8)-1 downto 0);
            s_axi_wvalid        : in  std_logic;
            s_axi_wready        : out std_logic;
            s_axi_bresp         : out std_logic_vector(1 downto 0);
            s_axi_bvalid        : out std_logic;
            s_axi_bready        : in  std_logic;
            s_axi_araddr        : in  std_logic_vector(c_s_axi_addr_width-1 downto 0);
            s_axi_arprot        : in  std_logic_vector(2 downto 0);
            s_axi_arvalid       : in  std_logic;
            s_axi_arready       : out std_logic;
            s_axi_rdata         : out std_logic_vector(c_s_axi_data_width-1 downto 0);
            s_axi_rresp         : out std_logic_vector(1 downto 0);
            s_axi_rvalid        : out std_logic;
            s_axi_rready        : in  std_logic
        );
    end component data_packager_axi;
    
    component data_packager_main is
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
    end component data_packager_main;
    
    signal start_transfer      : std_logic;
    signal transfer_size       : std_logic_vector(31 downto 0);
    signal axi_resetn          : std_logic;
    signal done                : std_logic;   
    signal fifo_overflow       : std_logic;
    
    signal resetn_combined     : std_logic;

begin

    resetn_combined <= resetn and axi_resetn;

    data_packager_axi_i : data_packager_axi generic map(
        C_S_AXI_DATA_WIDTH => C_S_AXI_DATA_WIDTH,
        C_S_AXI_ADDR_WIDTH => C_S_AXI_ADDR_WIDTH
    ) port map(
        start_transfer  => start_transfer,
        transfer_size   => transfer_size,
        axi_resetn      => axi_resetn,
        done            => done,
        fifo_overflow   => fifo_overflow,
        s_axi_aclk      => m_clk,
        s_axi_aresetn   => resetn_combined,
        s_axi_awaddr    => s_axi_awaddr,
        s_axi_awprot    => s_axi_awprot,
        s_axi_awvalid   => s_axi_awvalid,
        s_axi_awready   => s_axi_awready,
        s_axi_wdata     => s_axi_wdata,
        s_axi_wstrb     => s_axi_wstrb,
        s_axi_wvalid    => s_axi_wvalid,
        s_axi_wready    => s_axi_wready,
        s_axi_bresp     => s_axi_bresp,
        s_axi_bvalid    => s_axi_bvalid,
        s_axi_bready    => s_axi_bready,
        s_axi_araddr    => s_axi_araddr,
        s_axi_arprot    => s_axi_arprot,
        s_axi_arvalid   => s_axi_arvalid,
        s_axi_arready   => s_axi_arready,
        s_axi_rdata     => s_axi_rdata,
        s_axi_rresp     => s_axi_rresp,
        s_axi_rvalid    => s_axi_rvalid,
        s_axi_rready    => s_axi_rready
    );
    
    data_packager_main_i : data_packager_main port map(
        s_clk           => s_clk,         
        m_clk           => m_clk,
        resetn          => resetn_combined,
        s_axis_tdata    => s_axis_tdata,
        s_axis_tvalid   => s_axis_tvalid,
        m_axis_tdata    => m_axis_tdata,
        m_axis_tvalid   => m_axis_tvalid,
        m_axis_tready   => m_axis_tready,
        m_axis_tlast    => m_axis_tlast,
        start_transfer  => start_transfer,
        transfer_size   => transfer_size, 
        axi_resetn      => axi_resetn,    
        done            => done,          
        fifo_overflow   => fifo_overflow 
    );

end Behavioral;
