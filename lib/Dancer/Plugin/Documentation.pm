package Dancer::Plugin::Documentation;

use strict;
use warnings;

use Dancer::App;
use Dancer::Plugin;
use Scalar::Util (qw{blessed});
use Set::Functional (qw{setify_by});

my %APP_TO_ROUTE_DOCUMENTATION;

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

sub get_documentation {
	my ($class, %args) = @_;
	my ($app, $method, $route) = @args{qw{app method route}};
	$app ||= Dancer::App->current->name;

	my @docs = @{$APP_TO_ROUTE_DOCUMENTATION{$app} || []};

	@docs = grep { $_->{route} eq $route } @docs if $route;
	@docs = grep { $_->{method} eq lc $method } @docs if $method;

	return @docs;
}

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

register_plugin;
1;
