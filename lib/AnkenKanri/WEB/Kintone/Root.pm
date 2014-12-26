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

	#$kintone->query('状況 in (\"ウォッチ\") and お客様企業名 like \"トーエル\"' );
	$kintone->query('コマース担当 in (\"' . $self->param("member_name") . '\")');
	$kintone->fields('"お客様企業名","案件名","受注年月","状況","活動履歴"' );

	my $result_json = $kintone->get_json();	

	#$self->render(json => {data1=>$self->param("param1"),data2=>$self->param("param2")});
	$self->render(json => $result_json);
}

1;
