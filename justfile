# See https://github.com/sablier-labs/devkit/blob/main/just/evm.just
# Run just --list to see all available commands
import "./node_modules/@sablier/devkit/just/evm.just"

default:
  @just --list

coverage:
  forge coverage --report lcov
  genhtml --ignore-errors inconsistent lcov.info --branch-coverage --output-dir coverage
