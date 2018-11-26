defmodule Nodes do
    use GenServer

    def start_link(_,data2) do# works!!
        #IO.puts("hey2")
        [selfNum,highestNodePossible]=data2
        IO.puts("#{selfNum} is about to start!")
        {public_key,private_key} = :crypto.generate_key(:ecdh, :brainpoolP512r1)# gen key pair ecdh with elliptical curves as
        
        keys = [public_key,private_key]
        data2= [selfNum,highestNodePossible,keys]
        id="id#{selfNum}"
        
        
        GenServer.start_link(__MODULE__,data2,name: :"#{id}")# for zero the maxNodes
    end
    
    # def genPrivateKey() do

    #     private_key = :crypto.strong_rand_bytes(32)
    #     a=:binary.decode_unsigned(<<
    #         0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
    #         0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFE,
    #         0xBA, 0xAE, 0xDC, 0xE6, 0xAF, 0x48, 0xA0, 0x3B,
    #         0xBF, 0xD2, 0x5E, 0x8C, 0xD0, 0x36, 0x41, 0x41
    #         >>)

    #     private_key_binary = :binary.decode_unsigned(private_key)
    #     if private_key_binary>1 and private_key_binary<a do
    #         private_key
    #     else
    #         genPrivateKey()
    #     end

    # end

    # def genPublicKey(private_key) do
    #    elem(:crypto.generate_key(:ecdh, :crypto.ec_curve(:secp256k1), private_key),0)
    # end
    def genPublicPrivateKeys() do
        :crypto.generate_key(:ecdh, :brainpoolP512r1)
    end
   
    def handle_cast({:setFailureMod,failModulo},state) do
        # xx=genPrivateKey()
        # IO.inspect(xx)
       IO.inspect(state)
        {:noreply,state}
    end

    def handle_call({:setFailureMod},_from,state) do
        # xx=genPrivateKey()
        # IO.inspect(xx)
       IO.inspect(state)
        {:reply,state,state}
    end


    def handle_cast({:mineCoin,data,numberOfZero,currentNonce,startTime},state) do
       
        hashValue = Base.encode16(:crypto.hash(:sha256,data<>to_string(currentNonce)))
        # =Base.encode32(:crypto.hash(:sha256,"hello"<>to_string(108)))
        [selfNum,_,_]=state
        if String.slice(hashValue,0,4) == "0000" do
            IO.puts(hashValue)
            IO.puts(currentNonce)
            IO.puts(System.system_time(:millisecond)-startTime)
        else
            GenServer.cast(:"id#{selfNum}",{:mineCoin,data,numberOfZero,currentNonce+1,startTime})
        end
        {:noreply,state}
    end

end