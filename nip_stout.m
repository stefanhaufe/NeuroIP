function [J_rec extras] = nip_stout(y,L,B,varargin)
% function [J_rec extras] = nip_stout(y,L,B,options)
% Input:
%         y -> NcxNt. Matrix containing the data,
%         L -> Ncx3Nd. Lead Field matrix
%         B -> NdxNk. Spatial basis functions
%         options -> struct.
%                 options.spatial_reg -> scalar. Percentage of spatial
%                       regularization (between 0 and 1). 
%                 options.temp_reg -> scalar. Percentage of temporal
%                       regularization (between 0 and 1).
%                 options.a -> scalar. Time shift for the time frequency
%                       transform.
%                 options.m -> scalar. Frequency bins for the time frequency
%                       transform.
%                 options.tol -> Scalar. Default 1e-3
%   Output:
%         J_rec -> 3NdxNt. Reconstructed activity (solution)
%         extras. -> Currently empty
%
% Juan S. Castano C.
% jscastanoc@gmail.com
% 19 Aug 2013

p = inputParser;

def_a = 8;
def_m = 112;
def_sreg = 80;
def_treg= 1;
def_maxiter = 10;
def_tol = 2e-2;
def_resnorm = 0.3;
def_lipschitz = [];
def_optimres = false;
def_Winv = [];

addParamValue(p,'a',def_a);
addParamValue(p,'m',def_m);
addParamValue(p,'sreg',def_sreg);
addParamValue(p,'treg',def_treg);
addParamValue(p,'maxiter',def_maxiter);
addParamValue(p,'tol',def_tol);
addParamValue(p,'resnorm',def_resnorm);
addParamValue(p,'lipschitz',def_lipschitz);
addParamValue(p,'optimres',def_optimres);
addParamValue(p,'Winv',def_Winv)

parse(p,varargin{:})
options = p.Results;

Ltemp = nip_translf(L);
for i = 1:3
    Lnew(:,:,i) = Ltemp(:,:,i)*B;
end
Lnew = nip_translf(Lnew);
[J_r,extras] = nip_tfmxne_port(y,Lnew,varargin{:}, 'Winv', []);
J_rect = nip_translf(J_r');
J_rect = permute(J_rect,[2 1 3]);
for i = 1:3
    J_rec(:,:,i) = B*J_rect(:,:,i);
end

J_rec = permute(J_rec,[2 1 3]);
J_rec = nip_translf(J_rec)';


if ~isempty(options.Winv)
    J_est = nip_translf(J_rec');
    siJ = size(J_est);
    J_rec = permute(reshape(full(reshape(permute(J_est, [1 3 2]), siJ(1), [])*options.Winv), siJ(1), siJ(3), siJ(2)), [1 3 2]);
    J_rec = nip_translf(J_rec)';
end
% J_rec= J_rec*norm(y,2)/norm(L*J_rec,2);
% extras =[];
end