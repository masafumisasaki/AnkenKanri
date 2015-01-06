package AnkenKanri::WEB::Member::Root;
use Mojo::Base 'Mojolicious::Controller';
use Kintone;

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

        my $loginid  = $self->param('login_id') || '';
        my $password = $self->param('password') || '';
		$self->app->log->debug("loginid=". $loginid); 
		$self->app->log->debug("password=". $password); 

        if ( $loginid eq "sol-member" and $password eq "soei3" ) {
			$self->app->log->debug("success!!"); 
			$self->session(loggedin => 1);
            return 1;
        }

	$self->app->log->debug("failed!!"); 
	$self->render();
    return undef;
	
}

1;
