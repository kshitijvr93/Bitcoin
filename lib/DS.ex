defmodule DS do
    def starting(a,b) do
        IO.puts(a)
        IO.puts(b)
        highestNodePossible=100
        {_,spid}=DSS.start_link([])

        DSS.start_child(spid,0,highestNodePossible)

        genServerGenerator(spid,1,highestNodePossible)

        # all children started!!

    end

    def genServerGenerator(spid,currentNode,highestNodePossible) do

        if currentNode <= highestNodePossible do
            DSS.start_child(spid,currentNode,highestNodePossible)
            genServerGenerator(spid,currentNode+1, highestNodePossible)
        end
        
    end
end
