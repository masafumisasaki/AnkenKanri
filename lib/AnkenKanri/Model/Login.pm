package AnkenKanri::Model::Login;

use strict;
use warnings;
use Moo;

has login_id => (
	is	    => 'ro',
	required => 1,
);
has password => (
	is	    => 'ro',
	required => 1,
);

sub authenticate {

	my $self = shift;

	my $login_id  = $self->login_id || '';
   	my $password = $self->password || '';
	
	if ( $login_id eq "sol-member" and $password eq "soei3" ) {
        return 1;
    }else{
        return 0;
	}

}


1;
