#!/usr/bin/env python3
"""Tests for the rules. Run from the repo root: python3 ai/test_incident_analyzer.py"""

import unittest

from incident_analyzer import analyze, redact, render


class AnalyzeTests(unittest.TestCase):
    def test_healthy_logs_match_nothing(self):
        lines = ["✓ MongoDB Connected!", '{"status":"ok","db":"connected"}', "GET / 200"]
        self.assertEqual(analyze(lines), [])

    def test_mongodb_outage_is_the_likely_cause_over_its_symptoms(self):
        lines = [
            "Warning Unhealthy pod/server-1 Readiness probe failed: statuscode: 503",
            '{"status":"unavailable","db":"disconnected"}',
            "connect() failed (111: Connection refused) while connecting to upstream",
        ]
        findings = analyze(lines)
        self.assertEqual(findings[0].rule.name, "MongoDB unavailable")
        self.assertEqual(len(findings), 3)

    def test_each_known_signature_is_recognised(self):
        cases = {
            "Container out of memory": "Last State: Terminated Reason: OOMKilled",
            "Image cannot be pulled": "Warning Failed ImagePullBackOff",
            "API misconfigured": "TypeError: JwtStrategy requires a secret or key",
            "Pods restarting": "Back-off restarting failed container server",
            "API unreachable from Nginx": "upstream timed out (110) while reading response",
        }
        for name, line in cases.items():
            with self.subTest(name=name):
                self.assertEqual(analyze([line])[0].rule.name, name)

    def test_evidence_is_capped_but_every_line_is_counted(self):
        findings = analyze(["MongoNetworkError: failed"] * 20)
        self.assertEqual(findings[0].count, 20)
        self.assertEqual(len(findings[0].evidence), 5)


class RedactTests(unittest.TestCase):
    def test_secrets_are_removed(self):
        for line, secret in [
            ("JWT_SECRET=abc123 started", "abc123"),
            ("password: hunter2", "hunter2"),
            ("Authorization: Bearer ghp_abcdef", "ghp_abcdef"),
            ("mongodb://shop:s3cret@mongo:27017/db", "s3cret"),
        ]:
            with self.subTest(line=line):
                self.assertNotIn(secret, redact(line))

    def test_a_secret_never_reaches_the_report(self):
        report = render(analyze(["MongoNetworkError password=hunter2"]), 1)
        self.assertNotIn("hunter2", report)


class RenderTests(unittest.TestCase):
    def test_empty_report_says_nothing_was_found(self):
        self.assertIn("No known failure", render([], 10))

    def test_report_names_the_cause_and_the_fix(self):
        report = render(analyze(["MongoNetworkError: failed"]), 1)
        self.assertIn("Likely cause: MongoDB unavailable", report)
        self.assertIn("scale statefulset/mongo", report)


if __name__ == "__main__":
    unittest.main()
