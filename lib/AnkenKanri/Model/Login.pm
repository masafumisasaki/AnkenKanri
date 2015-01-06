package AnkenKanri::Model::Login;

use strict;
use warnings;
use Moo;

has user_name => (
	is	    => 'ro',
	required => 1,
);
has password => (
	is	    => 'ro',
	required => 1,
);


sub authenticate {

	return 1;

}


1;
