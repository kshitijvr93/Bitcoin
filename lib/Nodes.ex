defmodule Nodes do
    use GenServer

    def start_link(_,data2) do# works!!
        #IO.puts("hey2")

        
        [selfNum,highestNodePossible]=data2
        id="id#{selfNum}"
        IO.puts("#{selfNum} is about to start!")
        
        GenServer.start_link(__MODULE__,data2,name: :"#{id}")# for zero the maxNodes
    end
    
    def genPrivateKey() do
        private_key = :crypto.strong_rand_bytes(32)
        a=:binary.decode_unsigned(<<
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFE,
            0xBA, 0xAE, 0xDC, 0xE6, 0xAF, 0x48, 0xA0, 0x3B,
            0xBF, 0xD2, 0x5E, 0x8C, 0xD0, 0x36, 0x41, 0x41
            >>)
        if private_key>1 and private_key<a do

        else
            genPrivateKey()
        end

    end
   
   
    def handle_cast({:setFailureMod,failModulo},state) do
       IO.inspect(state)
        {:noreply,state}
    end

end