# TVHStats

An elixir based web application for monitoring and analytics for [tvheadend](https://github.com/tvheadend/tvheadend).

## Features

- Monitor current activity in realtime
- Top statistics for last 30 days.
- Stream history

## Roadmap

- Search and filter on history.
- Selectable time range for statistics.
- Show more statistics.
- Graphs.
- User and Channel list to show richer information, to show per user history and per channel activity.
- Improve interface on mobile.

## Installation

You must pass a SECRET_KEY_BASE environment variable of at least 64 characters long.

### Docker

```bash
docker run -p 80:80 -e DATABASE_URL=ecto://db_user:db_password@db_host/db -e SECRET_KEY_BASE=secret_string_REPLACE_ME cr.jbonet.xyz/jbonet/tvhstats
```

### Docker compose

At the moment there are two flavors of the image:

- `latest`, `debian` running debian bullseye
- `alpine` running alpine 3.16.2

The main difference is the image size, around 70MB for debian, and around 15MB for the alpine based.


```yaml
version: '3.8'
services:
  tvhstats:
    image: cr.jbonet.xyz/jbonet/tvhstats:latest
    depends_on:
      - db
    environment:
      - DATABASE_URL=ecto://postgres:postgres@db/tvhstats
      - PHX_HOST=ip_or_hostname # the ip or hostname from where you will access the app ie: tvstats.local, 192.168.1.100:8080
      - TVHSTATS_TVHEADEND_HOST=tvheadend_ip_or_hostname
      - TVHSTATS_TVHEADEND_PORT=443
      - TVHSTATS_TVHEADEND_USE_HTTPS=1
      - TVHSTATS_TVHEADEND_USER=tvheadend_user
      - TVHSTATS_TVHEADEND_PASSWORD=tvheadend_password
      # Please set a secure string
      - SECRET_KEY_BASE=secret_string_REPLACE_ME
      # Optional parameters, these are the default values.
      - TVHSTATS_POLL_INTERVAL=1000 # optional
      - TVHSTATS_ICON_CACHE_ENABLED=1 # optional
      - TVHSTATS_CHANNEL_SURF_THRESHOLD=10000 # optional
      - TVHSTATS_TIMEZONE=Etc/UTC # Pass an IANA timezone. ie: Europe/Madrid, America/Los_Angeles
    ports:
      - "80:80"
  
  # Database does not need to be run from docker, added for convenience.
  db:
    image: postgres:latest
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_DB=tvhstats
    volumes:
      - db:/var/lib/postgresql/data
volumes:
  db:
```

An explanation of each environment variable can be found in the `.env.sample` file.

### Bare-metal

At the moment, there are no releases, so you will need to compile the code and run the development version.

Later on I will provide binaries for those who don't want to use docker version.

If you know what you are doing, you will need to have installed Erlang and Elixir, then you can start the app running:

```bash
mix deps.get
mix phx.server
```

You will need to set up the environment variables or edit `config/runtime.exs` and set your own values.

### Dependencies

- PostgreSQL
- Erlang
- Elixir

## License

[![License][badge-license]][License]

[badge-license]: https://img.shields.io/github/license/jbonet/tvhstats?style=flat-square

This is free software under the GPL v3 open source license. Feel free to do with it what you wish,
but any modification must be open sourced. A copy of the license is included.

[License]: https://github.com/jbonet/tvhstats/blob/master/LICENSE
