unless node[:docker_registry].nil?

  registry = node[:docker_registry][:type]
  accessData = Chef::JSONCompat.to_json(node[:docker_registry][:auth_data]).gsub('/', '\/')

  Chef::Log.info("Saving access config to ecs config: #{accessData}")

  unless File.readlines("/etc/ecs/ecs.config").grep(/ECS_ENGINE_AUTH_TYPE/).size > 0

    bash 'ecs add docker registry auth' do
      user "root" 
      code <<-EOH
        echo "ECS_ENGINE_AUTH_TYPE=#{registry}" >> /etc/ecs/ecs.config
        echo "ECS_ENGINE_AUTH_DATA=#{accessData}" >> /etc/ecs/ecs.config
      EOH
    end

  else

    bash 'update ecs docker auth' do
      user "root"
      code <<-EOH
        sed -i -e 's/ECS_ENGINE_AUTH_TYPE=.*/ECS_ENGINE_AUTH_TYPE=#{registry}/' /etc/ecs/ecs.config
        sed -i -e 's/ECS_ENGINE_AUTH_DATA=.*/ECS_ENGINE_AUTH_DATA=#{accessData}/' /etc/ecs/ecs.config
      EOH
    end

  end

else

  Chef::Log.info('No docker registry credentials were provided. Skipping')

end