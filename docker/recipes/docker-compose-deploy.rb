include_recipe 'deploy'

Chef::Log.info("Entering docker-compose-deploy")

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

  bash "debug" do
    user "root"
    cwd deploy[:deploy_to]
    code <<-EOH
      echo "Test" > /srv/www/log
      ls -la >> /srv/www/log
    EOH
  end

  ruby_block "log" do
    only_if { ::File.exists?("/srv/www/log") }
    block do
      print "\n"
      File.open("/srv/www/log").each do |line|
        print line
      end
    end
  end

  unless deploy[:environment_variables].nil?

    if ::File.exists?("#{deploy[:deploy_to]}/current/docker-compose.yml")
      Chef::Log.info('docker-compose-run start')

      deployEnv = deploy[:environment_variables].to_hash
      nodeEnv = node[:environment_variables].to_hash

      composeEnv = nodeEnv.merge!(deployEnv)

      composeEnv['PRIVATE_IP'] = node[:opsworks][:instance][:private_ip]
      composeEnv["HOST_NAME"] = node[:opsworks][:instance][:hostname]

      bash "docker-compose pull" do
        user "root"
        cwd "#{deploy[:deploy_to]}/current/"
        code <<-EOH
          docker-compose pull
        EOH
      end

      bash "docker-compose start" do
        user "root"
        environment composeEnv
        cwd "#{deploy[:deploy_to]}/current/"
        code <<-EOH
          docker-compose -p app up --renew-anon-volumes -d
        EOH
      end

    else
      raise "Cant't deploy, docker-compose file does not exists at #{deploy[:deploy_to]}/current/docker-compose.yml"
    end


  else
      raise "Cant't deploy, ENV is empty or docker-compose file does not exists"
  end

  bash "docker cleanup" do
    user "root"
    code <<-EOH
      docker system prune --volumes -f
    EOH
  end

end
Chef::Log.info("Exiting docker-compose-deploy")
