library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity efectos_sonido is
    Port (
        reloj_50mhz : in  STD_LOGIC;
        puntaje     : in  integer range 0 to 64;
        fin_juego   : in  STD_LOGIC;
        zumbador    : out STD_LOGIC 
    );
end efectos_sonido;

architecture Behavioral of efectos_sonido is
    
    signal ultimo_puntaje : integer range 0 to 64 := 0;
    signal ultimo_fin     : std_logic := '0';
    
    signal div_tono       : unsigned(16 downto 0) := (others => '0');
    signal max_tono       : unsigned(16 downto 0) := (others => '0'); 
    signal duracion       : unsigned(24 downto 0) := (others => '0'); 
    
    signal reproduciendo  : std_logic := '0';
    signal reg_zumbador   : std_logic := '0';

begin

    process(reloj_50mhz)
    begin
        if rising_edge(reloj_50mhz) then
            
            if puntaje > ultimo_puntaje then
                ultimo_puntaje <= puntaje;
                max_tono <= to_unsigned(25000, 17); 
                duracion <= to_unsigned(5000000, 25); 
                reproduciendo <= '1';
            end if;
            
            if puntaje < ultimo_puntaje then
                ultimo_puntaje <= puntaje;
            end if;
            
            if fin_juego = '1' and ultimo_fin = '0' then
                max_tono <= to_unsigned(100000, 17); 
                duracion <= to_unsigned(30000000, 25); 
                reproduciendo <= '1';
            end if;
            ultimo_fin <= fin_juego;

            if reproduciendo = '1' then
                if duracion > 0 then
                    duracion <= duracion - 1;
                    div_tono <= div_tono + 1;
                    
                    if div_tono >= max_tono then
                        div_tono <= (others => '0');
                        reg_zumbador <= not reg_zumbador;
                    end if;
                else
                    reproduciendo <= '0';
                    reg_zumbador <= '0';
                end if;
            else
                reg_zumbador <= '0';
            end if;
            
        end if;
    end process;

    zumbador <= reg_zumbador;

end Behavioral;