#!/usr/bin/env ruby
require 'configatron'
require 'pg'
require 'sequel'
require_relative 'defaults.rb'

DB = Sequel.connect("postgres://#{configatron.sql.user}:#{configatron.sql.pass}@localhost:5432/clipnotes")

DB.create_table :markers do
	primary_key :id
	String :user
	String :note
	String :uptime
	datetime :created_at
end
