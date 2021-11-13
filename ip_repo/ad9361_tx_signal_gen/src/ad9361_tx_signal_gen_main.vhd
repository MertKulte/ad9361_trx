----------------------------------------------------------------------------------
-- company: 
-- engineer: 
-- 
-- create date: 10/07/2021 11:26:28 pm
-- design name: 
-- module name: ad9361_tx_signal_gen_main - behavioral
-- project name: 
-- target devices: 
-- tool versions: 
-- description: 
-- 
-- dependencies: 
-- 
-- revision:
-- revision 0.01 - file created
-- additional comments:
-- 
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library xpm;
use xpm.vcomponents.all;

entity ad9361_tx_signal_gen_main is
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
end ad9361_tx_signal_gen_main;

architecture behavioral of ad9361_tx_signal_gen_main is

    component blk_mem_gen_0
        port (
            clka    : in  std_logic;
            wea     : in  std_logic_vector(0 downto 0);
            addra   : in  std_logic_vector(11 downto 0);
            dina    : in  std_logic_vector(23 downto 0);
            douta   : out std_logic_vector(23 downto 0);
            clkb    : in  std_logic;
            web     : in  std_logic_vector(0 downto 0);
            addrb   : in  std_logic_vector(11 downto 0);
            dinb    : in  std_logic_vector(23 downto 0);
            doutb   : out std_logic_vector(23 downto 0)
        );
    end component;

    signal tx0_dout : std_logic_vector(23 downto 0); 
    signal tx1_dout : std_logic_vector(23 downto 0);

    signal tx0_addrb    : std_logic_vector(11 downto 0);
    signal tx1_addrb    : std_logic_vector(11 downto 0);

    signal cdc_din  : std_logic_vector(25 downto 0);
    signal cdc_dout : std_logic_vector(25 downto 0);

    signal tx0_sample_size_int  : integer range 1 to 4096;
    signal tx1_sample_size_int  : integer range 1 to 4096;

    signal tx0_out_counter  : integer range 0 to 4095   := 0;
    signal tx1_out_counter  : integer range 0 to 4095   := 0;

    signal tx0_out_en_dacclk    : std_logic;
    signal tx1_out_en_dacclk    : std_logic;
    
    signal blkmem_din_0     : std_logic_vector(23 downto 0);
    signal blkmem_din_1     : std_logic_vector(23 downto 0);

begin

    output_gen : process(dac_clk) begin
        if(rising_edge(dac_clk)) then
            if(tx0_out_counter >= tx0_sample_size_int-1) then
                tx0_out_counter <= 0;
            else
                tx0_out_counter <= tx0_out_counter + 1;
            end if;
            if(tx1_out_counter >= tx1_sample_size_int-1) then
                tx1_out_counter <= 0;
            else
                tx1_out_counter <= tx1_out_counter + 1;
            end if;
        end if;
    end process output_gen;

    dac_data_i0 <= tx0_dout(11) & tx0_dout(11) & tx0_dout(11) & tx0_dout(11) & tx0_dout(11 downto 0) when tx0_out_en_dacclk = '1' else (others => '0');
    dac_data_q0 <= tx0_dout(23) & tx0_dout(23) & tx0_dout(23) & tx0_dout(23) & tx0_dout(23 downto 12) when tx0_out_en_dacclk = '1' else (others => '0');
    dac_data_i1 <= tx1_dout(11) & tx1_dout(11) & tx1_dout(11) & tx1_dout(11) & tx1_dout(11 downto 0) when tx1_out_en_dacclk = '1' else (others => '0');
    dac_data_q1 <= tx1_dout(23) & tx1_dout(23) & tx1_dout(23) & tx1_dout(23) & tx1_dout(23 downto 12) when tx1_out_en_dacclk = '1' else (others => '0');

    tx0_addrb <= std_logic_vector(to_unsigned(tx0_out_counter,12));
    tx1_addrb <= std_logic_vector(to_unsigned(tx1_out_counter,12));

    cdc_din             <= tx1_out_en & tx0_out_en & tx1_sample_size & tx0_sample_size;
    tx0_sample_size_int <= to_integer(unsigned(cdc_dout(11 downto 0)))+1;
    tx1_sample_size_int <= to_integer(unsigned(cdc_dout(23 downto 12)))+1;
    tx0_out_en_dacclk   <= cdc_dout(24);
    tx1_out_en_dacclk   <= cdc_dout(25);
    
    blkmem_din_0 <= tx0_data(27 downto 16) & tx0_data(11 downto 0);
    blkmem_din_1 <= tx1_data(27 downto 16) & tx1_data(11 downto 0);

    blk_mem_gen_tx0 : blk_mem_gen_0 port map(
        clka    => aclk,
        wea(0)  => tx0_data_wen,
        addra   => tx0_addr,
        dina    => blkmem_din_0,
        douta   => open,
        clkb    => dac_clk,
        web     => "0",
        addrb   => tx0_addrb,
        dinb    => (others => '0'),
        doutb   => tx0_dout
    );

    blk_mem_gen_tx1 : blk_mem_gen_0 port map(
        clka    => aclk,
        wea(0)  => tx1_data_wen,
        addra   => tx1_addr,
        dina    => blkmem_din_1,
        douta   => open,
        clkb    => dac_clk,
        web     => "0",
        addrb   => tx1_addrb,
        dinb    => (others => '0'),
        doutb   => tx1_dout
    );

    cdc_inst : xpm_cdc_array_single generic map (
        DEST_SYNC_FF    => 10,  
        INIT_SYNC_FF    => 0,   
        SIM_ASSERT_CHK  => 0, 
        SRC_INPUT_REG   => 1,  
        WIDTH           => 26          
    ) port map (
        dest_out    => cdc_dout, 
        dest_clk    => dac_clk,
        src_clk     => aclk,   
        src_in      => cdc_din 
    );

end behavioral;
