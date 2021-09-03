#!/usr/bin/python3
# Copyright (c) 2013 The CoreOS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

import http.server
import os
import select
import signal
import subprocess
import threading
import time
import unittest

from http import HTTPStatus

script_path = os.path.abspath('%s/../../bin/block-until-url' % __file__)


class UsageTestCase(unittest.TestCase):

    def test_no_url(self):
        proc = subprocess.Popen([script_path],
                                stdout=subprocess.PIPE,
                                stderr=subprocess.PIPE)
        out, err = proc.communicate()
        self.assertEqual(proc.returncode, 1)
        self.assertEqual(out, b'')
        self.assertIn(b'invalid url', err)

    def test_invalid_url(self):
        proc = subprocess.Popen([script_path, 'fooshizzle'],
                                stdout=subprocess.PIPE,
                                stderr=subprocess.PIPE)
        out, err = proc.communicate()
        self.assertEqual(proc.returncode, 1)
        self.assertEqual(out, b'')
        self.assertIn(b'invalid url', err)


class TestRequestHandler(http.server.BaseHTTPRequestHandler):

    def send_test_data(self):
        if self.path == '/ok':
            ok_data = b'OK!\n'
            self.send_response(HTTPStatus.OK)
            self.send_header('Content-type', 'text/plain')
            self.send_header('Content-Length', str(len(ok_data)))
            self.end_headers()
            if self.command != 'HEAD':
                self.wfile.write(ok_data)
        elif self.path == '/404':
            self.send_error(HTTPStatus.NOT_FOUND)
        else:
            # send nothing so curl fails
            pass

    def do_GET(self):
        self.send_test_data()

    def do_HEAD(self):
        self.send_test_data()

    def log_message(self, format, *args):
        pass


class HttpTestCase(unittest.TestCase):

    def setUp(self):
        self.server = http.server.HTTPServer(
                ('localhost', 0), TestRequestHandler)
        self.server_url = 'http://%s:%s' % (self.server.server_name, self.server.server_port)
        self.server_thread = threading.Thread(target=self.server.serve_forever)
        self.server_thread.start()

    def tearDown(self):
        self.server.shutdown()
        self.server_thread.join()
        self.server.server_close()

    def test_quick_ok(self):
        proc = subprocess.Popen([script_path, '%s/ok' % self.server_url],
                                stdout=subprocess.PIPE,
                                stderr=subprocess.PIPE)
        out, err = proc.communicate()
        self.assertEqual(proc.returncode, 0)
        self.assertEqual(out, b'')
        self.assertEqual(err, b'')

    def test_quick_404(self):
        proc = subprocess.Popen([script_path, '%s/404' % self.server_url],
                                stdout=subprocess.PIPE,
                                stderr=subprocess.PIPE)
        out, err = proc.communicate()
        self.assertEqual(proc.returncode, 0)
        self.assertEqual(out, b'')
        self.assertEqual(err, b'')

    def test_timeout(self):
        proc = subprocess.Popen([script_path, '%s/bogus' % self.server_url],
                                bufsize=4096,
                                stdout=subprocess.PIPE,
                                stderr=subprocess.PIPE)
        timeout = time.time() + 2 # kill after 2 seconds
        while time.time() < timeout:
            time.sleep(0.1)
            self.assertIs(proc.poll(), None, 'script terminated early!')
        proc.terminate()
        out, err = proc.communicate()
        self.assertEqual(proc.returncode, -signal.SIGTERM)
        self.assertEqual(out, b'')
        self.assertEqual(err, b'')


if __name__ == '__main__':
    unittest.main()
