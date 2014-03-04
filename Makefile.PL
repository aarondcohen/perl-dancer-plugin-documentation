use strict;
use warnings;

use ExtUtils::MakeMaker;
use ExtUtils::MakeMaker::CPANfile;

WriteMakefile(
	NAME          => 'Dancer::Plugin::Documentation',
	AUTHOR        => q{Aaron Cohen <acohen@shutterstock.com>},
	VERSION_FROM  => 'lib/Dancer/Plugin/Documentation.pm',
	ABSTRACT_FROM => 'lib/Dancer/Plugin/Documentation.pm',
);
