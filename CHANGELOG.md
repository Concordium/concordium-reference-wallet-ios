# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Removed election difficulty from expected chain parameters.
- Fix string handling which broke unicode support.

## [1.1.0] - 2023-07-13

### Added

- WalletConnect integration (preliminary implementation): Supports signing string messages (not binary) and signing/submitting transactions (currently only smart contract updates).
  The only entrypoint to WalletConnect is the "scan QR" button on the account list screen (for scanning QR code on web-based dApps).
  In particular, deep linking is not implemented; nor can you paste a "wc://" URI from the clipboard.

## [1.0.1]

Last release without changelog.