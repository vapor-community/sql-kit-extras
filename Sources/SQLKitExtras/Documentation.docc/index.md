# ``SQLKitExtras``

A set of utilities intended to improve the usefulness of SQLKit 3 (and, nominally, Fluent 4).

The documentation comments (viewable most easily in Xcode) and the notes in this README are currently the extent of the documentation.

This is not an official Vapor project; it's something that [@gwynne](https://github.com/gwynne) does on her own time.

## Things **NOT** to expect

- I do not promise to answer questions that are already answered in this README.
- I do not promise to follow semver with this package.
- I do not promise to keep the API of this package stable.
- I do not promise to continue supporting any given Swift version other than the latest release.
- I do not promise not to add or remove things at random.
- I do not promise to make releases or tags for every change.
- I do not promise to continue paying attention to this package once Fluent 5 is ready.
- I do not promise to improve the test coverage past its current level, or even to keep it at the current level, especially with regards to the Fluent property wrappers.
- I do not promise to ever write any documentation for this package.
- I do not promise to keep the existing documentation comments up to date or to write new ones.
- I do not promise to respond to issues or pull requests, although I do intend to at least try.
- I **will not** release this package with a 1.0.0 or higher version number.

_In short, use at your own risk._

## Miscellaneous info

This package provides two traits:
  - `FluentSQLKitExtras`: This trait is **enabled by default**. It enables a number of utilities which permit the use of FluentKit models - mostly keypaths to the model properties - with SQLKit APIs. This is _separate_ from and does not affect the `FluentKitExtras` target, which provides additional utilities specifically for FluentKit.
  - `PostgreSQLKitExtras`: This trait is disabled by default. It enables several additional expressions and other utilties which require PostgreSQL-specific SQL syntax.

