package TestApp;
use Dancer (':syntax');
use Dancer::Plugin::Documentation;

documentation 'overview',
get '/' => sub {
	return [Dancer::Plugin::Documentation->get_documentation];
};

prefix '/v1';

documentation "create foo",
post '/foo' => sub {};

documentation "fetch foo",
get '/foo/:id' => sub {};

documentation "find foo",
get '/foo' => sub {};

true;
