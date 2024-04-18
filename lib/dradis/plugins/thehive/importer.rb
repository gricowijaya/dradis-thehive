module Dradis::Plugins::TheHive
  class Importer < Dradis::Plugins::Upload::Importer

    def self.templates
      { issue: 'warning' }
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
      logger.info { "This is the Data from The hive Case #{ data }"} # Added by Rico  

      unless data.key?("case_export")
        logger.error "ERROR: no 'case_export' field present in the provided "\
                     "data. Are you sure you uploaded a TheHive file?"
        exit(-1)
      end

      # choose a different parent based on the application path?
      case_export = template_service.process_template(template: 'case_export', data: data['scan_info'])
      content_service.create_note text: case_export

      #logger.info { "#{data['warnings'].count} Warnings\n===========" }

      #data['warnings'].each do |warning|
      #  logger.info { "* [#{warning['warning_type']}] #{warning['message']}" }

      #  warning_info = template_service.process_template(template: 'warning', data: warning)
      #  content_service.create_issue text: warning_info, id: warning['warning_code']
      #end

    end
  end
end
