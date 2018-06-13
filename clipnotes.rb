#!/usr/bin/env ruby
require 'configatron'
require 'cinch'
require 'cinch/commands'
require 'sequel'
require 'pg'
require 'rest-client'
require 'oj'
require_relative 'defaults.rb'
@uptime = nil

def livetime
	chan = RestClient.get "https://api.twitch.tv/helix/streams?user_id=#{configatron.twitch.channel}", { :'Client-ID' => configatron.twitch.clientid }

	inchan = Oj.load(chan).fetch('data').first.fetch('started_at')
	timestart = Time.parse(inchan)
	timecurrent = Time.now.utc
	mathtime = (timecurrent.to_i - timestart.to_i).abs
	@uptime = Time.at(mathtime).utc.strftime("%H:%M:%S")
end

class Mark
	include Cinch::Plugin
	include Cinch::Commands

	command :clip, {
		arg1: :text
	}, 

	summary: "Make a cliper for a highlight you want to make later.", 
	discription: %{
 use !clip to make a markers
	}

	def clip(m, arg1)
		if arg1 == "help"
			m.reply "{m.user.nick}, To make a marker for a highlight do: !clip <something noteworthy that happened.>"

		else
			db = Sequel.connect("postgres://#{configatron.sql.user}:#{configatron.sql.pass}@localhost:5432/clipnotes")

			markers = db.from(:markers)
			clipnote = arg1
			clipuser = m.user.nick
			cliptime = livetime
			attime = Time.now.to_s
			m.reply "#{m.user.nick}, A marker was created at #{cliptime} for \"#{clipnote}\"."

			markers.insert(user: clipuser, note: clipnote, uptime: cliptime, created_at: attime, updated_at: attime)
		end
	end
end


bot = Cinch::Bot.new do
	configure do |c|
		c.server = "irc.chat.twitch.tv"
		c.password = configatron.twitch.oauth
		c.channels = [configatron.twitch.irc]
		c.plugins.plugins = [Mark]
		c.user = configatron.irc.nick
		c.nick = configatron.irc.nick
	end
end

bot.start
