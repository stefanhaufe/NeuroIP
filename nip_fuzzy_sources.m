function aff = nip_fuzzy_sources(cortex, sigma)
% aff = nip_fuzzy_sources(cortex, sigma)
% This function returns a matrix that contains information about the
% distance between points in a graph. It places a gaussian with variance = sigma
% in each vertex
% Input:
%       cortex -> Struct. Structure containing the vertices and faces of
%       the graph
%       sigma -> Scalar. Variance of the gaussian placed at each vertex
% Output:
%       aff -> NdxNd. Symmetrical matrix in which the i-th column
%       represents the gaussian placed a round the i-th vertex.
%
% Additional comments: This function uses the graph toolbox to compute the
% distance between each vertex.
%
% Juan S. Castaño C.
% 14 Mar 2013

Nd = num2str(size(cortex.vertices,1));

% Search for a file with the precompute geodesic distances. If not found,
% computes them and saves them in a file (This WILL take a while, grab a
% snickers).
file_name = strcat(fileparts(which('nip_init')),'/data/','dist_mat',num2str(Nd),'.mat');
if exist(file_name,'file')
    load(file_name)
else
    A    = triangulation2adjacency(cortex.faces);
    D   = compute_distance_graph(A);
    save(file_name,'D');
end

aff = exp(-D/sigma);