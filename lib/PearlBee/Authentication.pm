package PearlBee::Authentication;

use Dancer2;
use Dancer2::Plugin::DBIC;
use PearlBee::Password 'generate_hash';
#use PearlBee 'PearlBee';
#use PearlBee::Model::Schema::Result::User 'validate';

=head

index

=cut

get '/admin' => sub {
  my $user = session('user');

  redirect('/dashboard') if ( $user );
  template 'login', {}, { layout => 'admin' };
};

=head

login method

=cut

post '/login' => sub {
  my $password = params->{password};
  my $username = params->{username};
  #warn "The pass is :|$password|\n";
  #warn "The user is :|$username|\n";
  my $user = resultset("User")->search({
      username => $username,
      -or => [
      	status => 'activated',
      	status => 'deactivated'
      ]
    })->first;
  #warn "This are dbi data";
  #my $name_value = $user->username;
  #warn  "The name is $name_value\n";
  #my $passowrd_value = $user->password;
  #warn "The passowrd is $passowrd_value\n";
  #my $salt_value = $user->salt;
  #warn "The salt is $salt_value\n";
  
  
  my $password_hash = generate_hash($password, $user->salt ) if $user;
  
  
  
  if ( $user && $user->password eq $password_hash->{hash} ) {
    
    my $user_obj->{is_admin} = $user->is_admin;
    $user_obj->{role}        = $user->role;
    $user_obj->{id}          = $user->id;
    $user_obj->{username}    = $user->username;

    session user    => $user_obj;
    session user_id => $user->id;
	
    redirect('/dashboard');
  }
  else {
    template 'login', { warning => "Login failed for the provided username/password pair." }, { layout => 'admin' };
  }
};

=head

logout method

=cut

get '/logout' => sub {
  
  context->destroy_session;
  
  session blog_name => resultset('Setting')->first->blog_name unless ( session('blog_name') );
  session app_url   => config->{app_url};

  template 'login', { success => "You were successfully logged out." }, { layout => 'admin' };
};

true;
