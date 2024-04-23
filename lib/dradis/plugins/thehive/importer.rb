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
        logger.error "ERROR: no '_type', '_createdBy', 'severityLabel', 'tlpLabel' and 'papLabel' field present in the provided "\
                     "data. Are you sure you uploaded a TheHive file?"
      end

      # iterates through the array of JSON
      data.each do |case_item|
        process_agent(case_item)
        process_case_item(case_item)
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

    private
    attr_accessor :site_node

    def process_agent(case_item)
      logger.info { "Case ID: #{case_item['_id']}" }
      logger.info { "Title: #{case_item['title']}" }
      logger.info { "Rule ID: #{case_item['tags'][1]}" }
      logger.info { "Agent IP: #{case_item['tags'][2]}" }
      logger.info { "Severity: #{case_item['severityLabel']}" }
      logger.info { "TLP: #{case_item['tlpLabel']}" }
      logger.info { "PAP: #{case_item['papLabel']}" }
      logger.info { "Created At: #{case_item['_createdAt']}" }
      logger.info { "Created By: #{case_item['_createdBy']}" }

      # Extract the the agent IP address from the tag
      agent_ip = case_item['tags'][2] 
      case_item['tags'].each do |tag|
        content_service.create_note text: tag
      end

      site_node = content_service.create_node( label: agent_ip, type: :host, parent: site_node )
    end

    def process_case_item(case_item)
      issue_text = template_service.process_template(template: 'issue', data: case_item)
      issue = content_service.create_issue(text: issue_text, id: case_item['_id'])
      content_service.create_evidence(issue: issue, note site_node, content: case_item['description'])
    end
  end
end
