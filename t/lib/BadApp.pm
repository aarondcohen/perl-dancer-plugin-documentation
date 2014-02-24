package TestApp;
use Dancer (':syntax');
use Dancer::Plugin::Documentation;

documentation 'overview',
get '/' => sub {
	return [Dancer::Plugin::Documentation->get_documentation];
};

documentation "invalid",
any ['get', 'post'] => '/foo' => sub {};

true;
