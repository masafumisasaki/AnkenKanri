package AnkenKanri::WEB::Api::Root;
use Mojo::Base 'Mojolicious::Controller';
use AnkenKanri::Model::Login;

sub certify {

	my $self = shift;

	my $login = AnkenKanri::Model::Login->new(
		login_id => $self->param('login_id') 	,
		password => $self->param('password') 	,
	);
	
	$self->app->log->debug("auth auth!!"); 

	if ( $login->authenticate ) {
		$self->render(json => {result => '1'});
	}else{
		$self->render(json => {result => '0'});
	}

	return 1;
	
}

1;
