defmodule DSS do
    use DynamicSupervisor

    def start_link(arg) do
        DynamicSupervisor.start_link(__MODULE__, arg, name: __MODULE__)
    end
    
    def start_child(sid,num,highestNodePossible) do
     #IO.puts("hey1")
    
        spec = %{
                id: num,
                restart: :transient,
                start: {Nodes, :start_link, [[ num, highestNodePossible ]]}
            }
        #IO.puts("hey2")
        
        DynamicSupervisor.start_child(sid, spec)
    end
    
    @impl true
    def init(initial_arg) do
        DynamicSupervisor.init(
        strategy: :one_for_one,
        extra_arguments: [initial_arg]
        )
    end
end