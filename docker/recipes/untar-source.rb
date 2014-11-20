include_recipe 'deploy'
Chef::Log.debug("The recipe actuallz starts")
node[:deploy].each do |application, deploy|

  if node[:opsworks][:instance][:layers].first != deploy[:environment_variables][:layer]
    Chef::Log.debug("Skipping deploy::docker application #{application} as it is not deployed to this layer")
    next
  end

  opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
  end

  opsworks_deploy do
    deploy_data deploy
    app application
  end

  Chef::Log.debug("Before untar")

  bash "untar-code" do
    cwd "#{deploy[:deploy_to]}/current"
    command "for a in `ls -1 *.tar.gz`; do tar -zxvf $a; done"
  end

  Chef::Log.debug("Before file moving")
  
  bash "cleanup-mess" do
    cwd "#{deploy[:deploy_to]}/current"
    command "mv temporary/* #{deploy[:deploy_to]}/current"
  end

end


