using MATLAB
using JLD2
using Printf
# using Sunny
# include("CTS_info.jl");

# ? Reference structure extraction process

kbq = 0.025;
j2Grid_c = 0.00:0.01:0.30;  j2len = length(j2Grid_c);
j3Grid_c = 0.00:0.01:0.20;  j3len = length(j3Grid_c);
jcGrid_c = 0.80;            jclen = length(jcGrid_c);

magStr_c = zeros(j2len,j3len,jclen,36,36,3,2,3);
# magStr_s = zeros(j2len,j3len,jclen,36,36,3,2,3);
# survived = zeros(36,36,3,2,3);

for (i,j2) in enumerate(j2Grid_c), (j,j3) in enumerate(j3Grid_c), (k,jc) in enumerate(jcGrid_c)
  filename = @sprintf("magStr_bq_%.3f_j2_%.3f_j3_%.3f_jc_%.3f.mat",kbq,j2,j3,jc);
  mf = MatFile(filename);
  magStr_c[i,j,k,:,:,:,:,:] = get_variable(mf, "magStr");
  close(mf);
end

jldsave("magStr_repo.jld2";magStr_c = magStr_c);