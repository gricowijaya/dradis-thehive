module Dradis::Plugins::TheHive
  class Engine < ::Rails::Engine
    isolate_namespace Dradis::Plugins::TheHive

    include ::Dradis::Plugins::Base
    description 'Processes TheHive JSON output, use: thehive -f json -o results.json'
    provides :upload
  end
end
