#!/usr/bin/env ruby
# Run './process-schools.rb'
require 'csv'
require 'open-uri'
require 'json'

class UpdateSchoolData
  def run
    save_csv_file
    schools = []

    puts csv_file_location
    puts "Processing schools…"

    CSV.foreach(csv_file_location, headers: true, encoding: 'windows-1251:utf-8').each do |row|
      school = convert_to_school(row)
      schools << school
    end

    puts "Found #{schools.length} schools"

    schools.each do |school|
      File.open("schools/#{school['urn']}.json", 'w') { |file| file.write(JSON.pretty_generate(school) + "\n") }
    end
  end

  private

  def convert_to_school(row)
    school = {}
    set_properties(school, row)
    school
  end

  def set_properties(school, row)
    school['urn'] = row['URN']
    school['name'] = row['EstablishmentName']
    school['address'] = row['Street']
    school['locality'] = row['Locality']
    school['address3'] = row['Address3']
    school['town'] = row['Town']
    school['county'] = row['County (name)']
    school['postcode'] = row['Postcode']
    school['minimum_age'] = row['StatutoryLowAge']
    school['maximum_age'] = row['StatutoryHighAge']
    school['easting'] = row['Easting']
    school['northing'] = row['Northing']
    school['url'] = row['SchoolWebsite']
    school['phase'] = row['PhaseOfEducation (name)']
    school['type'] = row['EstablishmentTypeGroup (name)']
    school['detailed_type'] = row['TypeOfEstablishment (name)']
  end

  def datestring
    Time.now.strftime('%Y%m%d')
  end

  def csv_file_location
    "edubasealldata#{datestring}.csv"
  end

  def save_csv_file(location: csv_file_location)
    File.open(location, 'wb') { |f| f.write(open(csv_url).read) } unless File.exist?(location)
  end

  def csv_url
    "http://ea-edubase-api-prod.azurewebsites.net/edubase/edubasealldata#{datestring}.csv"
  end
end

u = UpdateSchoolData.new
u.run
