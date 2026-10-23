#!/usr/bin/env python3
"""Regression tests for the gate using isolated runner stubs, not a Rails app."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

SCRIPT = Path(__file__).with_name("check.sh").resolve()


class GateTests(unittest.TestCase):
    def setUp(self):
        base = "/tmp/opencode" if Path("/tmp/opencode").is_dir() else None
        self.temp = tempfile.TemporaryDirectory(prefix="rails-gate-", dir=base)
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / "Gemfile").write_text("# Stub sandbox\n")
        self.env = {key: value for key, value in os.environ.items()
                    if key not in ("TEST_SUITE", "CI_REVIEWED")}
        self.env.update(RAILS_ENV="test", RACK_ENV="test")
        self.stub("bin/rails", 'if [[ "$1" == test* ]]; then echo "2 runs, 3 assertions, 0 failures, 0 errors, 0 skips"; fi')

    def stub(self, name, body):
        path = self.root / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text("#!/usr/bin/env bash\nset -eu\n" + body + "\n")
        path.chmod(0o755)

    def run_gate(self, mode="fast", **environment):
        return subprocess.run(["bash", str(SCRIPT), mode], cwd=self.root,
                              env=dict(self.env, **environment), capture_output=True, text=True)

    def test_minitest_success_and_missing_checks_reported(self):
        result = self.run_gate()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("2 testes/examples", result.stdout)
        self.assertIn("NAO EXECUTADO: bin/brakeman", result.stdout)

    def test_zero_tests_fail(self):
        self.stub("bin/rails", 'echo "0 runs, 0 assertions, 0 failures, 0 errors, 0 skips"')
        self.assertNotEqual(self.run_gate().returncode, 0)

    def test_all_skipped_fail(self):
        self.stub("bin/rails", 'echo "2 runs, 0 assertions, 0 failures, 0 errors, 2 skips"')
        self.assertNotEqual(self.run_gate().returncode, 0)

    def test_nonzero_runner_exit_propagates(self):
        self.stub("bin/rails", 'echo "2 runs, 3 assertions, 0 failures, 0 errors, 0 skips"; exit 7')
        self.assertNotEqual(self.run_gate().returncode, 0)

    def test_unrecognized_output_fails(self):
        self.stub("bin/rails", 'echo "Everything seems fine"')
        self.assertNotEqual(self.run_gate().returncode, 0)

    def test_production_and_staging_blocked(self):
        for key in ("RAILS_ENV", "RACK_ENV"):
            for value in ("production", "staging"):
                with self.subTest(key=key, value=value):
                    self.assertEqual(self.run_gate(**{key: value}).returncode, 2)

    def test_local_commands_use_test_environment(self):
        self.stub("bin/rails", '[[ "$RAILS_ENV" == test && "$RACK_ENV" == test ]]; echo "1 runs, 1 assertions, 0 failures, 0 errors, 0 skips"')
        self.assertEqual(self.run_gate(RAILS_ENV="development", RACK_ENV="development").returncode, 0)

    def test_rspec_selected(self):
        (self.root / "spec").mkdir()
        self.stub("bin/rspec", 'echo "$*"; echo "3 examples, 0 failures"')
        result = self.run_gate()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("--exclude-pattern", result.stdout)

    def test_pending_rspec_examples_are_not_executed_tests(self):
        (self.root / "spec").mkdir()
        self.stub("bin/rspec", 'echo "3 examples, 0 failures, 3 pending"')
        self.assertNotEqual(self.run_gate().returncode, 0)

    def test_mixed_suites_require_choice(self):
        for name in ("test/model_test.rb", "spec/model_spec.rb"):
            path = self.root / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.touch()
        self.assertEqual(self.run_gate().returncode, 2)
        self.assertEqual(self.run_gate(TEST_SUITE="minitest").returncode, 0)

    def test_ci_requires_review_and_is_not_run_in_local_mode(self):
        self.stub("bin/ci", 'touch ci-ran; echo "1 runs, 1 assertions, 0 failures, 0 errors, 0 skips"')
        self.assertEqual(self.run_gate().returncode, 0)
        self.assertFalse((self.root / "ci-ran").exists())
        self.assertEqual(self.run_gate("ci").returncode, 2)
        self.assertEqual(self.run_gate("ci", CI_REVIEWED="1").returncode, 0)
        self.assertTrue((self.root / "ci-ran").exists())

    def test_full_requires_nonempty_system_suite(self):
        self.stub("bin/rails", 'if [[ "$1" == "test:system" ]]; then echo "0 runs, 0 assertions, 0 failures, 0 errors, 0 skips"; else echo "1 runs, 1 assertions, 0 failures, 0 errors, 0 skips"; fi')
        self.assertNotEqual(self.run_gate("full").returncode, 0)


if __name__ == "__main__":
    unittest.main()
