require 'uscis_status/version'
require 'mechanize'
require 'nokogiri'
require 'open-uri'

module USCISStatus

  class USCISWebScraping
    CURRENT_CASE = "Your Current Case Status for"
    CERT_FILE = "Symantec Class 3 Secure Server CA - G4.crt"

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
          statuses << {number: number, type: 'NONE', status: error.text.strip, description: '', general_description: '', complete: ''}
          next
        end

        # Get the application type and description (eg. Form I130...)
        #application_type = capitalize_words(page.search('.//div[@id="caseStatus"]/h3').text.gsub(CURRENT_CASE, ""))
        application_type = 'I-486'

        # Get current application block
        current_application = page.search('.rows.text-center p')

        # Verify if it's in the final step a.k.a 'Complete'
        #steps = page.search('.//table[@id="buckets"]/tr/td')
        #complete = steps[steps.count - 1]["class"] == "current" ? "true" : "false"
        complete = "true"

        # Get the Status
        status = page.search('.rows.text-center h1').text.strip

        # Get the Description
        description = page.search('.rows.text-center p').text.strip

        # Get the General Description for the Application
        #general_description = current_application.search('.//div[@id="bucketDesc"]').text.strip
        general_description = 'Nothing'

        statuses << {number: number, type: application_type, status: status, description: description, general_description: general_description, complete: complete}

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
