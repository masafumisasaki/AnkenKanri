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

    # Router
  	my $r = $self->routes;

  	$r->route('/')->to('member-root#index');
  	$r->route('/kintone')->to('kintone-root#search');
	
}

1;
