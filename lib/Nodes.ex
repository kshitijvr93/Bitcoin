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
        state = 
        if selfNum==0 do
            data2
        else
            wallet_value = 5
            current_transaction_pool_list = []
            ledger = []
            transactionsNewBlockWork = []
            [selfNum,highestNodePossible,keys,wallet_value, transactionsNewBlockWork,current_transaction_pool_list, ledger]
        end
        
        GenServer.start_link(__MODULE__,state,name: :"#{id}")# for zero the maxNodes
    end

    def handle_cast({:receivetransactionList, transacList},state) do #for !0
        IO.puts("receivetransactionList")
        IO.inspect(state)
        [selfNum,highestNodePossible,keys,wallet_value, transactionsNewBlockWork ,current_transaction_pool_list, ledger] = state
        current_transaction_pool_list= current_transaction_pool_list++ transacList
         state =  [selfNum,highestNodePossible,keys,wallet_value, transactionsNewBlockWork,current_transaction_pool_list, ledger]
         
        
       
        {:noreply,state}
    end

     def handle_cast(:generateBlock,state) do #for 0
        # IO.puts("generateBlock")
        [selfNum,highestNodePossible,keys,wallet_value, transactionsNewBlockWork, current_transaction_pool_list, ledger] = state

         #state =  [selfNum,highestNodePossible,keys,wallet_value, transactionsNewBlockWork, transacList, ledger]
         state=
         if length(transactionsNewBlockWork) == 0 do
            if length(current_transaction_pool_list) == 0 do
                # IO.puts("1")
                GenServer.cast(:"id#{selfNum}",:generateBlock)
                state
            else
                # IO.puts("1")
                GenServer.cast(:"id#{selfNum}",{:mineCoin,current_transaction_pool_list,:rand.uniform(10000000),System.system_time(:millisecond)})
                state =  [selfNum,highestNodePossible,keys,wallet_value, current_transaction_pool_list, [], ledger]
                
                state
            end
         else
            # IO.puts("1")
            # GenServer.cast(:"id#{selfNum}",{:mineCoin,current_transaction_pool_list,:rand.uniform(10000000),System.system_time(:millisecond)})
            # state =  [selfNum,highestNodePossible,keys,wallet_value, current_transaction_pool_list, [], ledger]
            
            state
         end
        
        {:noreply,state}
        
    end
    
    def handle_call(:generateBlockStart,_from,state) do
        Enum.each(1..100,fn(x)->
            GenServer.cast(:"id#{x}",:generateBlock)
        end)

        {:reply,state,state}
    end

    def handle_cast({:mineCoin,data,currentNonce,startTime},state) do
        # IO.puts("mineCoin")
        [selfNum,highestNodePossible,keys,wallet_value, transactionsNewBlockWork, current_transaction_pool_list, ledger] = state
        
        state =
        if transactionsNewBlockWork == data do
            
            concatData= concatTransactions(data,"")

            hashValue = Base.encode16(:crypto.hash(:sha256,concatData<>to_string(currentNonce)))
            # =Base.encode32(:crypto.hash(:sha256,"hello"<>to_string(108)))
           
            if String.slice(hashValue,0,4) == "0000" do
                IO.puts(hashValue)
                IO.puts(currentNonce)
                IO.puts(System.system_time(:millisecond)-startTime)

                blockData = concatData<>"|| the current NONCE is #{currentNonce} "
                blockHeader = ""
                block = {blockHeader,blockData}
                ledger = ledger ++ [block]
                GenServer.cast(:"id#{selfNum}",{:mineCoin,data,currentNonce+1,startTime})
                [selfNum,highestNodePossible,keys,wallet_value, [], current_transaction_pool_list, ledger]
                ##### to fill
            else           
                GenServer.cast(:"id#{selfNum}",{:mineCoin,data,currentNonce+1,startTime})
                state
            end
        
        else
            GenServer.cast(:"id#{selfNum}",:generateBlock)
            state

        end
        
        
        {:noreply,state}

    end
    
    def concatTransactions(transactionsNewBlockWork, mergedTransactions) do
        # IO.puts("concatTransactions")
        if length(transactionsNewBlockWork) >0 do
            current = Enum.at(transactionsNewBlockWork,0)
            mergedTransactions= mergedTransactions<>"||"<>current
            concatTransactions(transactionsNewBlockWork--[current],mergedTransactions)
        else
            mergedTransactions
        end
    end
    
    def handle_call(:getState,_from,state) do
        IO.inspect(state)

        {:reply,state,state}
    end

    def handle_cast({:createDummyValues,counter,w8time,transactionNumber},state) do #for 0
         IO.puts("createDummyValues!!")
        if counter > 0 do
            if System.system_time(:millisecond) - w8time >10000 do
                transactionList = generateRandomTransactions(:rand.uniform(5),[])
                IO.inspect(transactionList)
                spreadTransactions(1,100,transactionList)

                GenServer.cast(:id0,{:createDummyValues,counter-1,System.system_time(:millisecond),transactionNumber+length(transactionList)})
            else
                GenServer.cast(:id0,{:createDummyValues,counter,w8time,transactionNumber})
            end
       
        end

        {:noreply,state}
    end
    
    def spreadTransactions(current, max, transactionList) do
        IO.puts("spreadTransactions running")
        if current<=max do
            GenServer.cast(:"id#{current}",{:receivetransactionList,transactionList})
            spreadTransactions(current+1, max, transactionList)
        end

    end


    def generateRandomTransactions(transNum, transactionList) do
        if transNum == 0 do
            transactionList
        else
            senderNode = :rand.uniform(99)+1
            receiverNode = :rand.uniform(99)+1
            money = :rand.uniform(1000)
            dummyString = "#{senderNode} #{money} #{receiverNode}"
            transactionList = transactionList ++ [dummyString]
            generateRandomTransactions(transNum-1, transactionList)
        end
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


    

end