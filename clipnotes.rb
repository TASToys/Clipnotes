#!/usr/bin/env ruby
require 'configatron'
require 'cinch'
require 'cinch/commands'
require 'sequel'
require 'pg'
require 'rest-client'
require 'oj'
require_relative 'config.rb'

class Clip
	include Cinch::Plugin
	include Cinch::Commands

	command :clip, {arg1: :string},
		summary: "Make a marker for a highlight you want to make later.",
		discription: %{
		use !clip to make a marker
		}

	def clip(m,arg1)
		db = Sequel.connect("postgres://#{configatron.sql.user}:#{configatron.sql.pass}@localhost:5432/clipnotes")
		markers = db.from(:markers)
		clipnote = arg1
		clipuser = m.user.nick
		clipmark = nil
		cliptime = Time.now.to_s
		
