Chef::Log.info(" === :: Docker INSTALL from repository :: === ")

# default docker version to use
DOCKER_VERSION = "18.06.1~ce~3-0~ubuntu"

Chef::Log.info(" attempting to install DOCKER_VERSION #{DOCKER_VERSION}")

bash "prepare system" do
  user "root"
  code <<-EOH
    apt-get update
    apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        software-properties-common \
        linux-image-extra-$(uname -r) \
        linux-image-extra-virtual
  EOH
end

bash "veirfy  GPG key and add repository" do
  user "root"
  code <<-EOH
    # download dockers official GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg > docker.gpg

    # verify fingerprint
    gpg --with-fingerprint docker.gpg | grep "9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88"

    # exit if it doesn't match (as recommended)
    if [[ $? != 0 ]]; then
        raise
    fi

    # add to keyring
    apt-key add docker.gpg

    # setup stable repository
    sudo add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) \
        stable"
  EOH
end

bash "install docker-ce" do
  user "root"
  code <<-EOH
    # install docker-ce
    apt-get update
    apt-get install --yes --force-yes docker-ce=#{DOCKER_VERSION}
  EOH
end
