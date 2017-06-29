Chef::Log.info(" === :: Docker INSTALL from repository :: === ")
bash "docker-install" do
user "root"

# default docker version to use
DOCKER_VERSION = "17.06.0~ce-0~ubuntu"
  
unless deploy[:environment_variables][:DOCKER_VERSION].nil?
  DOCKER_VERSION = deploy[:environment_variables][:DOCKER_VERSION]
end

code <<-EOH
  apt-get update
  apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    linux-image-extra-$(uname -r) \
    linux-image-extra-virtual
    
  # download dockers official GPG key
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg > docker.gpg
  
  # add to keyring
  apt-key add docker.gpg
  
  # setup stable repository
  sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
   
  # install docker-ce 
  apt-get update
  apt-get install docker-ce=#{DOCKER_VERSION}
EOH
end
