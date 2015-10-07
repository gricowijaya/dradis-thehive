class BrakemanTasks < Thor
  include Core::Pro::ProjectScopedTask if defined?(::Core::Pro)


  namespace "dradis:plugins:brakeman"

  desc      "upload FILE", "upload Brakeman results in JSON format"
  long_desc "This plugin expect a JSON file generated by Brakeman using: -f "\
            "jason -o results.json"
  def upload(file_path)
    require 'config/environment'

    unless File.exists?(file_path)
      $stderr.puts "** the file [#{file_path}] does not exist"
      exit(-1)
    end

    # Set project scope from the PROJECT_ID env variable:
    detect_and_set_project_scope if defined?(::Core::Pro)

    plugin = Dradis::Plugins::Brakeman

    Dradis::Plugins::Brakeman::Importer.new(
      logger:           logger,
      content_service:  service_namespace::ContentService.new(plugin: plugin),
      template_service: service_namespace::TemplateService.new(plugin: plugin)
    ).import(file: file_path)

    logger.close
  end

  private

  def logger
    @logger ||= Logger.new(STDOUT).tap { |l| l.level = Logger::DEBUG }
  end

  def service_namespace
    defined?(Dradis::Pro) ? Dradis::Pro::Plugins : Dradis::Plugins
  end

end
