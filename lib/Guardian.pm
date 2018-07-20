package Guardian;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
  my $self = shift;

  # Load configuration from hash returned by "guardian.conf"
  my $config = $self->plugin('Config');

  # Global cache of services
  $self->helper( services => sub { state $services = {} } );
  $self->helper( slack => sub { return $config->{slack_vault_url} } );

  # Router
  my $r = $self->routes;

  # Routes to controller
  $r->get('/guardian')->to('signal#catalog');
  $r->post('/guardian/api/v1/signal')->to('signal#signal');
}

1;
