defmodule Neighbours_for_topologies do
    def get_neighbours(num, max_num , topology ) do
        cond do

            
            topology == "Line" ->
                
                cond do
                    num == 1 -> [2]

                    num == max_num ->  temp = max_num - 1
                                        [temp]

                    true ->
                        temp1 = num - 1
                        temp2 = num + 1
                        [temp1,temp2]

                end
            
            topology == "Ring" ->
            
                cond do
                    num == 1 -> [max_num,2]

                    num == max_num ->  temp = max_num - 1
                                        [temp,1]

                    true ->
                        temp1 = num - 1
                        temp2 = num + 1
                        [temp1,temp2]

                end

                
                      
            topology == "Full" ->
                list_out = listpopulate(1, max_num , [])
                list_out = list_out -- [num]                
                list_out



            topology == "Toroid" ->
                squareroot = :math.pow(max_num,(1/2))
                squareroot = round(squareroot)

                along = []
                along =
                if num-squareroot<=0 do
                    temp = max_num + num - squareroot
                    along++[temp]
                else
                    temp = num - squareroot
                    along++[temp]
                end

                along = 
                if num+squareroot> max_num do
                   temp = num + squareroot - max_num
                   along ++[temp] 
                else
                    temp = num + squareroot
                    along ++ [temp]
                end

                adjacent = []
                adjacent =
                if rem(num,squareroot) == 0   do
                    temp = num - squareroot + 1
                    adjacent ++ [temp]
                else
                    temp = num + 1
                    adjacent ++ [temp]
                end

                adjacent = 
                if rem(num,squareroot) == 1   do
                    temp = num + squareroot - 1
                    adjacent ++ [temp]
                else
                    temp = num - 1
                    adjacent ++ [temp]
                end
                
                list = adjacent ++ along
                
           
            true ->
                IO.puts("please enter an appropriate Topology")
        end
        
    end

    def listpopulate(lowerval , uperval , list) when lowerval==uperval do
        list = list ++ [lowerval]
        list
    end

    def listpopulate( lowerval , uperval , list) do
        list = list ++ [lowerval]
        listpopulate(lowerval+1,uperval , list)
    end
end