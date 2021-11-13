----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/07/2021 11:25:59 PM
-- Design Name: 
-- Module Name: ad9361_tx_signal_gen_top - Behavioral
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

entity ad9361_tx_signal_gen_top is
    generic (
        C_S_AXI_DATA_WIDTH  : integer   := 32;
        C_S_AXI_ADDR_WIDTH  : integer   := 4
    );
    Port ( 
        dac_clk         : in  std_logic;
        dac_data_i0     : out std_logic_vector(15 downto 0);
        dac_data_q0     : out std_logic_vector(15 downto 0);
        dac_data_i1     : out std_logic_vector(15 downto 0);
        dac_data_q1     : out std_logic_vector(15 downto 0);
        s_axi_aclk      : in  std_logic;
        s_axi_aresetn   : in  std_logic;
        s_axi_awaddr    : in std_logic_vector(c_s_axi_addr_width-1 downto 0);
        s_axi_awprot    : in std_logic_vector(2 downto 0);
        s_axi_awvalid   : in std_logic;
        s_axi_awready   : out std_logic;
        s_axi_wdata     : in std_logic_vector(c_s_axi_data_width-1 downto 0);
        s_axi_wstrb     : in std_logic_vector((c_s_axi_data_width/8)-1 downto 0);
        s_axi_wvalid    : in std_logic;
        s_axi_wready    : out std_logic;
        s_axi_bresp     : out std_logic_vector(1 downto 0);
        s_axi_bvalid    : out std_logic;
        s_axi_bready    : in std_logic;
        s_axi_araddr    : in std_logic_vector(c_s_axi_addr_width-1 downto 0);
        s_axi_arprot    : in std_logic_vector(2 downto 0);
        s_axi_arvalid   : in std_logic;
        s_axi_arready   : out std_logic;
        s_axi_rdata     : out std_logic_vector(c_s_axi_data_width-1 downto 0);
        s_axi_rresp     : out std_logic_vector(1 downto 0);
        s_axi_rvalid    : out std_logic;
        s_axi_rready    : in std_logic
    );
end ad9361_tx_signal_gen_top;

