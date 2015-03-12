package AnkenKanri::WEB::Kintone::Root;
use Mojo::Base 'Mojolicious::Controller';
use Kintone;
use Template;
use Template::Provider::Encoding;
use JSON qw/decode_json/;
use Time::Piece;
use Time::Seconds;
use Data::Dumper;
use Path::Class;
use Encode;
use utf8;

sub search {

	my $self = shift;
	my $kintone = Kintone->new(
		kintone_url => 'https://mkt.cybozu.com',
		proxy_server => $self->app->config->{kintone}->{proxy_server},
		application_id => $self->app->config->{kintone}->{application_id},
	);

	$kintone->query('コマース担当 in (\"' . $self->param("member_name") . '\") 
					and 状況 not in (\"クローズ(Win)\",\"クローズ(Loss)\",\"クローズ(辞退)\",\"HQハンドリング\") 
					order by 受注年月,受注年月,更新日時 desc');

	$kintone->fields('"お客様企業名","案件名","受注年月","確度","状況","活動履歴","更新日時","案件分類"' );

	my $result_json = $kintone->find();	

	$self->render(json => $result_json);
}

sub weeklyreport {

	my $self = shift;

	#
	# 案件管理アプリ
	#
	my $kintone = Kintone->new(
		kintone_url => 'https://mkt.cybozu.com',
		proxy_server => $self->app->config->{kintone}->{proxy_server},
		application_id => $self->app->config->{kintone}->{application_id},
		token => "l4Fxfy8sFLa9Sd4eS7jSE86UJckRQN2B6TvL3b7L",
	);

	$kintone->query('コマース担当 in (\"' . $self->param("member_name") . '\") 
					and 状況 not in (\"クローズ(Win)\",\"クローズ(Loss)\",\"クローズ(辞退)\",\"HQハンドリング\",\"ウォッチ\") 
					order by 受注年月,受注年月,更新日時 desc');

	$kintone->fields('"案件分類","お客様企業名","案件名","受注年月","確度","状況","活動履歴","更新日時","shokihi","getsugaku","案件種別","JBCC営業"' );

	my $result_json = $kintone->find();	

	#
	# リード管理アプリ
	#
	my $lead = Kintone->new(
		kintone_url => 'https://mkt.cybozu.com',
		proxy_server => $self->app->config->{kintone}->{proxy_server},
		application_id => "342",
		token => "s9a9JMxWc2Pau4GoAVC1RMW7iaHDU8lSclcHmuxE",
	);

	$lead->query('コマース担当 in (\"' . $self->param("member_name") . '\") 
			        and リード状況 in (\"' . "確認中" . '\") 
					order by リード発掘日');

	$lead->fields('"案件種別","お客様企業名","ソース＿施策","次Action","活動履歴","リード状況","リード発掘日"' );

	my $lead_result_json = $lead->find();

	#
	# テンプレート受け渡しデータ生成
	#

	my $t = get_report_day();

	my $tt = Template->new(
			{
				ABSOLUTE => 1,
				UNICODE  => 1,
				ENCODING => 'utf-8',}
			);

	my $result = "";

	my $home = new Path::Class::File(__FILE__);
	my $root = $home->dir->resolve->absolute();

	$result_json->{name} = $self->param("member_name");
	$result_json->{activity_of_the_week} = 
	{
		current => {
			monday    => { date => ($t + ONE_DAY * 0)->mon() . "/" . ($t + ONE_DAY * 0)->mday() ,
				activity => '' },
			tuesday   => { date => ($t + ONE_DAY * 1)->mon() . "/" . ($t + ONE_DAY * 1)->mday() ,
				activity => '', },
			wednesday => { date => ($t + ONE_DAY * 2)->mon() . "/" . ($t + ONE_DAY * 2)->mday() ,
				activity => '', },
			thursday  => { date => ($t + ONE_DAY * 3)->mon() . "/" . ($t + ONE_DAY * 3)->mday() ,
				activity => '', },
			friday    => { date => ($t + ONE_DAY * 4)->mon() . "/" . ($t + ONE_DAY * 4)->mday() ,
				activity => '', },
		},
		next => {
			monday    => { date => ($t + ONE_DAY * 7)->mon() . "/" . ($t + ONE_DAY * 7)->mday() ,
				activity => '' },
			tuesday   => { date => ($t + ONE_DAY * 8)->mon() . "/" . ($t + ONE_DAY * 8)->mday() ,
				activity => '', },
			wednesday => { date => ($t + ONE_DAY * 9)->mon() . "/" . ($t + ONE_DAY * 9)->mday() ,
				activity => '', },
			thursday  => { date => ($t + ONE_DAY * 10)->mon() . "/" . ($t + ONE_DAY * 10)->mday() ,
				activity => '', },
			friday    => { date => ($t + ONE_DAY * 11)->mon() . "/" . ($t + ONE_DAY * 11)->mday() ,
				activity => '', },
		},
	};
	$result_json->{lead} = $lead_result_json;

	#my $json = JSON->new;
	#$json = $json->pretty(1);
	#$self->app->log->debug($json->pretty->encode($result_json));
	
	$tt->process("$root/weekly_report.tt", $result_json , \$result) || die $tt->error() ;

	$result =~ s/\n/<br>/g;
	$result =~ s/\s/&nbsp;&nbsp;/g;
	$self->render(text => $result);

}

sub get_report_day {

	# get current day
	my $t = localtime;

	# go 1week ago
	$t = $t - ( ONE_DAY * 7 );

	my $month = $t->mon;
	my $mday  = $t->mday;

	while (1) {
		# if wday equals Monday break loop
		last if $t->wdayname() eq 'Mon';
		# add one day
		$t = $t + ( ONE_DAY * 1 );
	}

	return $t;
}

1;
