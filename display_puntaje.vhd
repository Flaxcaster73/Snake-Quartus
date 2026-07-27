library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity display_puntaje is
    Port (
        reloj_50mhz : in  STD_LOGIC;
        puntaje     : in  integer range 0 to 64;
        puntaje_max : in  integer range 0 to 64;
        segmentos   : out STD_LOGIC_VECTOR (7 downto 0); 
        digitos     : out STD_LOGIC_VECTOR (3 downto 0)  
    );
end display_puntaje;

architecture Behavioral of display_puntaje is

    signal cont_refresco : unsigned(16 downto 0) := (others => '0');
    signal digito_activo : unsigned(1 downto 0); 
    signal valor_actual  : integer range 0 to 9 := 0;
    
    signal dec_actual, uni_actual  : integer range 0 to 9 := 0;
    signal dec_record, uni_record  : integer range 0 to 9 := 0;

    function decodificar_7seg(num : integer) return std_logic_vector is
    begin
        case num is
            when 0 => return "11000000"; 
            when 1 => return "11111001"; 
            when 2 => return "10100100"; 
            when 3 => return "10110000"; 
            when 4 => return "10011001"; 
            when 5 => return "10010010"; 
            when 6 => return "10000010"; 
            when 7 => return "11111000"; 
            when 8 => return "10000000"; 
            when 9 => return "10010000"; 
            when others => return "11111111";
        end case;
    end function;

begin

    dec_actual <= puntaje / 10;
    uni_actual <= puntaje mod 10;
    

    dec_record <= puntaje_max / 10; 
    uni_record <= puntaje_max mod 10;

    process(reloj_50mhz)
    begin
        if rising_edge(reloj_50mhz) then
            cont_refresco <= cont_refresco + 1;
        end if;
    end process;
    
    digito_activo <= cont_refresco(16 downto 15);

    process(digito_activo, dec_actual, uni_actual, dec_record, uni_record)
    begin
        case digito_activo is
            when "00" =>
                digitos <= "1110";         
                valor_actual <= uni_actual; 
            when "01" =>
                digitos <= "1101";         
                valor_actual <= dec_actual; 
            when "10" =>
                digitos <= "1011";         
                valor_actual <= uni_record; 
            when "11" =>
                digitos <= "0111";         
                valor_actual <= dec_record; 
            when others =>
                digitos <= "1111";
                valor_actual <= 0;
        end case;
    end process;

    segmentos <= decodificar_7seg(valor_actual);

end Behavioral;