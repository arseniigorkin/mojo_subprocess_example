package MyApp::Controller::Test;
use base "MyApp::Controller";
use strict;
use Mojo::Base -strict, -signatures, -async_await;
use Mojo::IOLoop::Subprocess;
use Mojo::Promise;
use Data::Show;

async sub testMehod{

    $c->render_later;
    my $start_timer1 = Time::HiRes::gettimeofday();

    my @promises;

    my @looper = (0..5); # Store here you parameters for each subprocess. Now it are just numbers.
    
    foreach my $lp (@looper){
        
        my $subprocess = Mojo::IOLoop::Subprocess->new;
            
            push @promises, $subprocess->run_p(
            
                sub {
                    # now we can use $lp
                    my $sp = shift; # $subprocess
                    
                    say "Hello, from $i and $$!";
                    sleep 2;
                    say "Goodbye, from $i and $$!";
                    return "Done for $i";
                }
            )->then(sub ($_result) {
                show $_result;
                return $_result;
            })->catch(sub  {
                my $err = shift;
                say "Subprocess error: $err";
            });
      
        $subprocess->ioloop->start unless $subprocess->ioloop->is_running;
    }


    my @results = await Mojo::Promise->all_settled(@promises); 
    show @results;
    # Process these results. You can use loops for it (foreach, for example).

    my $stop_timer1 = Time::HiRes::gettimeofday();
    my $total1 = sprintf("%.5f\n", $stop_timer1 - $start_timer1);

    return $c->render(text => "All done. Parallel: within $total1", status => 405);
}
