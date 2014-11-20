execute "untar-code" do
  cwd "#{deploy[:deploy_to]}"
  command "for a in `ls -1 *.tar.gz`; do tar -zxvf $a; done"
end

execute "cleanup-mess" do
  cwd "#{deploy[:deploy_to]}"
  command "mv temporary/* #{deploy[:deploy_to]}"
end