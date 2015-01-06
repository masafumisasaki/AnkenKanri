package AnkenKanri::WEB;
use Mojo::Base 'Mojolicious';
use Path::Class;

# This method will run once at server start
sub startup {

	my $self = shift;

	my $home = new Path::Class::File(__FILE__);
	my $root = $home->dir->resolve->absolute->parent->parent();

	for my $e ( 'kintone' ) {
		my $f = $root->stringify.'/etc/'.$e.'.conf';
		$self->plugin( 'Config', { 'file' => $f } );
		#$conf = $self->plugin( 'Config', { 'file' => $f } );
	}

	# Secret
	$self->secrets(['secret']);

	# Session
	$self->session(expiration => 3600);

    # Router
  	my $r = $self->routes;

	#
	my $loged_in = $r->bridge->to('member-root#login');
	
  	$loged_in->route('/')->to('member-root#index');
  	$loged_in->route('/kintone')->to('kintone-root#search');
  	$loged_in->route('/logout')->to('member-root#logout');
	
}

1;
