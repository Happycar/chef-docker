Chef::Log.info(" === :: AWS CLI - Install :: === ")

bash "awscli-install" do
    user "root"
    code <<-EOH
        apt-get install -y unzip
        cd ~/
        curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
        unzip awscli-bundle.zip
        rm awscli-bundle.zip
        ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
    EOH
end