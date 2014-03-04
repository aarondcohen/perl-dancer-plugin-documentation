package Dancer::Plugin::Documentation;

=head1 NAME

Dancer::Plugin::Documentation - register documentation for a route

=cut

use strict;
use warnings;

use Dancer::App;
use Dancer::Plugin;
use Scalar::Util (qw{blessed});
use Set::Functional (qw{setify_by});

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Dancer::Plugin::Documentation provides the keyword I<documentation> to
associate documentation with a fully pathed route.  This is especially
useful when the route path is externally modified by the prefix command.
See the example for recommended usage.

Example usage:

	package Foo;

	use Dancer;
	use Dancer::Plugin::Documentation;

	get '/resources' => sub {
		status 200;
		return join "\n", Dancer::Plugin::Documentation->get_documentation;
	};

	prefix '/v1';

	documentation 'A route to retrieve foo',
	get '/foo' => sub { status 200; return 'foo' };

	package main;

	dance;

=cut

my %APP_TO_ROUTE_DOCUMENTATION;

=head1 METHODS

=cut

=head2 documentation

Given a documentation argument and a list of routes, associate the
documentation with all of the routes.  The documentation argument
can be anything from a string to a complex object.

=cut

register documentation => sub {
	my ($documentation, @routes) = @_;

	my $app = Dancer::App->current->name;

	die "Documentation missing, Dancer::Route found instead"
		if blessed $documentation && $documentation->isa('Dancer::Route');

	die "Invalid argument where Dancer::Route expected"
		if grep { ! blessed $_ || ! $_->isa('Dancer::Route') } @routes;

	Dancer::Plugin::Documentation->set_documentation(
		app => $app,
		route => $_->pattern,
		method => $_->method,
		documentation => $documentation,
	) for @routes;

	return @routes;
};

=head2 get_documentation

Retrieve the registered documentation for an app in lexicographical order by
route, then method.  Defaults to the current app unless otherwise specified.
Optionally, a route and/or method may be supplied to only show the
corresponding documentation.

=cut

sub get_documentation {
	my ($class, %args) = @_;
	my ($app, $method, $route) = @args{qw{app method route}};
	$app ||= Dancer::App->current->name;

	my @docs = @{$APP_TO_ROUTE_DOCUMENTATION{$app} || []};

	@docs = grep { $_->{route} eq $route } @docs if $route;
	@docs = grep { $_->{method} eq lc $method } @docs if $method;

	return @docs;
}

=head2 set_documentation

Register documentation for the method and route of a particular app.
Documentation can be any defined value.

=cut

sub set_documentation {
	my ($class, %args) = @_;

	defined $args{$_} || die "Argument [$_] is required"
		for qw{ app documentation method route };

	my $app = $args{app};
	$args{method} = lc $args{method};

	$APP_TO_ROUTE_DOCUMENTATION{$app} = [
		sort { $a->{route} cmp $b->{route} || $a->{method} cmp $b->{method} }
		setify_by { "$_->{method}:$_->{route}" }
		(
			@{$APP_TO_ROUTE_DOCUMENTATION{$app} || []},
			+{ map { ($_ => $args{$_}) } qw{ documentation method route } },
		)
	];

	return;
}

=head1 CAVEATS

=over 4

=item any

The documentation keyword does not work with the I<any> keyword as it does not
return the list of registered routes, but rather the number of routes
registered.  Fixing this beahvior will require a patch to Dancer.

=item get

The I<get> keyword generates both get and head routes.  Documentation will be
attached to both.

=back

=head1 ACKNOWLEDGEMENTS

This module is brought to you by L<Shutterstock|http://www.shutterstock.com/>
(L<@ShutterTech|https://twitter.com/ShutterTech>).  Additional open source
projects from Shutterstock can be found at
L<code.shutterstock.com|http://code.shutterstock.com/>.

=head1 AUTHOR

Aaron Cohen, C<< <aarondcohen at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-Dancer-Plugin-Documentation at rt.cpan.org>, or through
the web interface at L<https://github.com/aarondcohen/Dancer-Plugin-Documentation/issues>.  I will
be notified, and then you'll automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Dancer::Plugin::Documentation

You can also look for information at:

=over 4

=item * Official GitHub Repo

L<https://github.com/aarondcohen/Dancer-Plugin-Documentation>

=item * GitHub's Issue Tracker (report bugs here)

L<https://github.com/aarondcohen/Dancer-Plugin-Documentation/issues>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Dancer-Plugin-Documentation>

=item * Official CPAN Page

L<http://search.cpan.org/dist/Dancer-Plugin-Documentation/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2014 Aaron Cohen.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

register_plugin;
1; # End of Dancer::Plugin::Documentation
