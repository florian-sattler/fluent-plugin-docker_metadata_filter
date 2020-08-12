# fluent-plugin-docker_metadata_filter, a plugin for [Fluentd](http://fluentd.org)

## Installation

I still need to build an official gem... for the time being you have to build this yourself.

## Configuration
```
<source>
  @type tail
  path /var/lib/docker/containers/*/*-json.log
  pos_file /fluentd/pos/docker.pos
  tag docker.*
  <parse>
    @type json
    time_key time
    time_format %Y-%m-%dT%H:%M:%S.%L
  </parse>
  read_from_head true
</source>

<filter docker.var.lib.docker.containers.*.*.log>
  @type docker_metadata
</filter>

<match **>
  type stdout
</match>
```

Docker logs in JSON format. Log files are normally in
`/var/lib/docker/containers/*/*-json.log`, depending on what your Docker
data directory is.

Assuming following inputs are coming from a log file:
df14e0d5ae4c07284fa636d739c8fc2e6b52bc344658de7d3f08c36a2e804115-json.log:
```
{
  "log": "2015/05/05 19:54:41 \n",
  "stream": "stderr",
  "time": "2015-05-05T19:54:41.240447294Z"
}
```

Then output becomes as belows
```
{
  "log": "2015/05/05 19:54:41 \n",
  "stream": "stderr",
  "docker": {
    "container_id": "df14e0d5ae4c07284fa636d739c8fc2e6b52bc344658de7d3f08c36a2e804115",
    "container_name": "k8s_fabric8-console-container.efbd6e64_fabric8-console-controller-9knhj_default_8ae2f621-f360
-11e4-8d12-54ee7527188d_7ec9aa3e",
    "container_hostname": "fabric8-console-controller-9knhj",
    "container_image": "fabric8/hawtio-kubernetes:latest"
  }
}
```
## Running in Docker
Create and build a Dockerfile similar to the one below:
```
FROM fluent/fluentd:v1.11-1
MAINTAINER <maintainer>

USER root

RUN apk add --no-cache --update --virtual .build-deps \
        sudo build-base ruby-dev git \
 # cutomize following instruction as you wish
 && git clone https://github.com/corbanvilla/fluent-plugin-docker_metadata_filter.git \
 && cd /fluent-plugin-docker_metadata_filter \
 && gem build fluent-plugin-docker_metadata_tb_filter.gemspec \
 && gem install fluent-plugin-docker_metadata_tb_filter-0.3.3.gem \
 && sudo gem sources --clear-all \
 && apk del .build-deps \
 && rm -rf /home/fluent/.gem/ruby/2.5.0/cache/*.gem

RUN mkdir /fluentd/pos/ \
 && touch /fluentd/pos/docker.pos \
 && chown fluent:fluent /fluentd/pos/docker.pos

COPY entrypoint.sh /bin/
COPY *.conf /fluentd/etc/

USER fluent
```

Then you can launch it with something like:

```
version: '3'
services:
  fluentd:
    image: <my_image>
    environment:
    - HOSTNAME=
    volumes:
    - /var/lib/docker/containers/:/var/lib/docker/containers/:ro
    - pos-file:/fluentd/pos/

volumes:
  pos-file:
```

Note: This fork no longer uses the docker socket to add metadata, and instead uses the `config.v2.json` file. Access to the docker socket can provide root access to the host machine, and required the container to run as root.

## Running Tests
```
bundle install
bundle exec rake test
```
## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Update and verify tests are successful (See `Running Tests`)
6. Create new Pull Request

## Copyright
  Copyright (c) 2015 jimmidyson
