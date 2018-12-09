defmodule Topology do
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

    ###########################

    #  def getNeighbours(num, maxNum, topology) do
    #     neighbours=[]
    #     neighbours=
    #     cond do
    #         topology=="line"->
    #             #IO.puts("line reached!!")
    #             cond do
    #                 num==1->
    #                     neighbours=[2]

    #                 num==maxNum ->
    #                     neighbours=[maxNum-1]

    #                 num>0 && num<maxNum->
    #                     neighbours=[num-1,num+1]

    #                 true ->
    #                     neighbours=[]


    #             end
    #         topology=="full"->

    #             neighbours=[Enum.random(1..maxNum)]
    #             neighbours

    #         topology=="3D"->
    #             maxNumCubeRoot=round(:math.pow(maxNum,1/3))
    #             maxNumFaceNum=maxNumCubeRoot*maxNumCubeRoot

    #             #num = my id
    #             #maxNumFaceNum = the number of elements on a face x square   x square
    #             #maxNumCubeRoot = one edge distance that is x                x

    #             #top
    #             neighbours=
    #             if rem(num,maxNumFaceNum) <=maxNumCubeRoot do
    #                 neighbours
    #             else
    #                 #IO.puts(num-maxNumCubeRoot)
    #                 neighbours=neighbours++[num-maxNumCubeRoot]
    #                 neighbours
    #             end

    #             #bottom
    #             #IO.puts("num is #{num} and maxNumFaceNum is #{maxNumFaceNum} and maxNumCubeRoot is #{maxNumCubeRoot}")
    #             neighbours=
    #             if rem(maxNum-num,maxNumFaceNum)<maxNumCubeRoot do# do
    #                 neighbours
    #             else
    #                 #IO.puts("bottom")
    #                 #IO.puts(num+maxNumCubeRoot)
    #                 neighbours=neighbours++[num+maxNumCubeRoot]
    #                 neighbours
    #             end

    #             #left
    #             neighbours=
    #             if (rem(num,maxNumCubeRoot))==1 do
    #                 neighbours
    #             else
    #                 #IO.puts(num-1)
    #                 neighbours=neighbours++[num-1]
    #                 neighbours
    #             end

    #             #right
    #             neighbours=
    #             if rem(num,maxNumCubeRoot)==0 do
    #                 neighbours
    #             else
    #                 #IO.puts(num+1)
    #                 neighbours=neighbours++[num+1]
    #                 neighbours
    #             end

    #             #back
    #             neighbours=
    #             if (maxNum-num)<maxNumFaceNum do
    #                 neighbours
    #             else
    #                 #IO.puts(num+maxNumFaceNum)
    #                 neighbours=neighbours++[num+maxNumFaceNum]
    #                 neighbours
    #             end

    #             #front
    #             neighbours=
    #             if num<=maxNumFaceNum do
    #                 neighbours
    #             else
    #                 #IO.puts(num-maxNumFaceNum)
    #                 neighbours=neighbours++[num-maxNumFaceNum]
    #                 neighbours
    #             end
    #             neighbours

    #         topology=="imp2D"->
    #             #IO.puts("line reached!!")
    #             neighbours=
    #             cond do
    #                 num==1->
    #                     neighbours=[2]
    #                     #neighbours=neighbours++[getRandom(1,maxNum,num)]

    #                 num==maxNum ->
    #                     neighbours=[maxNum-1]
    #                     #neighbours=neighbours++[getRandom(1,maxNum,num)]

    #                 num>0 && num<maxNum->
    #                     neighbours=[num-1,num+1]
    #                     #neighbours=neighbours++[getRandom(1,maxNum,num)]

    #                 true ->
    #                     neighbours=[]


    #             end
    #             neighbours
    #         topology=="rand2D"->
    #             [_,_,_,_,allNeighbours]=:sys.get_state(:id0)
    #             neighbours=allNeighbours[num]

    #         topology=="torus"->
    #             width=round(:math.pow(maxNum,1/2))
    #             totalNodes=width*width

    #             #top
    #             neighbours=
    #             if num<=width do
    #                 neighbours=neighbours++[num+(width*(width-1))]
    #                 neighbours
    #             else
    #                 neighbours=neighbours++[num-width]
    #             end

    #             #bottom
    #             neighbours=
    #             if totalNodes-num<width do # 9-7<3
    #                 neighbours=neighbours++[width-(totalNodes-num)]
    #                 neighbours
    #             else
    #                 neighbours=neighbours++[num+width]
    #                 neighbours
    #             end

    #             #left
    #             neighbours=
    #             if rem(num,width)==1 do
    #                 neighbours=neighbours++[num+width-1]
    #                 neighbours
    #             else
    #                 neighbours=neighbours++[num-1]
    #                 neighbours
    #             end

    #             #right
    #             neighbours=
    #             if rem(num,width)==0 do
    #                 neighbours=neighbours++[num-width+1]
    #                 neighbours
    #             else
    #                 neighbours=neighbours++[num+1]
    #                 neighbours
    #             end

    #             neighbours
    #         true->
    #         []

    #     end
    #     neighbours
    # end
end