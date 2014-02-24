#!/usr/bin/env perl

use strict;
use warnings;

use FindBin ();
use lib "$FindBin::Bin/lib";

use Test::Most tests => 5;

use TestApp;
use Dancer::Test;

route_exists $_, "$_->[0] $_->[1] is registered properly" for (
	[GET => '/'],
	[GET => '/v1/foo'],
	[POST => '/v1/foo'],
	[GET => '/v1/foo/:id'],
);

response_content_is_deeply [GET => '/'],
	[
		{ method => 'get',  route => '/',           documentation => 'overview' },
		{ method => 'head', route => '/',           documentation => 'overview' },
		{ method => 'get',  route => '/v1/foo',     documentation => 'find foo' },
		{ method => 'head', route => '/v1/foo',     documentation => 'find foo' },
		{ method => 'post', route => '/v1/foo',     documentation => 'create foo' },
		{ method => 'get',  route => '/v1/foo/:id', documentation => 'fetch foo' },
		{ method => 'head', route => '/v1/foo/:id', documentation => 'fetch foo' },
	],
	'All the documentation is properly retrieved';
