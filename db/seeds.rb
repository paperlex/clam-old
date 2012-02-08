# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Emanuel', :city => cities.first)

slaw = Paperlex::Slaw.create({:name => "Default CLA", :body => File.open("#{Rails.root}/db/seeds/default_cla.paperlexml").read})
ClaTemplate.create(:name => "Default CLA", :slaw_uuid => slaw.uuid)