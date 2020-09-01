#
# Fluentd Docker Metadata Filter Plugin - Enrich Fluentd events with Docker
# metadata
#
# Copyright 2015 Red Hat, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
require 'fluent/plugin/filter'
require 'json'
require 'lru_redux'

module Fluent::Plugin
  class DockerMetadataFilter < Fluent::Plugin::Filter
    Fluent::Plugin.register_filter('docker_metadata', self)

    config_param :docker_containers_path, :string, :default => '/var/lib/docker/containers'
    config_param :cache_size, :integer, :default => 100
    config_param :container_id_regexp, :string, :default => '(\w{64})'

    def get_metadata(container_id)
      get_docker_cfg_from_id(container_id) unless @id_to_docker_cfg.has_key? container_id
    end

    def initialize
      super
    end

    def configure(conf)
      super

      @id_to_docker_cfg = {}

      @cache = LruRedux::ThreadSafeCache.new(@cache_size)
      @container_id_regexp_compiled = Regexp.compile(@container_id_regexp)
      @hostname = ENV["HOSTNAME"]
    end

    def get_docker_cfg_from_id(container_id)
      begin
        config_path = "#{@docker_containers_path}/#{container_id}/config.v2.json"
        if not File.exists?(config_path)
          config_path = "#{@docker_containers_path}/#{container_id}/config.json"
        end
        docker_cfg = JSON.parse(File.read(config_path))
      rescue
        docker_cfg = nil
      end
      docker_cfg
    end

    def filter_stream(tag, es)
      new_es = es
      container_id = tag.match(@container_id_regexp_compiled)
      if container_id && container_id[0]
        container_id = container_id[0]
        metadata = @cache.getset(container_id){get_metadata(container_id)}

        if metadata
          new_es = Fluent::MultiEventStream.new

          es.each {|time, record|
            record['host'] = @hostname
            record['docker'] = {
              'container_id' => metadata['id'],
              'container_name' => metadata['Name'][1..-1],
              'container_hostname' => metadata['Config']['Hostname'],
              'container_image' => metadata['Config']['Image'],
              'swarm_namespace' => metadata['Config']['Labels']['com.docker.stack.namespace'] || 'None',
              'service_name' => metadata['Config']['Labels']['com.docker.swarm.service.name'] || 'None',
            }
          }
        end
      end
      return new_es
    end
  end

end
