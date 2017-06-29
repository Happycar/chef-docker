Chef::Log.info(" === :: Docker INSTALL from repository :: === ")
bash "docker-install" do
user "root"

# default docker version to use
DOCKER_VERSION = "17.06.0~ce-0~ubuntu"
  
Chef::Log.info(" attempting to install DOCKER_VERSION #{DOCKER_VERSION}")  
  
code <<-EOH
  apt-get update
  apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    linux-image-extra-$(uname -r) \
    linux-image-extra-virtual
    
  # download dockers official GPG key
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg > docker.gpg

  # verify fingerprint
  gpg --with-fingerprint docker.gpg | grep "9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD89"

  # exit if it doesn't match (as recommended)
  if [[ $? != 0 ]]; then 
    Chef::Log.fatal('Docker GPG Key fingerprint mismatch. Aborting. ')
    raise
  fi
  
  # add to keyring
  apt-key add docker.gpg
  
  # setup stable repository
  sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
   
  # install docker-ce 
  apt-get update
  apt-get install -y docker-ce=#{DOCKER_VERSION}
EOH
end
