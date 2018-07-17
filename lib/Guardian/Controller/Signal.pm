package Guardian::Controller::Signal;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::IOLoop;

sub catalog {
  my $self = shift;
  $self->render( json => $self->services );
}

sub signal {
  my $self = shift;

  my $err = validate_service_payload( $self->req->json );

  unless ( $err eq "" ) {
    my $msg = 'invalid payload: bad JSON or missing fields';
    $self->app->log->error($msg);
    $self->render( text => "$msg\n\n$err\n\n" . $self->req->body );
    return;
  }

  my $sn = $self->req->json->{'service_name'};

  if ( exists( $self->app->services->{$sn} )
    && exists( $self->app->services->{$sn}->{timer_id} ) )
  {
    Mojo::IOLoop->remove( $self->app->services->{$sn}->{timer_id} );
    $self->app->log->info(
      sprintf( "'%s' has averted disaster: removing timer %s",
        $self->app->services->{$sn}->{timer_id} )
    );
  }

  $self->app->log->info(
    sprintf(
      "new alert for '%s' scheduled in %d seconds",
      $sn, $self->req->json->{next_signal}
    )
  );

  $self->app->services->{$sn} = {
    next_signal => $self->req->json->{next_signal},
    notifiers   => $self->req->json->{notifiers},
    timer_id    => my $timer_id = Mojo::IOLoop->timer(
      $self->req->json->{next_signal} => sub {
        $self->app->log->info( sprintf( "notify X about '%s'", $sn ) );
        delete $self->app->services->{$sn}->{timer_id};
      }
    ),
  };

  $self->render( text => "OK" );
}

sub validate_service_payload {
  my $json      = shift;
  my $error_msg = "";
  for my $key (qw(notifiers service_name next_signal)) {
    unless ( exists( $json->{$key} ) ) {
      $error_msg .= "Could not retrieve $key\n";
    }
  }
  return $error_msg;
}

1;
