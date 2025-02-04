#Use BDgrapg
library(BDgraph)

#Read the b that is parsed as an argument from Python
parser = commandArgs(trailingOnly=TRUE)

b = as.integer(parser[1])  # Degrees of freedom

#Read the n (number of samples in the original data) that is parsed from Python
n = as.integer(parser[2])

# Reading G matrix
G = read.table(text=parser[3])  # Input is already in the right format thanks to python
G = as.matrix(G)

# Reading Data matrix (that is, the k x k matrix built from multivariate Gaussian samples)
# Important: Data is already H' . H
Data = read.table(text=parser[4])  # Input is already in the right format thanks to python
Data = as.matrix(Data)

#Read the if debugging lines should be printed
debugOn = parser[5]

# Building shape_matrix
shape_matrix = diag(dim(G)[1])  # Identity matrix of size k

# Prior on existing link
p_existing_link = 0.5  # uninformative prior
#p_existing_link = 0.2  # uninformative prior

# Number of iterations
iterations = 2

if (debugOn){
    sprintf("[R] BDMCMC will now be sampling a single iteration.")
    sprintf("The n (data sample size) is set to %d.", n)
    sprintf("The b (degrees of freedom) is set to %d", b)
    sprintf("The probability of existing link is set to %f", p_existing_link)
    print("[R] Matrix G:")
    print(G)
    print("[R] Data Matrix:")
    print(Data)
    print("[R] Shape Matrix:")
    print(shape_matrix)
    print("[R] Iterations:")
    print(iterations)
}

# INPUTS: b, n, G, K, Data, p_existing_link and shape_matrix (if you need something else let me know - K)
#########################################
# Actual algorithm
sample.bdmcmc <- bdgraph(Data, n = n, method = "ggm", algorithm = "bdmcmc", iter = iterations, burnin = 0, not.cont = NULL, g.prior = p_existing_link, df.prior = b, g.start = G, jump = 1, save = TRUE, print = 1000, cores = "all", threshold = 1e-8 )
#G = summary(sample.bdmcmc)$selected_g
#K = sample.bdmcmc$K_hat
G = sample.bdmcmc$last_graph
K = sample.bdmcmc$last_K
waitingTime <- sample.bdmcmc$graph_weights[iterations]
#HOW CAN WE KEEP THE ENTIRE BDGRAPH OBJECT FROM ONE ITERATION TO THE OTHER

# Check https://github.com/TeoGiane/FGM/blob/master/R/sampler.R
# which uses ggm_bdmcmc_map here https://github.com/cran/BDgraph/blob/master/src/ggm_bd.cpp
# Called from https://github.com/TeoGiane/FGM/blob/master/R/bdgraph.R  (line 101)
# Remember to only run one iteration
#########################################
# OUTPUTS: G, K and waiting time (waitingTime)


# Finally
if (debugOn){
    print("[R] Waiting time:")
    print(waitingTime)  
    print("[R] Sampled Matrix G:")
    print(G)
    print("[R] Sampled Matrix K:")
    print(K)
    print("[R] returning results:")
}
# Printing results (to be deserialized by python) 
# (cat does not print newline)
cat(formatC(waitingTime, digits = 16, format = "f"))
cat('\n')  # Newline
G_vectorized = as.vector(t(G))
for (entry in G_vectorized) {
    cat(entry)
    cat(' ')
}
cat('\n')  # Newline

K_vectorized = as.vector(t(K))
for (entry in K_vectorized) {
    cat(formatC(entry, digits = 32, format = "f"))
    cat(' ')
}
