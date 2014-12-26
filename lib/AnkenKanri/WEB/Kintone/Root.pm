package AnkenKanri::WEB::Kintone::Root;
use Mojo::Base 'Mojolicious::Controller';
use Kintone;

sub search {
	my $self = shift;

	my $kintone = Kintone->new(
		kintone_url => 'https://mkt.cybozu.com',
		proxy_server => $self->app->config->{kintone}->{proxy_server},
		application_id => '170',
	);

	my $result_json = $kintone->get_json();	

	#$self->render(json => {data1=>$self->param("param1"),data2=>$self->param("param2")});
	$self->render(json => $result_json);
}

1;
