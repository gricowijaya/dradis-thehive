module Dradis::Plugins::TheHive
  class Importer < Dradis::Plugins::Upload::Importer

    def self.templates
      { issue: 'issue' }
    end

    # The framework will call this function if the user selects this plugin from
    # the dropdown list and uploads a file.
    # @returns true if the operation was successful, false otherwise
    def import(params={})

      file_content = File.read( params[:file] )

      # Parse the uploaded file into a Ruby Hash
      logger.info { "Parsing TheHive output from #{ params[:file] }..." }
      data = MultiJson.decode(file_content)
      logger.info { 'Done.' }
      logger.info { "There are #{ data.length } Case from TheHive."} # Added by Rico  

      if data[0].key?("_type") && data[0].key?("_createdBy") && data[0].key?("severityLabel") && data[0].key?("tlpLabel") && data[0].key?("papLabel")
        logger.info { "This JSON file appears to be from TheHive." }
      else
        logger.info { "This JSON file does not appear to be from TheHive." }
      end
      #unless data.key?("case_export")
      #  logger.error "ERROR: no 'case_export' field present in the provided "\
      #               "data. Are you sure you uploaded a TheHive file?"
      #  #exit(-1)
      #  return false
      #end

      # choose a different parent based on the application path?
      #case_export = template_service.process_template(template: 'case_export', data: data)
      #content_service.create_note text: case_export

      #logger.info { "#{data['warnings'].count} Warnings\n===========" }

      #data['warnings'].each do |warning|
      #  logger.info { "* [#{warning['warning_type']}] #{warning['message']}" }

      #  warning_info = template_service.process_template(template: 'warning', data: warning)
      #  content_service.create_issue text: warning_info, id: warning['warning_code']
      #end
      return true

    end

    def process_case_item()
  end
end
