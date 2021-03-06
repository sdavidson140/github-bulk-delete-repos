require 'json'
require 'io/console'
require 'colorize'

puts 'What is your Github username?'
USERNAME = STDIN.gets.chomp

puts 'What is your Github password?'
PASSWORD = STDIN.noecho(&:gets).chomp

def delete_repo!(owner, repo_name)
  puts "\nEnter [Y/y] to confirm delete.".colorize(:red)
  confirmation = STDIN.gets.chomp
  if confirmation =~ /^[Yy]([Ee][Ss])?$/
    `curl --request DELETE -u "#{USERNAME}:#{PASSWORD}" "https://api.github.com/repos/#{owner}/#{repo_name}"`
    puts "You have successfully deleted repo: #{repo_name}".colorize(:green).underline
  else
    puts 'Moving to next repo...'
  end
end

json_response = `curl -u "#{USERNAME}:#{PASSWORD}" 'https://api.github.com/users/#{USERNAME}/repos?sort=updated&direction=asc'`
if json_response.include? 'Bad credentials'
  abort 'There was an issue w/ username or password. '\
  'Please try again.'.colorize(:red)
end
repositories = JSON.parse(json_response)
repositories.each do |repo|
  repo_name = repo['name']
  description = repo['description']
  owner = repo['owner']['login']
  is_private = repo['private']
  is_fork = repo['fork']
  is_admin = repo['permissions']['admin']
  puts "\nWould you like to delete #{repo_name.colorize(:blue)}?"
  puts "  Owned by #{owner}"
  puts "  #{description}" unless description.nil?
  puts '  This is a private repo.' if is_private
  puts '  This is a forked repo.' if is_fork
  puts "\nType [Y/y] to delete, or press any key to continue."
  response = STDIN.gets.chomp
  if response =~ /^[Yy]([Ee][Ss])?$/
    if is_admin
      puts 'WARNING: You are not the owner of this repo!' if USERNAME != owner
      delete_repo!(owner, repo_name)
    else
      puts 'Must be an admin of repo to delete.'
    end
  elsif response == 'exit' || response == 'quit'
    exit(0)
  end
end
