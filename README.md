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

### Docker

```bash
docker run -p 80:80 -e DATABASE_URL=ecto://db_user:db_password@db_host/db -e SECRET_KEY_BASE=secret_string_REPLACE_ME cr.jbonet.xyz/jbonet/tvhstats
```

### Docker compose

```yaml
version: '3.8'
services:
  tvhstats:
    image: cr.jbonet.xyz/jbonet/tvhstats
    depends_on:
      - db
    environment:
      - DATABASE_URL=ecto://postgres:postgres@db/tvhstats
      - TVHSTATS_TVHEADEND_HOST=example.com
      - TVHSTATS_TVHEADEND_PORT=443
      - TVHSTATS_TVHEADEND_USE_HTTPS=1
      - TVHSTATS_TVHEADEND_USER=tvheadend_user
      - TVHSTATS_TVHEADEND_PASSWORD=tvheadend_password
      # Please set a secure string
      - SECRET_KEY_BASE=secret_string_REPLACE_ME
      # Optional parameters, these are the default values.
      - TVHSTATS_POLL_INTERVAL=1000 # optional
      - TVHSTATS_ICON_CACHE_ENABLED=1 # optional
      - TVHSTATS_ICON_CACHE_FOLDER=/icons # optional
      - TVHSTATS_CHANNEL_SURF_THRESHOLD=10000 # optional

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

### Dependencies

- PostgreSQL
- Erlang
- Elixir

For using it without docker, you will need to have installed Erlang and Elixir, then you can start the app running these commands.

```bash
mix deps.get
mix phx.server
```

You will need to set up the environment variables or edit `config/config.exs` and set your own values.

## License

[![License][badge-license]][License]

[badge-license]: https://img.shields.io/github/license/jbonet/tvhstats?style=flat-square

This is free software under the GPL v3 open source license. Feel free to do with it what you wish,
but any modification must be open sourced. A copy of the license is included.

[License]: https://github.com/jbonet/tvhstats/blob/master/LICENSE
