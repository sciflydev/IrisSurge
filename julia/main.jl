using Surge
using Clustering
import RDatasets: dataset
import DataFrames

# Data setup
const data = DataFrames.insertcols!(dataset("datasets", "iris"), :Cluster => zeros(Int, 150))
const features = [:SepalLength, :SepalWidth, :PetalLength, :PetalWidth]

# Define reactive signals
no_of_clusters = Signal(3, :no_of_clusters)
no_of_iterations = Signal(10, :no_of_iterations)

# Clustering function
function perform_clustering(nclusters, niters)
    feats = Matrix(data[:, [c for c in features]])' |> collect
    result = kmeans(feats, nclusters; maxiter=niters)
    data[!, :Cluster] = assignments(result)
    data
end

cluster_data = computed(() -> begin
    perform_clustering(no_of_clusters(), no_of_iterations())
end, :data_clusters)

# Start server in asynchronous mode to make the REPL usable
println("Starting server...")
server = start_server([no_of_clusters, no_of_iterations, cluster_data], 8080, async=true)
println("Server running on http://localhost:8080")
# Interrupt the loop with Ctrl+C to stop the server and free the port
while true
    sleep(1)
end
stop_server(server)
