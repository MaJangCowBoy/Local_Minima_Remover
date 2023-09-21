using Printf

# ? shell making process which copies the file

fid = open("autoCopy.sh", "w")

println(fid, "#!/bin/bash");

for it = 1:50
  strstr = @sprintf("cp magStr_repo.jld2 magStr_repo_%2.2d.jld2", it);
  println(fid,strstr);
end

println(fid, "wait");
println(fid, "exit 0");

close(fid);