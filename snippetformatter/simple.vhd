

enTiTy simple is --comment
	poRt 
	(
		a_in : in std_logic; --comment
		b_out : out std_logic
	);
end;

architecture a of simple is
begin
	process
	begin
		a.b_in <= a;
	end process; 
end;
