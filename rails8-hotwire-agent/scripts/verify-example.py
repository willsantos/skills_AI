#!/usr/bin/env python3
"""Create a new disposable Rails sandbox and test the bundled Hotwire example."""
import argparse
from datetime import datetime, timedelta
import os
from pathlib import Path
import secrets
import shutil
import subprocess


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("destination", type=Path, help="New directory outside an existing Rails application")
    parser.add_argument("--system", action="store_true", help="Also run real Chrome/Selenium system tests")
    parser.add_argument("--local", action="store_true", help="Use local cache for the initial bundle install; Rails installers may still contact the registry")
    args = parser.parse_args()
    skill = Path(__file__).resolve().parents[1]
    destination = args.destination.resolve()
    # Reserve a brand-new directory atomically; never overwrite user work.
    destination.mkdir(parents=True, exist_ok=False)
    environment = dict(os.environ, RAILS_ENV="test", RACK_ENV="test", DISABLE_SPRING="1")
    for key in ("DATABASE_URL", "RAILS_MASTER_KEY", "SECRET_KEY_BASE", "BUNDLE_GEMFILE", "TEST_SUITE", "CI_REVIEWED"):
        environment.pop(key, None)
    environment["SECRET_KEY_BASE"] = secrets.token_hex(64)

    def run(*command):
        subprocess.run(command, cwd=destination, env=environment, check=True)

    run("rails", "_8.1.3.1_", "new", str(destination), "--name", "HotwireSkillExample", "--no-rc", "--quiet",
        "--skip-bundle", "--skip-git", "--skip-docker", "--skip-kamal", "--skip-solid",
        "--skip-action-mailbox", "--skip-action-text", "--skip-active-storage", "--skip-action-cable",
        "--skip-jbuilder", "--skip-bootsnap", "--skip-dev-gems", "--skip-thruster",
        "--skip-rubocop", "--skip-brakeman", "--skip-bundler-audit", "--skip-ci")
    (destination / "Gemfile").write_text('''source "https://rubygems.org"
gem "rails", "8.1.3.1"
gem "propshaft", "1.3.2"
gem "sqlite3", "2.9.5"
gem "puma", "8.0.2"
gem "importmap-rails", "2.2.3"
gem "turbo-rails", "2.0.23"
gem "stimulus-rails", "1.3.4"
gem "bcrypt", "3.1.22"
group :test do
  gem "capybara", "3.40.0"
  gem "selenium-webdriver", "4.47.0"
end
''', encoding="utf-8")
    run("bundle", "install", *(["--local"] if args.local else []))
    run("bin/rails", "generate", "authentication", "--quiet")
    run("bin/rails", "importmap:install", "turbo:install", "stimulus:install")
    shutil.copytree(skill / "assets/example", destination, dirs_exist_ok=True)
    migrations = destination / "db/migrate"
    newest = max(datetime.strptime(path.name[:14], "%Y%m%d%H%M%S")
                 for path in migrations.glob("[0-9]*_*.rb"))
    timestamp = (newest + timedelta(seconds=1)).strftime("%Y%m%d%H%M%S")
    (migrations / "create_tasks.rb").rename(migrations / f"{timestamp}_create_tasks.rb")
    # These files were generated above in our new sandbox, not supplied by a user.
    # Keep the suite focused on the skill example, not generator snapshot tests.
    for generated in ("test/controllers/sessions_controller_test.rb", "test/controllers/passwords_controller_test.rb"):
        (destination / generated).unlink(missing_ok=True)
    user = destination / "app/models/user.rb"
    user.write_text(user.read_text().replace("class User < ApplicationRecord", "class User < ApplicationRecord\n  has_many :tasks, dependent: :destroy", 1))
    routes = destination / "config/routes.rb"
    routes.write_text(routes.read_text().replace("Rails.application.routes.draw do", '''Rails.application.routes.draw do
  root "tasks#index"
  resources :tasks, only: [:index, :new, :show, :create, :update]''', 1))
    # Only this sandbox's local SQLite test database exists; never inherit DATABASE_URL.
    (destination / "config/database.yml").write_text('''test:
  adapter: sqlite3
  database: storage/test.sqlite3
  pool: 5
  timeout: 5000
''', encoding="utf-8")
    run("bin/rails", "db:migrate")
    run("bash", str(skill / "scripts/check.sh"), "full" if args.system else "fast")
    if not args.system:
        print("NOT EXECUTED: browser system tests. Run again in a new sandbox with --system.", flush=True)
    print(f"Sandbox and Gemfile.lock preserved at {destination}", flush=True)


if __name__ == "__main__":
    main()
