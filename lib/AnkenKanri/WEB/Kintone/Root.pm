package AnkenKanri::WEB::Kintone::Root;
use Mojo::Base 'Mojolicious::Controller';
use Kintone;
use Template;
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
					and 状況 not in (\"クローズ(Win)\",\"クローズ(Loss)\",\"クローズ(辞退)\") 
					order by 受注年月,受注年月,更新日時 desc');

	$kintone->fields('"お客様企業名","案件名","受注年月","確度","状況","活動履歴","更新日時"' );

	my $result_json = $kintone->find();	

	$self->render(json => $result_json);
}

sub weeklyreport {

	my $self = shift;
	my $kintone = Kintone->new(
		kintone_url => 'https://mkt.cybozu.com',
		proxy_server => $self->app->config->{kintone}->{proxy_server},
		application_id => $self->app->config->{kintone}->{application_id},
	);

	$kintone->query('コマース担当 in (\"' . $self->param("member_name") . '\") 
					and 状況 not in (\"クローズ(Win)\",\"クローズ(Loss)\",\"クローズ(辞退)\") 
					order by 受注年月,受注年月,更新日時 desc');

	$kintone->fields('"案件分類","お客様企業名","案件名","受注年月","確度","状況","活動履歴","更新日時","shokihi","getsugaku"' );

	my $result_json = $kintone->find();	

	#my $item = $result_json;

	my $t = get_report_day();

	my $item = {
		activity_of_the_week => {
			current => {
				monday    => { date => ($t + ONE_DAY * 0)->mon() . "/" . ($t + ONE_DAY * 0)->mday() ,
					activity => 'CS活動' },
				tuesday   => { date => ($t + ONE_DAY * 1)->mon() . "/" . ($t + ONE_DAY * 1)->mday() ,
					activity => 'コマース営業部MTG', },
				wednesday => { date => ($t + ONE_DAY * 2)->mon() . "/" . ($t + ONE_DAY * 2)->mday() ,
					activity => 'コロプラスト call , コンフィエンス call', },
				thursday  => { date => ($t + ONE_DAY * 3)->mon() . "/" . ($t + ONE_DAY * 3)->mday() ,
					activity => '案件整理,', },
				friday    => { date => ($t + ONE_DAY * 4)->mon() . "/" . ($t + ONE_DAY * 4)->mday() ,
					activity => 'コマース部会 BPS', },
			},
			next => {
				monday    => { date => ($t + ONE_DAY * 7)->mon() . "/" . ($t + ONE_DAY * 7)->mday() ,
					activity => 'CS活動' },
				tuesday   => { date => ($t + ONE_DAY * 8)->mon() . "/" . ($t + ONE_DAY * 8)->mday() ,
					activity => 'コマース営業部MTG', },
				wednesday => { date => ($t + ONE_DAY * 9)->mon() . "/" . ($t + ONE_DAY * 9)->mday() ,
					activity => 'コロプラスト call , コンフィエンス call', },
				thursday  => { date => ($t + ONE_DAY * 10)->mon() . "/" . ($t + ONE_DAY * 10)->mday() ,
					activity => '案件整理,', },
				friday    => { date => ($t + ONE_DAY * 11)->mon() . "/" . ($t + ONE_DAY * 11)->mday() ,
					activity => 'コマース部会 BPS', },
			},
		},

		topic_of_the_week => {

			sales => [
				{ "コマース"       => '

					住商グローバルロジスティクス(HQ)：
					Makeshop:　海外駐在員向け日本食受注サイト
					ユーザ部門にてデモサイトを使用した業務運用について確認を実施中。
					運用課題について連絡を受けており対応中。
					また、営業河原さん経由で今後のスケジュールを再度確認中。

					キャプラン(直)：決済サイト
					Makeshop
					情報システムとしては来年度予算申請は済み。
					予算承認及び、今年度実行（余り予算)するかは2/末に判明するとのこと。
					確度 D -> C　へ変更

					コンフィアンス(HQ)：会員向け注文サイト
					Makeshop
					01/21にヒアリングを実施、標準機能+データ連携オプション（カスタマイズ）で実現が可能。
					2015/06 までに対応が必要(OS保守切れ)なお客様のため概算金額を提示し、見極めを行う。

					コロプラスト(HQ)：得意先向けWeb受注サイト
					Makeshop
					01/21にヒアリングを実施、EDIカート + データ連携にて概算費用を提出し、
					2/10 に再訪問し、見極めを行う予定
					' }, 

				{ "マーケティング" => "
					アルク： IBM Campaign
					IBM Camapaignを含む、マーケティング施策実現のための
					実装課題（自動化、メール連携）があり、ヒアリングを実施。
					SIにて対応可否について検討中。

					"},
				{ "アナリティクス" => "動きなし" },

			],

			other => [
				{ 
				},
			],
		},
	};

	my $tt = Template->new(
			{
				ABSOLUTE=>1,
				UNICODE  => 1,
		    	ENCODING => 'utf-8',}
			);

	my $result = "";

	my $home = new Path::Class::File(__FILE__);
	my $root = $home->dir->resolve->absolute();

	$tt->process("$root/weekly_report.tt", $item , \$result) || die $tt->error() ;

	$self->app->log->debug("result:". $result);

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
