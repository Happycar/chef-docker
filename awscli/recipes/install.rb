Chef::Log.info(" === :: AWS CLI - Install :: === ")

bash "awscli-install" do
    user "root"
    code <<-EOH
        apt-get install -y python-pip
        pip install awscli
    EOH
end