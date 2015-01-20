package AnkenKanri::WEB::Kintone::Root;
use Mojo::Base 'Mojolicious::Controller';
use Kintone;

sub search {
	my $self = shift;
	my $kintone = Kintone->new(
		kintone_url => 'https://mkt.cybozu.com',
		proxy_server => $self->app->config->{kintone}->{proxy_server},
		application_id => $self->app->config->{kintone}->{application_id},
	);

	#$kintone->query('状況 in (\"ウォッチ\") and お客様企業名 like \"トーエル\"' );
	$kintone->query('コマース担当 in (\"' . $self->param("member_name") . '\") 
					and 状況 not in (\"クローズ(Win)\",\"クローズ(Loss)\",\"クローズ(辞退)\") 
					order by 受注年月,受注年月,更新日時 desc');
	#$kintone->query('コマース担当 in (\"' . $self->param("member_name") . '\") order by 更新日時 desc');
	$kintone->fields('"お客様企業名","案件名","受注年月","確度","状況","活動履歴","更新日時"' );

	my $result_json = $kintone->find();	

	$self->render(json => $result_json);
}

1;
