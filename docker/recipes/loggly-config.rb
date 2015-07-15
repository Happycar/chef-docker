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

execute 'remove-udp' do
  command "sed -i '/$ModLoad imudp/d' /etc/rsyslog.conf"
end

execute 'enable-udp' do
  command "printf '$ModLoad imudp \n' >> /etc/rsyslog.conf"
end

execute 'remove-post' do
  command "sed -i '/$UDPServerRun 514/d' /etc/rsyslog.conf"
end

execute 'enable-post' do
  command "printf '$UDPServerRun 514 \n' >> /etc/rsyslog.conf"
end

execute 'restart-syslog' do
  command "service rsyslog restart"
end