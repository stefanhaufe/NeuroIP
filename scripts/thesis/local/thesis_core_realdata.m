function thesis_core(Nexp,Nact,Ntrials,methods,dir_data,dir_results,snr_bio)

nip_init();
load_data;
basis = nip_fuzzy_sources(model.cortex,1,struct('dataset','montreal','save',true));

for i = Nexp
    for j = Nact
        for k = Ntrials
            dir = strcat(dir_data,num2str(j));
            file_name = strcat(dir,'/Exp',num2str(i),'Ntrials',...
                num2str(k),'BioNoise',num2str(snr_bio),'.mat');
            load(file_name)
            model.fs = fs;
            model.y = y;
            model.Nt = size(y,2);
            model.t = 0:1/fs:model.Nt/fs;
            for m = 1:numel(methods)
                tic;
                switch methods{m}
                    case 'LOR'
%                         Q = nip_translf(repmat(nip_translf(repmat(basis,[1 1 3]))',[1 1 3]));
                        Q = speye(model.Nd);
                        [J_rec,extra]  = nip_loreta(model.y,model.L,Q);
                    case 'KAL'
%                         neigh = nip_translf(repmat(nip_translf(repmat(basis,[1 1 3]))',[1 1 3]));
                        neigh = speye(model.Nd);
                        [J_rec,extra]  = nip_kalmanwh(model.y,model.L,neigh,par);
                    case 'IRA3'
                        neigh = speye(model.Nd);
                        Q = speye(model.Nd);
                        [J_rec,extra] = nip_iterreg(model.y,model.L,Q,neigh,3,eye(model.Nc),par)
                    case 'IRA5'
                        neigh = speye(model.Nd);
                        Q = speye(model.Nd);
                        [J_rec,extra] = nip_iterreg(model.y,model.L,Q,neigh,3,eye(model.Nc),par)
                    case 'LOR_PROJ'
                        Q = nip_translf(repmat(nip_translf(repmat(basis,[1 1 3]))',[1 1 3]));
                        [y_proj,~,Ur,~]= nip_tempcomp(model.y,model.t,[0 60],0.9);
                        [J_rec,extra] = nip_loreta(y_proj,model.L,Q);
                        J_rec = Jrec*Ur';
                    case 'LORTV'
                        [J_rec,extra]=nip_tvloreta(model.y,model.t,model.L,basis,model.cortex);
                    case 'S-FLEX'
                        [J_rec,~]  = nip_sflex(model.y,model.L,basis,5e-5);
                    case 'TF-MxNE'
                        [J_rec,~] = nip_tfmxne_port(model.y,model.L,[]);
                    case 'STOUT'
                        [J_rec,~] = nip_stout(model.y,model.L,basis,[]);
                    otherwise
                        err('%s not available as method',methods{j})
                end
                idx = find(sqrt(sum(J_rec.^2)) <= 0.01*sqrt(sum(J_rec.^2)));
                J_rec(idx,:) = zeros(length(idx),model.Nt);
                J_rec = sparse(J_rec);
                time = toc;
                
                
                dir = strcat(dir_results,num2str(j));
                file_name = strcat(dir,'/',methods{m},'Exp',num2str(i),'Ntrials',...
                    num2str(k),'BioNoise',num2str(snr_bio),'.mat');
            end
        end
    end
end

end