architecture behavioral of ad9361_tx_signal_gen_top is

    component ad9361_tx_signal_gen_axi is
        generic (
            C_S_AXI_DATA_WIDTH  : integer   := 32;
            C_S_AXI_ADDR_WIDTH  : integer   := 4
        );
        port (
            tx0_out_en      : out std_logic;
            tx1_out_en      : out std_logic;
            tx0_sample_size : out std_logic_vector(11 downto 0);
            tx1_sample_size : out std_logic_vector(11 downto 0);
            tx0_data_wen    : out std_logic;
            tx0_data        : out std_logic_vector(31 downto 0);
            tx0_addr        : out std_logic_vector(11 downto 0);
            tx1_data_wen    : out std_logic;
            tx1_data        : out std_logic_vector(31 downto 0);
            tx1_addr        : out std_logic_vector(11 downto 0);
            axi_resetn      : out std_logic;
            s_axi_aclk      : in  std_logic;
            s_axi_aresetn   : in  std_logic;
            s_axi_awaddr    : in std_logic_vector(c_s_axi_addr_width-1 downto 0);      
            s_axi_awprot    : in std_logic_vector(2 downto 0);                         
            s_axi_awvalid   : in std_logic;                                            
            s_axi_awready   : out std_logic;                                           
            s_axi_wdata     : in std_logic_vector(c_s_axi_data_width-1 downto 0);      
            s_axi_wstrb     : in std_logic_vector((c_s_axi_data_width/8)-1 downto 0);  
            s_axi_wvalid    : in std_logic;                                            
            s_axi_wready    : out std_logic;                                           
            s_axi_bresp     : out std_logic_vector(1 downto 0);                        
            s_axi_bvalid    : out std_logic;                                           
            s_axi_bready    : in std_logic;                                            
            s_axi_araddr    : in std_logic_vector(c_s_axi_addr_width-1 downto 0);      
            s_axi_arprot    : in std_logic_vector(2 downto 0);                         
            s_axi_arvalid   : in std_logic;                                            
            s_axi_arready   : out std_logic;                                           
            s_axi_rdata     : out std_logic_vector(c_s_axi_data_width-1 downto 0);     
            s_axi_rresp     : out std_logic_vector(1 downto 0);                        
            s_axi_rvalid    : out std_logic;                                           
            s_axi_rready    : in std_logic                                             
        );
    end component ad9361_tx_signal_gen_axi;

    component ad9361_tx_signal_gen_main is
        port ( 
            aclk            : in  std_logic;
            aresetn         : in  std_logic;
            dac_clk         : in  std_logic;
            tx0_out_en      : in  std_logic;
            tx1_out_en      : in  std_logic;
            tx0_sample_size : in  std_logic_vector(11 downto 0);
            tx1_sample_size : in  std_logic_vector(11 downto 0);
            tx0_data_wen    : in  std_logic;
            tx0_data        : in  std_logic_vector(31 downto 0);
            tx0_addr        : in  std_logic_vector(11 downto 0);
            tx1_data_wen    : in  std_logic;
            tx1_data        : in  std_logic_vector(31 downto 0);
            tx1_addr        : in  std_logic_vector(11 downto 0);
            dac_data_i0     : out std_logic_vector(15 downto 0);
            dac_data_q0     : out std_logic_vector(15 downto 0);
            dac_data_i1     : out std_logic_vector(15 downto 0);
            dac_data_q1     : out std_logic_vector(15 downto 0)
        );
    end component ad9361_tx_signal_gen_main;

    signal axi_aresetn      : std_logic;

    signal tx0_out_en       : std_logic;
    signal tx1_out_en       : std_logic;
    signal tx0_sample_size  : std_logic_vector(11 downto 0);
    signal tx1_sample_size  : std_logic_vector(11 downto 0);
    signal tx0_data_wen     : std_logic;
    signal tx0_data         : std_logic_vector(31 downto 0);
    signal tx0_addr         : std_logic_vector(11 downto 0);
    signal tx1_data_wen     : std_logic;
    signal tx1_data         : std_logic_vector(31 downto 0);
    signal tx1_addr         : std_logic_vector(11 downto 0);

begin

    ad9361_tx_signal_gen_axi_i : ad9361_tx_signal_gen_axi generic map(
        C_S_AXI_DATA_WIDTH  => 32,
        C_S_AXI_ADDR_WIDTH  => 4
    ) port map(
        tx0_out_en      => tx0_out_en,        
        tx1_out_en      => tx1_out_en,     
        tx0_sample_size => tx0_sample_size,
        tx1_sample_size => tx1_sample_size,
        tx0_data_wen    => tx0_data_wen,   
        tx0_data        => tx0_data,       
        tx0_addr        => tx0_addr,       
        tx1_data_wen    => tx1_data_wen,   
        tx1_data        => tx1_data,       
        tx1_addr        => tx1_addr,       
        axi_resetn      => axi_aresetn,
        s_axi_aclk      => s_axi_aclk,   
        s_axi_aresetn   => s_axi_aresetn,
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

    ad9361_tx_signal_gen_main_i : ad9361_tx_signal_gen_main port map(
        aclk            => s_axi_aclk,
        aresetn         => axi_aresetn,
        dac_clk         => dac_clk,
        tx0_out_en      => tx0_out_en,     
        tx1_out_en      => tx1_out_en,     
        tx0_sample_size => tx0_sample_size,
        tx1_sample_size => tx1_sample_size,
        tx0_data_wen    => tx0_data_wen,   
        tx0_data        => tx0_data,       
        tx0_addr        => tx0_addr,       
        tx1_data_wen    => tx1_data_wen,   
        tx1_data        => tx1_data,       
        tx1_addr        => tx1_addr,       
        dac_data_i0     => dac_data_i0,
        dac_data_q0     => dac_data_q0,
        dac_data_i1     => dac_data_i1,
        dac_data_q1     => dac_data_q1
    );


end behavioral;
