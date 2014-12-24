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

1;

