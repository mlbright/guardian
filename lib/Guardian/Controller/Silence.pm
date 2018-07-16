package Guardian::Controller::Silence;
use Mojo::Base 'Mojolicious::Controller';

sub silence {
  my $self = shift;
  my $payload;
  eval {
    $payload = $self->req->json;
  }; 

  if ($@) {
    $self->app->log->debug('malformed JSON');
  } else {
    if (exists($payload->{next_signal})) {
    my $timeout = $payload->{next_signal};
    my $id = Mojo::IOLoop->timer( $timeout => sub {
      $self->app->log->debug('did not receive signal...');
    });

    $self->render( text => "OK" ); 
    } else {
    $self->app->log->debug('missing next signal');
    $self->render( text => $self->req->body ); 
    }
  }
}

1;
