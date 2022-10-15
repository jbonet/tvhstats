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

Create an `.env` file to override the default config, read `.env.sample` to know which variables are available.

At the moment there is no public image available, build it running:

```bash
docker-compose up -d
```

### Bare-metal

At the moment, there are no releases, so you will need to compile the code and run the development version.

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
