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

bash "enable-udp" do
  user "root"
  code <<-EOS
  echo "$ModLoad imudp" >> /etc/rsyslog.conf
  EOS
end


bash "enable-port" do
  user "root"
  code <<-EOS
  echo "$UDPServerRun 514" >> /etc/rsyslog.conf
  EOS
end
