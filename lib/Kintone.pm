package Kintone;

use strict;
use warnings;
use utf8;
use Rest::Client;
use URI::Escape;
use JSON;
use Encode;
use Moo;

has kintone_url => (
	is	    => 'ro',
	required => 1,
);
has proxy_server => (
	is	    => 'ro',
);

has application_id => (
	is	    => 'ro',
	required => 1,
);
has query => (
	is	    => 'rw',
);
has fields => (
	is	    => 'rw',
);

sub get_json {

	my $self = shift;

	my $host = q{https://mkt.cybozu.com};
	my $client = REST::Client->new(host => $host);
	
	$client->getUseragent()->proxy(['https'], $self->proxy_server);


	my $req_json = '{' . 
				   '"app":' . $self->application_id . ',' . 
				   '"query":"' . $self->query . '",' . 
				   '"fields":[' . $self->fields . '],' . 
				   '}';

#	my $req_json = '{' . 
#				   '"app":' . "170" . ',' . 
#				   '"query":"' . '状況 in (\"ウォッチ\") and お客様企業名 like \"トーエル\"' . '",' . 
#				   '"fields":[' . '"お客様企業名","案件名","受注年月","状況","活動履歴"' . '],' . 
#				   '}';

#	$client->request(
#		 	'GET',
#            '/k/v1/records.json',
#			encode_utf8(q/{
#			"app":170,
#			"query":"状況 in (\"ウォッチ\") and お客様企業名 like \"トーエル\"",
#	 	   	"fields":["お客様企業名","案件名","受注年月","状況","活動履歴"]
#			}/),
#            {
#                'X-Cybozu-API-Token'     => "qYArQFYeMRUfLaBkmBx23jDJhIh5fDJo8tSRuZwW",
#                'X-Cybozu-Authorization' => 'c29sLW1lbWJlcjpzb2Vp',
#                'Accept-Language' => 'ja',
#				'Content-Type' => 'application/json',
#            }
#        );
	$client->request(
		 	'GET',
            '/k/v1/records.json',
			encode_utf8($req_json),
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
	#return $json->pretty->encode($json->decode($json_string));
	return $json->decode($json_string);
	#return $json_string;

}

1;

