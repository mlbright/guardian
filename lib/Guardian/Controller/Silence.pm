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
  my $notifier     = $payload->{'notifier'};

  my $service;
  if ( exists( $self->app->services->{$service_name} ) ) {
    $self->app->log->info("$service_name is registered...");
    $service = $self->app->services->{$service_name};
    my $timer_id = $service->{timer_id};
    Mojo::IOLoop->remove($timer_id);
    $self->app->log->info("$service_name has averted disaster");
  }

  my $timer_id = Mojo::IOLoop->timer(
    $timeout => sub {
      $self->app->log->info( 'notify X about ' . $service_name );
    }
  );

  $service = {
    next_signal  => $timeout,
    service_name => $service_name,
    notifier     => $notifier,
    timer_id     => $timer_id,
  };
  $self->app->services->{$service_name} = $service;

  $self->render( text => "OK" );
}

1;
