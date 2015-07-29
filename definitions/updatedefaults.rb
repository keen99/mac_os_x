

#this should probably take an arg:  what array to process... or just take the array.
#and what to kill.

define :updatedefaults, :killwhat => [] do


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


  params[:killwhat].each do |killwhat|
    log "DSR: killwhat #{killwhat}"
    execute "killall #{killwhat}" do
      ignore_failure true
      action :nothing
    end
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
##uh for multiples.. need a loop here
       notifies :run, "execute[killall #{params[:killwhat].to_s}]" if ! params[:killwhat].to_a.empty?
        notifies :run, "execute[killall Dock]" if settings['domain'] =~ /^com.apple.dock$/
        notifies :run, "execute[killall Dock]" if settings['domain'] =~ /^com.apple.dashboard$/
        notifies :run, "execute[killall Finder]" if settings['domain'] =~ /^com.apple.finder$/
        notifies :run, "execute[killall loginwindow]" if settings['domain'] =~ /^com.apple.spaces$/
      end
    end
  end

end
