
define :updatedefaults do

  ## ignore failure - depending on login state, these might not be running when chef runs.
  execute "killall Dock" do
    ignore_failure true
    action :nothing
  end
  execute "killall Finder" do
    ignore_failure true
    action :nothing
  end
  execute "killall loginwindow" do
    ignore_failure true
    action :nothing
  end

  node['mac_os_x']['settings'].each do |domain,settings|
    settings.each do |k,v|
      next if k == 'domain'

      mac_os_x_userdefaults "#{settings['domain']}-#{k}" do
        domain settings['domain']
        user node['mac_os_x']['settings_user']
        key k
        value v
        sudo true if settings['domain'] =~ /^\/Library\/Preferences/
        global true if settings['domain'] =~ /^NSGlobalDomain$/
        notifies :run, "execute[killall Dock]" if settings['domain'] =~ /^com.apple.dock$/
        notifies :run, "execute[killall Dock]" if settings['domain'] =~ /^com.apple.dashboard$/
        notifies :run, "execute[killall Finder]" if settings['domain'] =~ /^com.apple.finder$/
        notifies :run, "execute[killall loginwindow]" if settings['domain'] =~ /^com.apple.spaces$/
      end
      ##hack in a timestamp to show last time we updated a domain
#this DOES happen every run.
      # mac_os_x_userdefaults "#{settings['domain']}-#{k}" do
      #   domain settings['domain']
      #   user node['mac_os_x']['settings_user']
      #   key 'mac_os_x_userdefaults'
      #   value "#{k}.#{Time.new.strftime("%Y%m%d%H%M%S")}"
      #   sudo true if settings['domain'] =~ /^\/Library\/Preferences/
      #   global true if settings['domain'] =~ /^NSGlobalDomain$/
      # end
    end
  end

end
