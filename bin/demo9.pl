#!/usr/bin/perl

use strict;
use warnings;

use lib qw(../lib);
main() unless caller;

sub main {

	use POE::Component::Curses;
#	use Curses::Toolkit;
	use Curses::Toolkit::Widget::Window;
	use Curses::Toolkit::Widget::Border;
	use Curses::Toolkit::Widget::Label;
	use Curses::Toolkit::Widget::VBox;
	use Curses::Toolkit::Widget::HBox;
	use Curses::Toolkit::Widget::Button;

	my $root = POE::Component::Curses->spawn();

#	my $root = Curses::Toolkit->init_root_window();

	local $| = 1;
	print STDERR "\n\n\n--- starting demo9 -----------------\n\n";

	my $button02;
	$root->add_window(
        Curses::Toolkit::Widget::Window->new()
          ->add_widget(
            Curses::Toolkit::Widget::Border->new()
              ->add_widget(
            Curses::Toolkit::Widget::Border->new() # space
              ->set_visible(0)
              ->add_widget(
                Curses::Toolkit::Widget::VBox->new()
                  ->pack_end(
 				    Curses::Toolkit::Widget::HBox->new()
 					  ->pack_end(
			            my $button01 = Curses::Toolkit::Widget::Button
				          ->new_with_label('This button is focused !')
				          ->set_name('button1'),
				       { expand => 1 }
  					  )

 					  ->pack_end(
 			            $button02 = Curses::Toolkit::Widget::Button
 				          ->new_with_label('This button is not focused !')
 				          ->set_name('button2')
->add_event_listener(
		Curses::Toolkit::EventListener->new(
			accepted_event_class => 'Curses::Toolkit::Event::Mouse::Click',
			conditional_code => sub { 
				my ($event) = @_;
				$event->{button} eq 'button1' or return 0;
				$event->{type} eq 'pressed' or return 0;
			},
			code => sub {
				$button02->set_focus(1);
			},
		)
	),
				       { expand => 1 }
 					  ),

				       { expand => 0 }
				  )
                  ->pack_end(
                     Curses::Toolkit::Widget::Border->new()
                       ->add_widget(
                         Curses::Toolkit::Widget::Label->new()
                           ->set_text('expanding border with a label (this text) in it')
					   ),
				       { expand => 1 }
				  )
                  ->pack_end(
 				    Curses::Toolkit::Widget::HBox->new()
 					  ->pack_end(
			            my $button1 = Curses::Toolkit::Widget::Button
				          ->new_with_label('This button is focused !')
				          ->set_name('button1'),
				       { expand => 0 }
  					  )

 					  ->pack_end(
 			            my $button2 = Curses::Toolkit::Widget::Button
 				          ->new_with_label('This button is not focused !')
 				          ->set_name('button2'),
				       { expand => 0 }
 					  ),

				       { expand => 0 }
				  )
			  )
              )
		  )
          ->set_coordinates(x1 => 0,   y1 => 0,
                            x2 => '100%',
							y2 => '100%',
						   )
      );
	$button1->set_focus(1);
#	$button1->register_event( type => keyboard

#$root
#      ->render()
#      ->display();
#sleep 5;
	POE::Kernel->run();
}

