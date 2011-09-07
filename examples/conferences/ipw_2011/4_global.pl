#!/usr/bin/env perl

use strict;
use warnings;

use lib qw(../../../lib);

open STDERR, '>>/dev/null';

main() unless caller;

sub main {

	use POE::Component::Curses;

	use Curses::Toolkit::Widget::Window;
	use Curses::Toolkit::Widget::VBox;
	use Curses::Toolkit::Widget::HBox;
	use Curses::Toolkit::Widget::Button;
	use Curses::Toolkit::Widget::Border;
	use Curses::Toolkit::Widget::Entry;
	use Curses::Toolkit::Widget::HPaned;
	use Curses::Toolkit::Widget::VPaned;
	use Curses::Toolkit::Widget::Label;

	my $root = POE::Component::Curses->spawn();

    {

	my $window;
	$root->add_window( $window = Curses::Toolkit::Widget::Window->new()->set_name('window')->set_title("title 1") );

	my $label = Curses::Toolkit::Widget::Label->new->set_text(
		"This is <span weight='underline'>underlined text <span weight='bold'>underlined + bold</span> chunk </span> chunk"
	);
	my $label2 = Curses::Toolkit::Widget::Label->new->set_text(
		"This is <span fgcolor='black'>in black, <span bgcolor='red'>red background </span> and black again</span> chunk");
	my $label3 = Curses::Toolkit::Widget::Label->new->set_text(
		"This is a <span weight='bold'>bold <span weight='normal'>then normal</span> then back to bold</span> chunk");
	$window->add_widget( my $vbox =
			Curses::Toolkit::Widget::VBox->new()->pack_end( $label, { expand => 0 } )
			->pack_end( $label2, { expand => 0 } )->pack_end( $label3, { expand => 0 } ) );
	$window->set_coordinates(
		x1 => '15%', y1 => '55%',
		x2 => '85%',
		y2 => '85%',
	);

    }


	my $window2;
	$root->add_window( $window2 = Curses::Toolkit::Widget::Window->new()->set_name('window2')->set_title("title 2") );

	my $hpaned = Curses::Toolkit::Widget::HPaned->new();
	$hpaned->set_name('hpaned'), $hpaned->set_gutter_position(35);
	$window2->add_widget($hpaned);
	my $vpaned = Curses::Toolkit::Widget::VPaned->new();
	$vpaned->set_name('vpaned'), $vpaned->set_gutter_position(4);

	my $label_void1 = Curses::Toolkit::Widget::Label->new->set_text(' ');
	my $label_void2 = Curses::Toolkit::Widget::Label->new->set_text(' ');
	my $label1 = Curses::Toolkit::Widget::Label->new->set_text(' ');
	my $label2 = Curses::Toolkit::Widget::Label->new->set_text('You entered in the entry :');
	my $entry =
		Curses::Toolkit::Widget::Entry->new()->signal_connect( focus_changed => \&focus_changed, $label1 )
		->signal_connect( content_changed => \&content_changed, $label2 );

sub focus_changed {
	my ( $event, $widget, $label ) = @_;
	my $focus = $event->isa('Curses::Toolkit::Event::Focus::In') ? 'in' : 'out';
	$label->set_text("you just focused $focus of the entry");
	return;
}

sub content_changed {
	my ( $event, $widget, $label ) = @_;
	$label->set_text( "Entry changed : [" . $widget->get_text . "]" );
	return;
}


	$hpaned->add1(
        Curses::Toolkit::Widget::VBox->new()->pack_end(
			Curses::Toolkit::Widget::Label->new()->set_wrap_mode('never')->set_text("Please enter your name"),
			{ expand => 0 }
			)->pack_end(
			$entry,
			{ expand => 0 }
			)->pack_end(
            $label_void1,
			{ expand => 1 }
			)->pack_end(
			$label2,
			{ expand => 0 }
			)->pack_end(
            $label_void1,
			{ expand => 1 }
			)->pack_end(
			$label1,
			{ expand => 0 }
	        )
    );
	$hpaned->add2(
		$vpaned->add1(
			Curses::Toolkit::Widget::Label->new()->set_text('An other label')
				->set_name('label2'),
			)->add2(
			Curses::Toolkit::Widget::VBox->new()
                ->pack_end( Curses::Toolkit::Widget::Label->new()->set_text('What ?! yet another Label ?!')->set_justify('center'), { expand => 1 } )
                ->pack_end( Curses::Toolkit::Widget::HBox->new()->pack_end(Curses::Toolkit::Widget::Button->new_with_label('A Button'), { expand => 1 }), { expand => 0 } )
			)
	);
	$window2->set_coordinates(
		x1 => '5%', y1 => '5%',
		x2 => '95%',
		y2 => '40%',
	);

	POE::Kernel->run();
}
