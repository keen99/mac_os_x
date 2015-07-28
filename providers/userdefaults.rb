#
# Cookbook Name:: mac_os_x
# Provider:: userdefaults
#
# Copyright 2011, Joshua Timberman
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/mixin/shell_out'
require 'chef/mixin/language'
include Chef::Mixin::ShellOut

def load_current_resource
  @userdefaults = Chef::Resource::MacOsXUserdefaults.new(new_resource.name)
  @userdefaults.key(new_resource.key)
  @userdefaults.domain(new_resource.domain)
  Chef::Log.debug("Checking #{new_resource.domain} #{new_resource.key} new value: #{new_resource.value}")
  truefalse = 1 if [true, 'TRUE','1','true','YES','yes'].include?(new_resource.value)
  truefalse = 0 if [false, 'FALSE','0','false','NO','no'].include?(new_resource.value)
  drcmd = "defaults read '#{new_resource.domain}' "
  drcmd << "'#{new_resource.key}' " if new_resource.key
  shell_out_opts = {}
  shell_out_opts[:user] = new_resource.user unless new_resource.user.nil?
  vlong = shell_out("#{drcmd}", shell_out_opts)
  Chef::Log.debug("Checking #{new_resource.domain} #{new_resource.key} current value: stdout: [ #{vlong.stdout} ] stderr: [ #{vlong.stderr} ] ")

  v = shell_out("#{drcmd} | grep -qx '#{truefalse || new_resource.value}'", shell_out_opts)
  is_set = v.exitstatus == 0 ? true : false
  Chef::Log.debug("Checking #{new_resource.domain} #{new_resource.key} test result: [ #{v.stdout} ] [ #{v.stderr} ] [ #{v.exitstatus} ] ")
  @userdefaults.is_set(is_set)
end

action :write do
  unless @userdefaults.is_set
    cmd = ["defaults write"]
    cmd.unshift('sudo') if new_resource.sudo

    if new_resource.global
      cmd << "NSGlobalDomain"
    else
      cmd << "'#{new_resource.domain}'"
    end

    cmd << "'#{new_resource.key}'" if new_resource.key

    type = new_resource.type
    value = "'#{new_resource.value}'"
    case new_resource.value
    when TrueClass, FalseClass
      type ||= 'bool'
    when Integer
      type ||= 'int'
    when Float
      type ||= 'float'
    when Hash
      type ||= 'dict'

      # creates a string of Key1 Value1 Key2 Value2...
      value = new_resource.value.map {|k,v| "\"#{k}\" \"#{v}\"" }.join(' ')
    when Array
      type ||= 'array'
      value = new_resource.value.join("' '")
      value = "'#{value}'"
    end

    cmd << "-#{type}" if type
    cmd << value
    execute cmd.join(' ') do
      user new_resource.user unless new_resource.user.nil?
    end
    new_resource.updated_by_last_action(true)
  end
end
