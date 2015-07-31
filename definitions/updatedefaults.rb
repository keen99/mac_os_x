

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

  processwhat=node['mac_os_x']['settings']

if params[:processwhat].to_a.empty?
  processwhat=node['mac_os_x']['settings']
  log "updatedefaults: using default"
  mode="defaults"
else
  processwhat=params[:processwhat]
  mode="params"

  log "updatedefaults: using param"
end

##find the depth of our array we were handed.

  arr=processwhat
  b, depth = arr.dup, 1
  until b==arr.flatten
    depth+=1
    b=b.flatten(1)
  end
puts "#{mode} Array depth: #{depth}" #=> 4

## feh, depth = 2 in both cases.


def count_subarrays array
  return 0 unless array && array.is_a?(Array)

  nested = array.select { |e| e.is_a?(Array) }
  if nested.empty?
    1 # this is a leaf
  else
    nested.inject(0) { |sum, ary| sum + count_subarrays(ary) }
  end
end

puts "#{mode} New Array depth: #{count_subarrays(processwhat)}"
puts "#{mode} wtf depth #{processwhat.class}"
puts "#{mode} wtf else depth #{node['mac_os_x']['settings'].class}"


#  log "updatedefaults: updating |depth #{depth}| [[ #{processwhat} ]]"



#   ## ignore failure - depending on login state, these might not be running when chef runs.

#   execute "killall Dock" do
#     ignore_failure true
#     action :nothing
#   end
#   execute "killall Finder" do
#     ignore_failure true
#     action :nothing
#   end
#   execute "killall loginwindow" do
#     ignore_failure true
#     action :nothing
#   end


#   params[:killwhat].each do |killwhat|
#     log "DSR: killwhat #{killwhat}"
#     execute "killall #{killwhat}" do
#       ignore_failure true
#       action :nothing
#     end
#   end



#   processwhat.each do |domain,settings|
#     settings.each do |k,v|
#       next if k == 'domain'

#       mac_os_x_userdefaults "#{settings['domain']}-#{k}" do
#         domain settings['domain']
#         user node['mac_os_x']['settings_user']
#         key k
#         value v
#         sudo true if settings['domain'] =~ /^\/Library\/Preferences/
#         global true if settings['domain'] =~ /^NSGlobalDomain$/
# ##uh for multiples.. need a loop here
#      params[:killwhat].each do |killwhat|
#        notifies :run, "execute[killall #{killwhat.to_s}]" if ! params[:killwhat].to_a.empty?
#      end
#         notifies :run, "execute[killall Dock]" if settings['domain'] =~ /^com.apple.dock$/
#         notifies :run, "execute[killall Dock]" if settings['domain'] =~ /^com.apple.dashboard$/
#         notifies :run, "execute[killall Finder]" if settings['domain'] =~ /^com.apple.finder$/
#         notifies :run, "execute[killall loginwindow]" if settings['domain'] =~ /^com.apple.spaces$/
#       end
#     end
#   end

end
