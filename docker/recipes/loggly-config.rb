execute 'loggly-config-download' do
  command 'curl -O https://www.loggly.com/install/configure-linux.sh'
end

bash "run-config" do
    user "root"
    code <<-EOH
        chmod 777 /configure-linux.sh
        /configure-linux.sh -a #{node[:loggly][:subdomain]} -t #{node[:loggly][:token]} -p #{node[:loggly][:password]} -u #{node[:loggly][:username]}
    EOH
  end



execute 'enable-udp' do
  command 'printf "$ModLoad imudp \n" >> /etc/rsyslog.conf'
end

execute 'enable-post' do
  command 'printf "$UDPServerRun 514 \n" >> /etc/rsyslog.conf'
end