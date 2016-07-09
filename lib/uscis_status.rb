require 'uscis_status/version'
require 'mechanize'
require 'nokogiri'
require 'open-uri'

module USCISStatus

  class USCISWebScraping
    CURRENT_CASE = "Your Current Case Status for"
    CERT_FILE = "Symantec Class 3 Secure Server CA - G4.crt"
    DATE_REGEX = /[\w]+\s\d{1,2},\s\d{4}/i
    TYPE_REGEX = /[a-zA-Z]-\d+/

    File.write(CERT_FILE, open("https://symantec.tbs-certificats.com/SymantecSSG4.crt", &:read))

    def self.check(application_numbers)
      # Check if the parameter is an Array, otherwise create one
      applications = application_numbers.kind_of?(Array) ? application_numbers : application_numbers.split

      statuses = []

      applications.each do |number|
        next if number.nil? or number.empty?

        mechanize = Mechanize.new{|a| a.ca_file = CERT_FILE }
        page = mechanize.post("https://egov.uscis.gov/casestatus/mycasestatus.do", { "appReceiptNum" => number })

        # Look for possible errors with this application number
        error = page.search('.formErrorMessages ul')
        if !error.empty?
          statuses << {number: number, type: 'NONE', status: error.text.strip, description: ''}
          next
        end

        # Get current application description block
        current_application = page.search('.rows.text-center')

        # Get the heading
        description = current_application.search('.rows.text-center h1').text.strip

        # Get the Description
        full_description = current_application.search('.rows.text-center p').text.strip

        # Get the application type and description (eg. Form I130...)
        application_type = full_description.match(TYPE_REGEX)[1]

        date = full_description.match(DATE_REGEX)[1]

        #steps = page.search('.//table[@id="buckets"]/tr/td')
        if description.include?('Approved') || description.include?('Card Was Mailed')
          status = "Approved"
          approved_date = date 
        else
          status = 'Pending'
          receipt_date = date
        end


        # Get the General Description for the Application
        #general_description = current_application.search('.//div[@id="bucketDesc"]').text.strip

        statuses << {number: number, type: application_type, status: status, approved_date: approved_date, 
                    receipt_date: receipt_date, description: description, full_description: full_description}

      end

      return statuses

    end

    private

    def self.capitalize_words(sentence)
      sentence.strip.split(' ').map{ |word| word.capitalize }.join(' ')
    end

  end

  def self.check(application_numbers)

    return USCISWebScraping.check(application_numbers)

  end

end
