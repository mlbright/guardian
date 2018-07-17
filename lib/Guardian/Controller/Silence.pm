package Guardian::Controller::Silence;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::IOLoop;

sub silence {
  my $self    = shift;
  my $payload = $self->req->json;

  unless ( exists( $payload->{service_name} )
    && exists( $payload->{notifier} )
    && exists( $payload->{'next_signal'} ) )
  {
    $self->app->log->error('bad JSON');
    $self->render( text => "bad JSON...\n\n" . $self->req->body );
    return;
  }

  my $timeout      = $payload->{'next_signal'};
  my $service_name = $payload->{'service_name'};

  if ( exists( $self->app->services->{$service_name} ) ) {
    Mojo::IOLoop->remove( $self->app->services->{$service_name}->{timer_id} );
    $self->app->log->info("$service_name has averted disaster");
  }

  my $timer_id = Mojo::IOLoop->timer(
    $timeout => sub {
      $self->app->log->info( 'notify X about ' . $service_name );
    }
  );

  $self->app->services->{$service_name} = {
    next_signal => $timeout,
    notifier    => $payload->{notifier},
    timer_id    => $timer_id,
  };

  $self->render( text => "OK" );
}

1;
