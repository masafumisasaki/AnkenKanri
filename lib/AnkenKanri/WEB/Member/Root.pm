package AnkenKanri::WEB::Member::Root;
use Mojo::Base 'Mojolicious::Controller';
use Kintone;
use AnkenKanri::Model::Login;
use Mojo::URL;
use Data::Dumper;

sub index {
	my $self = shift;

	my $kintone = Kintone->new(
		kintone_url => 'https://mkt.cybozu.com',
		proxy_server => $self->app->config->{kintone}->{proxy_server},
		application_id => $self->app->config->{kintone}->{application_id},
	);	

	$self->render();
}

sub login {

        my $self = shift;

		my $loggedin = $self->session('loggedin') || 0; 

		return 1 if ( $loggedin == 1 );

		my $login = AnkenKanri::Model::Login->new(
			login_id => $self->param('login_id') 	,
			password => $self->param('password') 	,
		);

        if ( $login->authenticate ) {
			$self->session(loggedin => 1);
            return 1;
        }

	$self->app->log->debug("failed!!"); 
	$self->render();
    return undef;
	
}

sub logout {

	my $self = shift;

	$self->session(expires => 1);

	#$self->app->log->debug($self->tx->req->url->base->host);
	my $host = $self->tx->req->url->base->host;
	$self->redirect_to(Mojo::URL->new("https://$host:3001/login"));
	
	#$self->redirect_to("/login");
}

1;
