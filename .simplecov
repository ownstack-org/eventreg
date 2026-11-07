# frozen_string_literal: true

# Coverage gate for eventreg (2026-11-06).
#
# spec/spec_helper.rb starts it when COVERAGE is set; bin/ci-test sets it, and
# OwnStack's pre-deploy test gate runs bin/ci-test, so a build that drops below
# these numbers does not deploy.
#
# Every file under app/ and lib/ counts, loaded or not (the rails profile
# tracks them). The only paths left out are config/, db/ and spec/, which are
# configuration, migrations and schema, and the tests themselves.
SimpleCov.configure do
  load_profile "rails"
  coverage_dir ENV.fetch("COVERAGE_DIR", "coverage")
  enable_coverage :branch

  minimum_coverage line: 90, branch: 90
end
