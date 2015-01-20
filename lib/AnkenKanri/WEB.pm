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
  	my $routes = $self->routes;
	my $loged_in = $routes->bridge->to('member-root#login');

	# SSL routes
	#my $ssl_routes = $loged_in->bridge->to(
	#	cb => sub{
	#		my $self = shift;

	#		my $req = $self->req;
	#		$self->app->log->debug("ssl_route callback"); 
	#		$self->app->log->debug("is_secure:". $req->is_secure ); 
	#		return 1 if $req->is_secure;

	#		$self->redirect_to($req->url->to_abs->scheme('https')->port(3001));
	#		return;
	#	}
	#);

	my $ssl_routes = $loged_in->under(
		sub{
			my $self = shift;

			my $req = $self->req;
			$self->app->log->debug("ssl_route callback"); 
			$self->app->log->debug("is_secure:". $req->is_secure ); 
			return 1 if $req->is_secure;

			$self->redirect_to($req->url->to_abs->scheme('https')->port(3001));
			return;
		}
	);

	# Not SSL routes
	# my $not_ssl_routes = $loged_in->bridge->to(
	#	cb => sub{
	#		my $self = shift;

	#		my $url = $self->req->url;
	#		$self->app->log->debug("not_ssl_route callback"); 
	#		return 1 if $url->base->scheme eq 'http';

	#		$self->redirect_to($url->to_abs->scheme('http')->port(3000));
	#		return;
	#	}
	#);

	my $not_ssl_routes = $loged_in->under(
		sub{
			my $self = shift;

			my $url = $self->req->url;
			$self->app->log->debug("not_ssl_route callback"); 
			return 1 if $url->base->scheme eq 'http';

			$self->redirect_to($url->to_abs->scheme('http')->port(3000));
			return;
		}
	);
	$ssl_routes->route('/login')->to('member-root#login');
#	$ssl_routes->route('/api/auth')->to('api-root#certify');
	
	$not_ssl_routes->route('/app')->to('member-root#index');
  	$not_ssl_routes->route('/kintone')->to('kintone-root#search');
	$not_ssl_routes->route('/logout')->to('member-root#logout');
	
	$routes->route('/api/auth')->to('api-root#certify');
}

1;
