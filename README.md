# rosie

[![Build Status](https://travis-ci.org/aergonaut/rosie.svg?branch=master)](https://travis-ci.org/aergonaut/rosie)

**Rosie** helps keep your repository tidy by ensuring your contributors follow
a standard format for commit messages and Pull Request titles.

**Disclaimer**: Currently, Rosie is intended for use only by my coworkers and I
at my day job. Given that, the code is very opinionated and probably won't be
useful to you without some serious customization. Some of the checks probably
don't make sense at all outside of our projects. YMMV.

## Features

- [x] Check incoming Pull Requests against a library of different checks
- [x] Warn of violations in a comment posted on the Pull Request
- [ ] Optionally add a failed status to the PR if a standard is broken

### Supported checks

- [x] Pull Request title follows standard format
- [ ] Commit message follows standard format
- [x] If the commit introduces a migration, the timestamp in `schema.rb` must be
\>= the timestamp of the migration

## License

MIT.
