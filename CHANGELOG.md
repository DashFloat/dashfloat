# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `Category` and `Envelope` resource and automatic creation of these records on `Book` creation. ([#23])

## [0.1.0] - 2023-11-22

### Added

- This repo which is a fresh Phoenix 1.7.9 web app.
- Use [AGPL-3.0](https://choosealicense.com/licenses/agpl-3.0/) as the license for this project. ([#1])
- CI pipeline through [GitHub Actions](https://github.com/features/actions). ([#3] [#4] [#5])
- Factories instead of Fixtures for testing. ([#6])
- Dialyzer integration and enforcement of spec types. ([#7])
- Authentication System courtesy of `mix phx.gen.auth`. ([#8])
- `Book` resource. ([#10])
- Layout based on [Flowbite](https://flowbite.com). ([#11])
- Containerization and Continuous Deployment to [Fly.io](https://fly.io). ([#12] [#17] [#18])
- Integration of [PostMark](https://postmarkapp.com) for sending emails. ([#19])

[Unreleased]: https://github.com/DashFloat/dashfloat/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/DashFloat/dashfloat/releases/tag/v0.1.0

[#23]: https://github.com/DashFloat/dashfloat/pull/23
[#19]: https://github.com/DashFloat/dashfloat/pull/19
[#18]: https://github.com/DashFloat/dashfloat/pull/18
[#17]: https://github.com/DashFloat/dashfloat/pull/17
[#12]: https://github.com/DashFloat/dashfloat/pull/12
[#11]: https://github.com/DashFloat/dashfloat/pull/11
[#10]: https://github.com/DashFloat/dashfloat/pull/10
[#8]: https://github.com/DashFloat/dashfloat/pull/8
[#7]: https://github.com/DashFloat/dashfloat/pull/7
[#6]: https://github.com/DashFloat/dashfloat/pull/6
[#5]: https://github.com/DashFloat/dashfloat/pull/5
[#4]: https://github.com/DashFloat/dashfloat/pull/4
[#3]: https://github.com/DashFloat/dashfloat/pull/3
[#1]: https://github.com/DashFloat/dashfloat/pull/1
