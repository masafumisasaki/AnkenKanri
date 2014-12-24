package AnkenKanri::WEB::Member::Root;
use Mojo::Base 'Mojolicious::Controller';
use Kintone;

sub index {
	my $self = shift;

	my $kintone = Kintone->new(
		kintone_url => 'https://mkt.cybozu.com',
		proxy_server => 'http://tk1py01a.jbcc.co.jp:8080',
		application_id => '170',
	);	

	$self->render(content => 'Welcome to the Mojolicious real-time web framework!',
	prop => $kintone->kintone_url,	
	);
}

sub get_json_from_kintone {

	my $query_param = shift;
	my $fields = shift;

	my $host = q{https://mkt.cybozu.com};
	my $client = REST::Client->new(host => $host);
	 $client->getUseragent()->proxy(['https'], 'http://tk1py01a.jbcc.co.jp:8080');
	 $client->request(
		 	'GET',
            '/k/v1/records.json',
			encode_utf8(q/{
			"app":170,
			"query":"状況 in (\"ウォッチ\") and お客様企業名 like \"トーエル\"",
	 	   	"fields":["お客様企業名","案件名","受注年月","状況","活動履歴"]
			}/),
            {
                'X-Cybozu-API-Token'     => "qYArQFYeMRUfLaBkmBx23jDJhIh5fDJo8tSRuZwW",
                'X-Cybozu-Authorization' => 'c29sLW1lbWJlcjpzb2Vp',
                'Accept-Language' => 'ja',
				'Content-Type' => 'application/json',
            }
        );

	my $json = JSON->new;
	$json = $json->pretty(1);
	my $json_string = decode_utf8( $client->responseContent());
	return $json->pretty->encode($json->decode($json_string));
	#return $json_string;

#	return `curl -X GET -H "X-Cybozu-API-Token: qYArQFYeMRUfLaBkmBx23jDJhIh5fDJo8tSRuZwW" -H "X-Cybozu-Authorization: c29sLW1lbWJlcjpzb2Vp" "https://mkt.cybozu.com/k/v1/records.json?app=170&query=$query_param" 2>/dev/null`;


}

1;
