package AnkenKanri::WEB::Member::Root;
use Mojo::Base 'Mojolicious::Controller';
use Kintone;

sub index {
	my $self = shift;

	my $kintone = Kintone->new(
		kintone_url => 'https://mkt.cybozu.com',
		proxy_server => $self->app->config->{kintone}->{proxy_server},
		application_id => '170',
	);	

	$self->render(content => 'Welcome to the Mojolicious real-time web framework!',
	prop => $kintone->kintone_url,	
	);
}

1;
