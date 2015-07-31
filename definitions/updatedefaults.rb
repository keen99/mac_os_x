

#this should probably take an arg:  what array to process... or just take the array.
#and what to kill.

###so I get the feeling, rightly so, that EVERY time I call back to this...they all process
##that's not great.

### without a param, we just process the whole set over and over again
### in my sample, chef run takes:
## 1.3-2.5m
#real  1m58.191s

### with a param, we just process what we were told to (could be a subset of the whole, or it's own array)
### in my sample, chef run


define :updatedefaults, :processwhat => [], :killwhat => [] do




  if params[:processwhat].to_a.empty?
    processwhat=node['mac_os_x']['settings']
    log "updatedefaults: using default"
    mode="defaults"
  else
    processwhat=params[:processwhat]
    mode="params"
    log "updatedefaults: using param"
  end

#  processwhat=node['mac_os_x']['settings']


  ## 2 for the default, 1 for something we pass in.
  def hash_depth(hash)
    a = hash.to_a
    d = 1
    while (a.flatten!(1).map! {|e| (e.is_a? Hash) ? e.to_a.flatten(1) : (e.is_a? Array) ? e : nil}.compact!.size > 0)
        d += 1
    end
    return d
  end

  ##find the depth of the mash we were handed.
  depth=hash_depth(processwhat)
## we could just use the param/default logic, but this lets us pass a deeper set...

log "updatedefaults: updating |depth #{depth}| [[ #{processwhat} ]]"



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


  #pull this out of the outer loop so we can call it instead.
    def settingsloop(settings)
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


  #using the default node attribute
  if depth == 2
    processwhat.each do |domain,settings|
      settingsloop(settings)
    end
  ##passed as a param, so no outer loop
  elsif depth == 1
    settingsloop(processwhat)
  else
    raise "ERROR: userdefaults processwhat param mash is deeper than 2, so it must be broke.  should only be 1 or 2 deep."
  end

end
