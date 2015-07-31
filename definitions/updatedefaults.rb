

#this should probably take an arg:  what array to process... or just take the array.
#and what to kill.

###so I get the feeling, rightly so, that EVERY time I call back to this...they all process
##that's not great.

### without a param, we just process the whole set over and over again
### in my sample, chef run takes:
### with a param, we just process what we were told to (could be a subset of the whole, or it's own array)
### in my sample, chef run takes: 2m3.631s

define :updatedefaults, :processwhat => [], :killwhat => [] do

  processwhat=node['mac_os_x']['settings']

if params[:processwhat].to_a.empty?
#  processwhat=node['mac_os_x']['settings']
  log "updatedefaults: using default"
else
#  processwhat=params[:processwhat]
  log "updatedefaults: using param"
end


  log "updatedefaults: updating [[ #{processwhat}]]"



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
     params[:killwhat].each do |killwhat|
       notifies :run, "execute[killall #{killwhat.to_s}]" if ! params[:killwhat].to_a.empty?
     end
        notifies :run, "execute[killall Dock]" if settings['domain'] =~ /^com.apple.dock$/
        notifies :run, "execute[killall Dock]" if settings['domain'] =~ /^com.apple.dashboard$/
        notifies :run, "execute[killall Finder]" if settings['domain'] =~ /^com.apple.finder$/
        notifies :run, "execute[killall loginwindow]" if settings['domain'] =~ /^com.apple.spaces$/
      end
    end
  end

end
