require "bundler/setup"
require "circleci"


if ENV['RACK_ENV'].nil? || ENV['RACK_ENV'] != 'production'
  require 'dotenv' 
  Dotenv.load
end

tkn = ENV['CI_TOKEN']

CircleCi.configure do |config|
  config.token = tkn
end

$token = "?circle-token=#{tkn}"
$username = ENV['CI_USERNAME']
$repo = ENV['CI_REPOSITORY']

def fetch_pending_and_running_builds page=0, total_per_page=20
	builds = CircleCi.http.get "/project/#{$username}/#{$repo}#{$token}&offset=#{page * total_per_page}&limit=#{total_per_page}"
	builds.body
    .select{|e|e["status"] =~ /pending|running/}
end

def builds_in_the_same_branch
 build_vs_status = lambda { |hh,b| hh[b['build_num']] = b['status']; hh}

 builds = fetch_pending_and_running_builds
   .group_by{|e|e["branch"]}
   .map{|k,v| [k, v.inject({}, &build_vs_status)]}
end

def cancel_builds_in_the_same_branch
  builds = builds_in_the_same_branch
  puts "#{$username}/#{$repo}: #{builds.inspect}"
  builds.each do |branch, build_status|
    next if branch == "master"
    next if build_status.length <= 1
    build_status.keys.sort[0..-2].each do |build_num|
      puts "canceling: ##{build_num} ..."
      CircleCi::Build.cancel $username, $repo, build_num
      print ".!"
    end
  end
end

10.times do
  cancel_builds_in_the_same_branch
  puts "sleeping 50 secs"
  50.times do
    sleep 1
    print "."
  end
end
#require 'pry'
#binding.pry

