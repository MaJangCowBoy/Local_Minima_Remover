using MATLAB
using JLD2
using Printf
using Sunny
include("CTS_info.jl");

# ? structure comparison and replacement process

sttPt = parse(Int64,ARGS[1]);
endPt = parse(Int64,ARGS[2]);
para  = parse(Int64,ARGS[3]);

kbq = 0.025;

j2Grid_c = 0.00:0.01:0.30;  j2len = length(j2Grid_c);
j3Grid_c = 0.00:0.01:0.20;  j3len = length(j3Grid_c);
jcGrid_c = 0.80;            jclen = length(jcGrid_c);

j2Grid_r = 0.00:0.01:0.30;
j3Grid_r = 0.00:0.01:0.20;
jcGrid_r = 0.80;          

magStr_s = zeros(j2len,j3len,jclen,36,36,3,2,3);
survived = zeros(36,36,3,2,3);

jldfile = @sprintf("magStr_repo_%.2d.jld2",para);
fid = jldopen(jldfile);
magStr_c = read(fid, "magStr_c");
close(fid)

for (i_r,j2_r) in enumerate(j2Grid_r), (j_r,j3_r) in enumerate(j3Grid_r), (k_r,jc_r) in enumerate(jcGrid_r)
  # idx, which is defined as number counting of i_r, j_r, k_r, is used to save data
  idx = (i_r-1)*j3len*jclen + (j_r-1)*jclen + k_r;

  if idx >= sttPt && idx <= endPt

    # filename = @sprintf("magStr_bq_0.025_j2_%.3f_j3_%.3f_jc_%.3f.mat",j2_r,j3_r,jc_r);
    # mf = MatFile(filename);
    # survived[:,:,:,:,:] = get_variable(mf, "magStr");
    # close(mf);
    survived[:,:,:,:,:] = magStr_c[i_r,j_r,k_r,:,:,:,:,:];
  
    for (i_c,j2_c) in enumerate(j2Grid_c), (j_c,j3_c) in enumerate(j3Grid_c), (k_c,jc_c) in enumerate(jcGrid_c)
  
      magSys_r = CTS_system(; latsize=(36,36,3), j1 = 1.8, jb = kbq/(1.5*1.5), j2 = j2_r, j3 = j3_r, jc = jc_r);
  
      for x = 1:36, y = 1:36, z = 1:3, b = 1:2
        magSys_r.dipoles[x,y,z,b] = survived[x,y,z,b,:];
      end
  
      magSys_c = CTS_system(; latsize=(36,36,3), j1 = 1.8, jb = kbq/(1.5*1.5), j2 = j2_r, j3 = j3_r, jc = jc_r);
  
      for x in 1:36, y in 1:36, z in 1:3, b in 1:2
        magSys_c.dipoles[x,y,z,b] = magStr_c[i_c,j_c,k_c,x,y,z,b,:];
      end
  
      if energy(magSys_r) > energy(magSys_c) + 10*eps()
        # if simulated structure is not true ground state, then ...
        survived[:,:,:,:,:] = magStr_c[i_c,j_c,k_c,:,:,:,:,:];
      end
  
    end
  
    magStr_s[i_r,j_r,k_r,:,:,:,:,:] = survived[:,:,:,:,:];

  end

end

for (i_r,j2_r) in enumerate(j2Grid_r), (j_r,j3_r) in enumerate(j3Grid_r), (k_r,jc_r) in enumerate(jcGrid_r)

  idx = (i_r-1)*j3len*jclen + (j_r-1)*jclen + k_r;

  if idx >= sttPt && idx <= endPt
    matname = @sprintf("magStr_bq_%.3f_j2_%.3f_j3_%.3f_jc_%.3f_survived_Test.mat",kbq,j2_r,j3_r,jc_r);
    savedata = magStr_s[i_r,j_r,k_r,:,:,:,:,:];
    write_matfile(matname; magStr_s = savedata);
    jldname = @sprintf("magStr_bq_%.3f_j2_%.3f_j3_%.3f_jc_%.3f_survived_Test.jld2",kbq,j2_r,j3_r,jc_r);
    savedata = magStr_s[i_r,j_r,k_r,:,:,:,:,:];
    jldsave(jldname; magStr_s = savedata);
  end

end
