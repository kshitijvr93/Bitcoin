defmodule DS do
    def starting() do
        
        highestNodePossible=100
        {_,spid}=DSS.start_link([])

        DSS.start_child(spid,0,highestNodePossible)

        genServerGenerator(spid,1,highestNodePossible)
        
        :timer.sleep(300)
        GenServer.call(:id0,:generateBlockStart)
        :timer.sleep(300)
        # GenServer.cast(:id0,{:createDummyValues,10,System.system_time(:millisecond),0})

        GenServer.cast(:id0, {:createTransactions, 10, 1, 20})
        # GenServer.cast(:id0, {:createTransactions, 30, 2, 40})
        # GenServer.cast(:id0, {:createTransactions, 50, 2, 70})
        # all children started!!

    end

    def genServerGenerator(spid,currentNode,highestNodePossible) do

        if currentNode <= highestNodePossible do
            DSS.start_child(spid,currentNode,highestNodePossible)
            genServerGenerator(spid,currentNode+1, highestNodePossible)
        end
        
    end
end
