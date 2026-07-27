library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity spi_max7219 is
    Port (
        reloj_1mhz : in  STD_LOGIC;
        reinicio   : in  STD_LOGIC;
        datos_in   : in  STD_LOGIC_VECTOR(63 downto 0);
        din        : out STD_LOGIC;
        cs         : buffer STD_LOGIC;
        reloj_out  : out STD_LOGIC
    );
end spi_max7219;

architecture Behavioral of spi_max7219 is
    type tipo_estado is (INICIO_ARRANQUE, INICIO_ENVIO, ESPERA, CARGAR_FILA, ENVIAR_BITS, GUARDAR);
    signal estado : tipo_estado := INICIO_ARRANQUE;
    
    signal cont_bits : integer range 0 to 15 := 15;
    signal cont_fila : integer range 1 to 8 := 1;
    signal reg_desplazamiento : STD_LOGIC_VECTOR(15 downto 0);
    
    signal paso_inicio : integer range 0 to 4 := 0;
    type arreglo_inicio is array (0 to 3) of std_logic_vector(15 downto 0);
    constant comandos_inicio : arreglo_inicio := (
        x"0900", x"0A07", x"0B07", x"0C01" 
    );
begin
    reloj_out <= reloj_1mhz when cs = '0' else '0';

    process(reloj_1mhz, reinicio)
    begin
        if reinicio = '1' then
            estado <= INICIO_ARRANQUE;
            cs <= '1';
            din <= '0';
            paso_inicio <= 0;
            cont_fila <= 1;
        elsif falling_edge(reloj_1mhz) then 
            case estado is
                when INICIO_ARRANQUE =>
                    if paso_inicio < 4 then
                        reg_desplazamiento <= comandos_inicio(paso_inicio);
                        cont_bits <= 15;
                        cs <= '0';
                        estado <= INICIO_ENVIO;
                    else
                        estado <= ESPERA;
                    end if;
                    
                when INICIO_ENVIO =>
                    din <= reg_desplazamiento(cont_bits);
                    if cont_bits = 0 then
                        estado <= GUARDAR;
                    else
                        cont_bits <= cont_bits - 1;
                    end if;
                    
                when ESPERA =>
                    cs <= '1';
                    estado <= CARGAR_FILA;
                    
                when CARGAR_FILA =>
                    cs <= '0';
                    reg_desplazamiento <= std_logic_vector(to_unsigned(cont_fila, 8)) & 
                                 datos_in( (9-cont_fila)*8 - 1 downto (8-cont_fila)*8 );
                    cont_bits <= 15;
                    estado <= ENVIAR_BITS;
                    
                when ENVIAR_BITS =>
                    din <= reg_desplazamiento(cont_bits); 
                    if cont_bits = 0 then
                        estado <= GUARDAR;
                    else
                        cont_bits <= cont_bits - 1;
                    end if;
                    
                when GUARDAR =>
                    cs <= '1';
                    if paso_inicio < 4 then
                        paso_inicio <= paso_inicio + 1;
                        estado <= INICIO_ARRANQUE;
                    else
                        if cont_fila = 8 then
                            cont_fila <= 1;
                        else
                            cont_fila <= cont_fila + 1;
                        end if;
                        estado <= ESPERA;
                    end if;
            end case;
        end if;
    end process;
end Behavioral;