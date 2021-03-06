defmodule Nodes do
    use GenServer

    def start_link(_,data2) do# works!!
        #IO.puts("hey2")
        [selfNum,highestNodePossible]=data2
        IO.puts("starting node numbered #{selfNum}")
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
            ledgerCoinAdderIndex = 0
            neighbourList= Topology.get_neighbours(selfNum,highestNodePossible,"Ring")
            [selfNum,neighbourList,highestNodePossible,keys,wallet_value, transactionsNewBlockWork,current_transaction_pool_list, ledger,ledgerCoinAdderIndex]
        end
        
        GenServer.start_link(__MODULE__,state,name: :"#{id}")# for zero the maxNodes
    end

    def handle_cast({:receivetransactionList, transacList},state) do #for !0
        
        # IO.inspect(state)
        [selfNum,neighbourList,highestNodePossible,keys,wallet_value, transactionsNewBlockWork ,current_transaction_pool_list, ledger,ledgerCoinAdderIndex] = state
        IO.puts("new Transactions received by node #{selfNum}")
        # IO.inspect(transacList)
        current_transaction_pool_list= current_transaction_pool_list++ transacList
         state =  [selfNum,neighbourList,highestNodePossible,keys,wallet_value, transactionsNewBlockWork,current_transaction_pool_list, ledger,ledgerCoinAdderIndex]
         
        
       
        {:noreply,state}
    end

    def handle_cast(:generateBlock,state) do #for 0
        # IO.puts("generateBlock")
        [selfNum,neighbourList,highestNodePossible,keys,wallet_value, transactionsNewBlockWork, current_transaction_pool_list, ledger,ledgerCoinAdderIndex] = state

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
                state =  [selfNum,neighbourList,highestNodePossible,keys,wallet_value, current_transaction_pool_list, [], ledger,ledgerCoinAdderIndex]
                
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
        # IO.inspect(state)
        [selfNum,neighbourList,highestNodePossible,keys,wallet_value, transactionsNewBlockWork, current_transaction_pool_list, ledger,ledgerCoinAdderIndex] = state
        
        state =
        if transactionsNewBlockWork == data do
            
            concatData= concatTransactions(data,"")

            hashValue = Base.encode16(:crypto.hash(:sha256,concatData<>to_string(currentNonce)))
            # =Base.encode32(:crypto.hash(:sha256,"hello"<>to_string(108)))
           
            if String.slice(hashValue,0,4) == "0000" do
                #IO.puts(hashValue)
                #IO.puts(currentNonce)
                nonceTimeTaken = System.system_time(:millisecond)-startTime
                #IO.puts(System.system_time(:millisecond)-startTime)

                blockData = concatData
                
                previousBlockHead=     ## finding the previous block if first block we find ""
                if (length(ledger)) == 0 do
                    [0]
                else
                    IO.puts("previous block head found!!! ")
                    tail = Enum.at(ledger,length(ledger)-1)    
                    {prevBlockHeadFound,_}= tail
                    
                    IO.inspect(prevBlockHeadFound)
                    prevBlockHeadFound
                end
                previousBlockHead = previousBlockHead -- [Enum.at(previousBlockHead, length(previousBlockHead)-1)]

                blockId =  length(ledger)+1
                

                IO.puts("block generated by #{selfNum} for #{concatData}")
                

                concatHeaderAsString= concatTransactions(previousBlockHead,"")# converting the previous header to string


                hashedPreviousBlockHead = hashedStringify(concatHeaderAsString) # hashing the stringed header
                hashedBlockData= hashedStringify(concatData)
                blockHeader = [blockId,selfNum,System.system_time(:millisecond),currentNonce,hashedBlockData,hashedPreviousBlockHead]
                
                blockHeaderHash = hashedStringify(concatTransactions(blockHeader,""))

                blockHeader = [blockId,selfNum,System.system_time(:millisecond),currentNonce,hashedBlockData,hashedPreviousBlockHead, blockHeaderHash]
                
                # blockHeader = "NONCE = #{currentNonce} || timestamp =  #{System.system_time(:millisecond)} || time taken to find NONCE in milliseconds = #{nonceTimeTaken}"
                block = {blockHeader,blockData}
                ledger =  ledger ++ [block]
                GenServer.cast(:"id#{selfNum}",{:mineCoin,data,currentNonce+1,startTime})
                propagateBlock(block , neighbourList)
                [selfNum,neighbourList,highestNodePossible,keys,wallet_value, [], current_transaction_pool_list, ledger, ledgerCoinAdderIndex]
                
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
    
    def hashedStringify(toString) do
        
        Base.encode16(:crypto.hash(:sha256,to_string(toString)))

    end
    
    def concatTransactions(transactionsNewBlockWork, mergedTransactions) do
        # IO.puts("concatTransactions")
        if length(transactionsNewBlockWork) >0 do
            current = Enum.at(transactionsNewBlockWork,0)
            mergedTransactions= mergedTransactions<>"||"<>to_string(current)
            concatTransactions(transactionsNewBlockWork--[current],mergedTransactions)
        else
            mergedTransactions
        end
    end
    
    def handle_call(:getState,_from,state) do
        # IO.inspect(state)

        {:reply,state,state}
    end

    def handle_call(:showState, _from, state) do
        [selfNum,neighbourList,highestNodePossible,keys,wallet_value, transactionsNewBlockWork, current_transaction_pool_list, ledger , ledgerCoinAdderIndex] = state
        [public, private] =keys
        IO.inspect(" Showing state for node #{selfNum} ")
        IO.inspect("    the wallet ")
        IO.inspect("keys are ")
        IO.inspect("public = ")
        IO.inspect(public)
        IO.inspect("private =")
        IO.inspect(private)
        IO.inspect("wallet value = #{wallet_value}")
        IO.inspect("ledger =")
        IO.inspect(ledger)
        IO.inspect("ledger index for mined value is #{ledgerCoinAdderIndex}")
        {:reply,"",state}
    end
    def handle_cast({:createDummyValues,counter,w8time,transactionNumber,totalTransactionList},state) do #for 0
        # IO.puts("createDummyValues!!")
        if counter > 0 do
            if System.system_time(:millisecond) - w8time >500 do
                transactionList = generateRandomTransactions(:rand.uniform(5),[])
                transactionList =  transactionList -- totalTransactionList
                totalTransactionList = transactionList ++ totalTransactionList 
                IO.inspect(transactionList)
                spreadTransactions(1,100,transactionList)

                GenServer.cast(:id0,{:createDummyValues,counter-1,System.system_time(:millisecond),transactionNumber+length(transactionList), totalTransactionList})
            else
                GenServer.cast(:id0,{:createDummyValues,counter,w8time,transactionNumber, totalTransactionList})
            end
       
        end

        {:noreply,state}
    end
    
    def spreadTransactions(current, max, transactionList) do
        # IO.puts("spreadTransactions running")
        if current<=max do
            GenServer.cast(:"id#{current}",{:receivetransactionList,transactionList})
            spreadTransactions(current+1, max, transactionList)
        end

    end

    def addMinedValue(selfNum, startIndex, lastIndex, ledger, value) do
        returnValue=
        if startIndex >= lastIndex or ledger == [] do
            value
        else
            [block|remainingLedger] = ledger
            {header,data} = block
            [blockId,creatorNum,_,_,_,_,_] =  header
            value=
            if blockId > startIndex and blockId <= lastIndex and selfNum == creatorNum do
                value = value + 500
            else
                value
            end
            addMinedValue(selfNum, startIndex, lastIndex, remainingLedger, value)
        end

        returnValue

    end


    # tempBlock = {[1,10,10,10,10,10],""}
    def handle_cast({:receiveBlock,receivedBlock},state) do # here we do two things check if the block is competent and if yes add to self and send to other nodes
        # IO.puts("1")
        [selfNum,neighbourList,highestNodePossible,keys,wallet_value, transactionsNewBlockWork, current_transaction_pool_list, ledger, ledgerCoinAdderIndex] =state
        {blockHeader,blockData}=receivedBlock
        # IO.puts("2")
        
        [blockId,creatorNum,creationTimeStamp,currentNonce,hashedBlockData,hashedPreviousBlockHead,receivedBlockHash] =  blockHeader

        wallet_value = wallet_value + addMinedValue(selfNum, ledgerCoinAdderIndex ,blockId-5, ledger, 0)

        ledgerCoinAdderIndex =  
        if ledgerCoinAdderIndex > (blockId - 5) do
            ledgerCoinAdderIndex
        else
            blockId-5
        end

        competitionResult = checkCompetent(ledger,blockHeader) #[true/false, matchingBlock/[]]
        
        # IO.inspect(competitionResult)
        # IO.puts("3")
        [isCompetent,matchingBlockAlreadyContained] = competitionResult
        
        # IO.puts("3")
        state=
        if isCompetent do
            # ledger updation
            {blockListToBeRemoved,transactionsToBeAdded} = cleanLedger(ledger,blockId,{[],[]})
            # indexOfMatchingBlockInLedger =  Enum.find_index(ledger,fn(x) -> x== matchingBlockAlreadyContained end)
            
            newLedger = ledger -- blockListToBeRemoved#List.replace_at(ledger,indexOfMatchingBlockInLedger,receivedBlock)
            newLedger = newLedger ++ [receivedBlock]
            # ledger updation


            # transaction updation
                # {_,incompetentTransactions} =  matchingBlockAlreadyContained
                
                # incompetentTransactions =  String.trim(incompetentTransactions,"|")
                # incompetentTransactionsList = String.split(incompetentTransactions,"||")

                {_,completedTransactions} = receivedBlock
                alreadyDoneTransactions =  String.trim(completedTransactions)
                alreadyDoneTransactionsList = String.split(alreadyDoneTransactions,"||")

                current_transaction_pool_list =  current_transaction_pool_list ++ transactionsNewBlockWork ++ transactionsToBeAdded
                current_transaction_pool_list = current_transaction_pool_list -- alreadyDoneTransactionsList
                # current_transaction_pool_list = current_transaction_pool_list ++ 
                transactionsNewBlockWork =[]
            # transaction updation
            
            # propagating the new block
                propagateBlock(receivedBlock , neighbourList)
            # propagating the new block
            
            state = [selfNum,neighbourList,highestNodePossible,keys,wallet_value, transactionsNewBlockWork, current_transaction_pool_list, newLedger, ledgerCoinAdderIndex]
        else
            state
        end
        

        {:noreply,state}
    end

    def propagateBlock(receivedBlock, neighbourList) do
        Enum.each(neighbourList , fn(x)->
            GenServer.cast(:"id#{x}",{:receiveBlock,receivedBlock})
        end)
    end

    def cleanLedger(ledger,receivedBlockId,{newLedger, toAddTransactionPool}) do
        {newLedger, toAddTransactionPool}=
        if ledger == [] do
            {newLedger,toAddTransactionPool}
        else
            [firstBlock|remainingLedger] = ledger
            {header,data} = firstBlock
            [matchingBlockId,_,_,_,_,_,_] = header

            newLedger=
            if matchingBlockId < receivedBlockId do # to delete this block
                
                newLedger
            else
                newLedger = newLedger ++ [firstBlock]
                newLedger
            end
            
            toAddTransactionPool=
            if matchingBlockId < receivedBlockId do
                toAddTransactionPool
            else
                newTransactionsToBeAddedList = String.split(String.trim(data,"|"), "||")
                toAddTransactionPool = newTransactionsToBeAddedList ++ toAddTransactionPool
            end

            cleanLedger(remainingLedger,receivedBlockId, {newLedger,toAddTransactionPool})
        end
        # {newLedger,toAddTransactionPool}

    end

    @docp """
block1 = {[1,10,10,10,10,10],10}
block2= {[2,20,20,20,20,20],10}
block3 = {[3,30,30,30,30,30],10}
ledger = [block1,block2,block3]
receivedBlockHeader = [2,50,50,50,50,50]
Nodes.checkCompetent(ledger,receivedBlockHeader)

    """

    def checkHashingMatchForBlock(ledger,receivedBlockHeader) do
        [blockId,selfNum,creationTimeStamp,currentNonce,hashedBlockData,hashedPreviousBlockHead,currentBlockHash] =  receivedBlockHeader
        
        returnValue=
        if blockId == 1 do
            true
        else
            
            previousBlockId= blockId-1
            previousBlock = Enum.at(ledger,blockId-2)
            if previousBlock != nil do
                IO.puts("hey!! #{length(ledger)}  #{blockId}")
                {previousBlockHeader,_} = previousBlock
                [_,_,_,_,_,_,previousBlockHash] = previousBlockHeader
                if previousBlockHash == hashedPreviousBlockHead do
                    true
                else
                    false
                end
            else
                false
            end
            
        end
        returnValue
    end
    
    def checkCompetent(ledger,receivedBlockHeader) do
        
        [blockId,selfNum,creationTimeStamp,currentNonce,hashedBlockData,hashedPreviousBlockHead, currentBlockHash] =  receivedBlockHeader
        matchingBlock=findMatchingIdBlock(ledger,blockId,[])
        # IO.puts("competition check!   #{blockId}")
        returnValue = 
        # if checkHashingMatchForBlock(ledger,receivedBlockHeader) do
        if matchingBlock == [] do
            # received block is exclusive
            if checkHashingMatchForBlock(ledger,receivedBlockHeader) do
                [true,matchingBlock]
            else
                [false,matchingBlock]
            end
            
        else
            # received block is challenged and not exclusive
            # checking if already present block was created before
            {[matchingBlockId,matchingCreatorId,matchingCreationTime,_,_,_,_],_} =  matchingBlock

            returnValueNew=
            if creationTimeStamp < matchingCreationTime or ((creationTimeStamp == matchingCreationTime) and (matchingCreatorId>selfNum) ) do # new block was created before!!
                if checkHashingMatchForBlock(ledger,receivedBlockHeader) do
                    [true,matchingBlock]
                else
                    [false,matchingBlock]
                end
            else
                
                [false,matchingBlock]
            
            end
            
            returnValueNew
        end
        # else
        #     [false,matchingBlock]
        # end
        returnValue
    end


    

    # Nodes.findMatchingIdBlock([{[5,1,2,3,4,6],[]} ,{[10,20,123,30,30,30],""}, {[20,30,123123,12,3,123],[]}     ],10,[])
    def findMatchingIdBlock(pruningLedger,id,ans) do
        ans= 
        if pruningLedger == [] do
            ans
        else
            [latestBlock|prunedLedger] = pruningLedger
            {latestBlockHeader,latestBlockData} = latestBlock
            [blockId,selfNum,creationTimeStamp,currentNonce,hashedBlockData,hashedPreviousBlockHead, currentBlockHash] =  latestBlockHeader
            ans = 
            if blockId == id do
                latestBlock
            else
                []    
            end

            # IO.puts(blockId)

            ans =
            cond do
                ans != [] ->
                    ans
                prunedLedger == [] ->
                    ans
                true ->
                    findMatchingIdBlock(prunedLedger,id,ans)

            end

            ans
        end
        ans
    end


    def handle_cast({:createTransactions,sender,money,receiver},state) do
        
        senderState= GenServer.call(:"id#{sender}",:getState)

        [senderNum,neighbourList,highestNodePossible,keys,wallet_value, transactionsNewBlockWork, current_transaction_pool_list, ledger, ledgerCoinAdderIndex] =senderState

        if wallet_value < money or money<0 do
            IO.puts("INVALID TRANSACTION SENDER HAS INSUFFICIENT BALANCE OF #{wallet_value} or money transferred is less than 0")
        else
            transactionToBeSigned = "#{sender} #{money} #{receiver}"
            [transaction, signature, publicKey] = GenServer.call(:"id#{sender}",{:signTransaction,transactionToBeSigned})
            IO.inspect("the signature for the transaction is #{signature} and the public key is #{publicKey}")
            randomNode = Enum.random(1..100)
            IO.puts("transaction is #{transactionToBeSigned}")
            
            IO.puts("verifying this transaction by a random node selected that is #{randomNode}")

            signatureAuthorization = GenServer.call(:"id#{randomNode}",{:verifyTransaction, transactionToBeSigned, signature, publicKey})
            if signatureAuthorization == true do
                IO.puts("this transaction is true and adding it to transaction pool")
                GenServer.cast(:"id#{sender}",{:updateWallet,-money})
                GenServer.cast(:"id#{receiver}",{:updateWallet,money})
                :timer.sleep(5000)
                spreadTransactions(1,100,[transactionToBeSigned])
            else
                IO.puts("this transaction is false!! Authentication failed")
            end


        end

        {:noreply,state}
    end
    
    def handle_cast({:updateWallet, money},state) do
        [selfNum,neighbourList,highestNodePossible,keys,wallet_value, transactionsNewBlockWork, current_transaction_pool_list, ledger, ledgerCoinAdderIndex] =state
        if money < 0 do
            IO.puts("deducting value #{-money} from #{selfNum} wallet")

        else
            IO.puts("adding value #{money} to #{selfNum} wallet")
        end

        wallet_value = wallet_value + money

        state = [selfNum,neighbourList,highestNodePossible,keys,wallet_value, transactionsNewBlockWork, current_transaction_pool_list, ledger, ledgerCoinAdderIndex]
        {:noreply,state}
    end

    def handle_call({:verifyTransaction, transaction, signature, publicKey}, _from, state) do
        signatureAuthorization = :crypto.verify(:ecdsa, :sha512, transaction, signature, [publicKey,:brainpoolP512r1])

        {:reply, signatureAuthorization, state}
    end

    def handle_call({:signTransaction,transactionToBeSigned},_from,state) do
        [senderNum,_,_,[public,private],_, _, _, _] =state

        signature = :crypto.sign(:ecdsa, :sha512, transactionToBeSigned, [private, :brainpoolP512r1])
        returnValue = [transactionToBeSigned, signature, public]
        {:reply,returnValue,state}
    end

    def generateRandomTransactions(transNum, transactionList) do
        if transNum == 0 do
            transactionList
        else
            senderNode = :rand.uniform(99)+1
            receiverNode = :rand.uniform(99)+1
            money = :rand.uniform(1000)
            dummyString = "#{senderNode} 0 #{receiverNode}"
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