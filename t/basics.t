#!/usr/bin/env perl

use strict;
use warnings;

use FindBin ();
use lib "$FindBin::Bin/lib";

use Test::Most tests => 15;

use Dancer::Plugin::Documentation;

sub default_args() {
	return (
		app => 'myapp',
		documentation => 'some docs',
		method => 'get',
		route => '/foo',
	);
}

my $class = 'Dancer::Plugin::Documentation';

is_deeply [$class->get_documentation], [], 'get_documentation returns the empty list when no documentation is registered ';

throws_ok
	{ $class->set_documentation(default_args, app => undef) }
	qr{^Argument \[app\] is required\b},
	'set_documentation fails without argument app';

throws_ok
	{ $class->set_documentation(default_args, documentation => undef) }
	qr{^Argument \[documentation\] is required\b},
	'set_documentation fails without argument documentation';

throws_ok
	{ $class->set_documentation(default_args, method => undef) }
	qr{^Argument \[method\] is required\b},
	'set_documentation fails without argument method';

throws_ok
	{ $class->set_documentation(default_args, route => undef) }
	qr{^Argument \[route\] is required\b},
	'set_documentation fails without argument route';

lives_ok
	{ $class->set_documentation(default_args) }
	'set_documentation succeeds with all arguments';

is_deeply
	[$class->get_documentation(app => 'myapp')],
	[{documentation => 'some docs', method => 'get', route => '/foo'}],
	'get_documentation retrieves registered documentation';

lives_ok
	{ $class->set_documentation(default_args, documentation => 'some new docs') }
	'set_documentation succeeds if documented route already exists';

is_deeply
	[$class->get_documentation(app => 'myapp')],
	[{documentation => 'some new docs', method => 'get', route => '/foo'}],
	'newest documentation is stored even when previous documentation exists';

$class->set_documentation(default_args, app => 'newapp', route => '/another/1');
$class->set_documentation(default_args, app => 'newapp', route => '/another/2');
$class->set_documentation(default_args, app => 'newapp', route => '/another/10');
$class->set_documentation(default_args, app => 'newapp', method => 'post', route => '/another/10');
$class->set_documentation(default_args, app => 'newapp', method => 'put', route => '/another/10');

is_deeply
	[$class->get_documentation(app => 'newapp')],
	[
		{documentation => 'some docs', method => 'get', route => '/another/1'},
		{documentation => 'some docs', method => 'get', route => '/another/10'},
		{documentation => 'some docs', method => 'post', route => '/another/10'},
		{documentation => 'some docs', method => 'put', route => '/another/10'},
		{documentation => 'some docs', method => 'get', route => '/another/2'},
	],
	'documentation is retrieved in lexicographical order by route then method';

is_deeply
	[$class->get_documentation(app => 'newapp', method => 'get')],
	[
		{documentation => 'some docs', method => 'get', route => '/another/1'},
		{documentation => 'some docs', method => 'get', route => '/another/10'},
		{documentation => 'some docs', method => 'get', route => '/another/2'},
	],
	'documentation retrieval can be filtered by method';

is_deeply
	[$class->get_documentation(app => 'newapp', route => '/another/10')],
	[
		{documentation => 'some docs', method => 'get', route => '/another/10'},
		{documentation => 'some docs', method => 'post', route => '/another/10'},
		{documentation => 'some docs', method => 'put', route => '/another/10'},
	],
	'documentation retrieval can be filtered by route';

is_deeply
	[$class->get_documentation(app => 'newapp', method => 'put', route => '/another/10')],
	[{documentation => 'some docs', method => 'put', route => '/another/10'}],
	'documentation retrieval can be filtered by method and route';

$class->set_documentation(default_args, app => 'caseapp', method => 'GET', route => '/bar');
is_deeply
	[$class->get_documentation(app => 'caseapp')],
	[{documentation => 'some docs', method => 'get', route => '/bar'}],
	'methods are stored in lowercase';

is_deeply
	[$class->get_documentation(app => 'caseapp', method => 'GET')],
	[{documentation => 'some docs', method => 'get', route => '/bar'}],
	'document retrieval by method is case insensitive';
