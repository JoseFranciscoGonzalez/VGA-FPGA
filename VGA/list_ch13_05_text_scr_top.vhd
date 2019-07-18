-- Listing 13.5
library ieee;
use ieee.std_logic_1164.all;
entity text_screen_top is
   generic(
      BAUD_RATE: integer := 115200;    -- Baud rate
      CLOCK_RATE: integer := 50E6
   );
   port(
      clk,reset: in std_logic;
      rxd_pin: in std_logic;
      hsync, vsync: out  std_logic;
      rgb: out std_logic_vector(2 downto 0)
   );
end text_screen_top;

architecture arch of text_screen_top is
   signal pixel_x, pixel_y: std_logic_vector(9 downto 0);
   signal video_on, pixel_tick: std_logic;
   signal rgb_reg, rgb_next: std_logic_vector(2 downto 0);
   signal writeEnable: std_logic;
   signal dataIN: std_logic_vector(7 downto 0);
begin
   -- instantiate VGA sync circuit
   vga_sync_unit: entity work.vga_sync
      port map(clk=>clk, reset=>reset,
               hsync=>hsync, vsync=>vsync,
               video_on=>video_on, p_tick=>pixel_tick,
               pixel_x=>pixel_x, pixel_y=>pixel_y);
   
   uart_rx: entity work.uart 
      port map(
      clk => clk,
      reset => reset,
      rx => rxd_pin,
      r_data => dataIN,
      rx_ready => writeEnable
       );
   -- instantiate full-screen text generator
   text_gen_unit: entity work.text_screen_gen
      port map(clk=>clk, reset=>reset, writeEnable=>writeEnable, dataIN=>dataIN(6 downto 0),
               video_on=>video_on, pixel_x=>pixel_x,
               pixel_y=>pixel_y, text_rgb=>rgb_next);
   -- rgb buffer
   process (clk)
   begin
      if (clk'event and clk='1') then
         if (pixel_tick='1') then
            rgb_reg <= rgb_next;
         end if;
      end if;
   end process;
   rgb <= rgb_reg;
end arch;