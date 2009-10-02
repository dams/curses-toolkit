#!/usr/bin/perl

use strict;
use warnings;

use lib qw(../lib);
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


	my $menu_window = Curses::Toolkit::Widget::Window->new();
	$menu_window->set_title("Demo Menu");
	$menu_window->set_coordinates(x1 => 0, y1 => 0,
								  x2 => '25%', y2 => '100%',
								 );
	my $menu_vbox = Curses::Toolkit::Widget::VBox->new();
	$menu_window->add_widget($menu_vbox);

	my @spawned_windows;
	my $current_pane;
	my $switch_pane = 0;
	my $b1 = Curses::Toolkit::Widget::Button->new_with_label('spawn a window');
	$menu_vbox->pack_end($b1, { expand => 0 });
	$b1->signal_connect(clicked => sub {
							my $w = Curses::Toolkit::Widget::Window->new()
							  ->set_title("Spawned window n." . scalar @spawned_windows + 1);
							my $hp = Curses::Toolkit::Widget::HPaned->new();
							$hp->set_gutter_position(10);
							$w->add_widget($hp);
							$hp->add1(Curses::Toolkit::Widget::Label->new()
									  ->set_text('This is a naive label. Very naive')
									 );
 							$hp->add2(	my $vb = Curses::Toolkit::Widget::VBox->new()
										->pack_end(
												   Curses::Toolkit::Widget::Label->new()
												   ->set_text('An other nonetheless naive label.Honest !'),
												   { expand => 0 }
												  )
 									 );
							$current_pane = $vb;

							my $s = scalar(@spawned_windows) * 2;
							push @spawned_windows, $w;
							$w->set_coordinates(x1 => 30 + $s, y1 => 5 + $s,
												x2 => 70 + $s, y2 => 20 + $s,
											   );
							$root->add_window($w);
							$w->set_theme_property(title_width => 80 );

						});

	my $theme_switch = 1;
	my $b2 = Curses::Toolkit::Widget::Button->new_with_label('change themes');
	$menu_vbox->pack_end($b2, { expand => 0 });
	$b2->signal_connect(clicked => sub {
							foreach my $w (@spawned_windows) {
								$w->{theme} = $theme_switch ? Curses::Toolkit::Theme::Default::Color::Pink->new($w)
								                            : Curses::Toolkit::Theme::Default->new($w);
								$w->set_theme_property(title_width => 80 );
							}
							$theme_switch = !$theme_switch;
							$root->needs_redraw();
						});
	my $b3 = Curses::Toolkit::Widget::Button->new_with_label('change themes 2');
	$menu_vbox->pack_end($b3, { expand => 0 });
	$b3->signal_connect(clicked => sub {
							foreach my $w (@spawned_windows) {
								$w->{theme} = $theme_switch ? Curses::Toolkit::Theme::Default::Color::Pink->new($w)
								                            : Curses::Toolkit::Theme::Default->new($w);
								$w->set_theme_property(title_width => 80 );
								$theme_switch = !$theme_switch;
							}
							$root->needs_redraw();
						});

	my $b4 = Curses::Toolkit::Widget::Button->new_with_label('Add a Pane');
	$menu_vbox->pack_end($b4, { expand => 0 });
	$b4->signal_connect(clicked => sub {
							defined $current_pane or return;
							my $pane = $switch_pane ? Curses::Toolkit::Widget::HPaned->new()
							                      : Curses::Toolkit::Widget::VPaned->new();
							$pane->set_gutter_position( $switch_pane ? 7 : 2);
							$current_pane->pack_end(
													$pane,
													{ expand => 0 }
												   );
							$pane->add1(Curses::Toolkit::Widget::Label->new()
									  ->set_text('This is a naive label. Very naive')
									 );
							$pane->add2(my $box = ($switch_pane ? Curses::Toolkit::Widget::VBox->new()
										                       : Curses::Toolkit::Widget::HBox->new())

									 );
							$current_pane = $box;
							$switch_pane = !$switch_pane;

						});


	my $b5 = Curses::Toolkit::Widget::Button->new_with_label('spawn dialog');
	$menu_vbox->pack_end($b5, { expand => 0 });
	$b5->signal_connect(clicked => sub {
							my $w = Curses::Toolkit::Widget::Window->new()
							  ->set_title("Spawned window n." . scalar @spawned_windows + 1)
							  ->add_widget(
							    Curses::Toolkit::Widget::VBox->new()
								->pack_end(
								  my $e = Curses::Toolkit::Widget::Entry->new(),
										   { expand => 0 },
										  )
                                ->pack_end(
								  my $b = Curses::Toolkit::Widget::Button->new_with_label(' Click me !'),
										   { expand => 0 },
										  )
								->pack_end(
								  Curses::Toolkit::Widget::Label->new()->set_text(' '),
										   { expand => 0 },
										  )										   
								->pack_end(
								  Curses::Toolkit::Widget::Label->new()->set_text(' '),
										   { expand => 0 },
										  )										   
								->pack_end(
								  my $l = Curses::Toolkit::Widget::Label->new()
									  ->set_text("I'll be displaying things here"),
										   { expand => 0 },
										  )										   
							  );
							my $s = scalar(@spawned_windows) * 2;
							push @spawned_windows, $w;
							$w->set_coordinates(x1 => 30 + $s, y1 => 5 + $s,
												x2 => 70 + $s, y2 => 20 + $s,
											   );
							$root->add_window($w);
							$w->set_theme_property(title_width => 80 );

							$b->signal_connect(clicked => sub {
												   my $t = $e->get_text();
												   $t = uc($t);
												   $l->set_text("You entered this: $t");
												   $root->needs_redraw();
											   });
						});

	my $b6 = Curses::Toolkit::Widget::Button->new_with_label('spawn boxes');
	$menu_vbox->pack_end($b6, { expand => 0 });
	$b6->signal_connect(clicked => sub {

        my $w = Curses::Toolkit::Widget::Window
          ->new()
          ->set_name('main_window')
			->set_title("Spawned window n." . scalar @spawned_windows + 1)
          ->add_widget(
                my $vbox1 = Curses::Toolkit::Widget::VBox->new()
                  ->pack_end(
                     my $border2 = Curses::Toolkit::Widget::Border
                       ->new()
                       ->set_name('border2')
                       ->add_widget(
                         my $label1 = Curses::Toolkit::Widget::Label
                         ->new()
                         ->set_name('label1')
                         ->set_text('non-expanding border but a long label that hopefully wraps')
                       )
                  )
                  ->pack_end(
#                      my $border3 = Curses::Toolkit::Widget::Border
#                        ->new()
#                        ->set_name('border3')
#                        ->add_widget(
						 my $hbox1 = Curses::Toolkit::Widget::HBox
                           ->new()
                           ->set_name('hbox1')
						   ->pack_end(
                             my $border4 = Curses::Toolkit::Widget::Border
                               ->new()
                               ->set_name('border4')
                               ->add_widget(
							     my $label3 = Curses::Toolkit::Widget::Label
								   ->new()
                                   ->set_name('label3')
                                   ->set_text('expanding border')
							   ),
							   { expand => 1 }
                           )
						   ->pack_end(
                             my $border5 = Curses::Toolkit::Widget::Border
                               ->new()
                               ->set_name('border5')
                               ->add_widget(
							     my $label4 = Curses::Toolkit::Widget::Label
								   ->new()
                                   ->set_name('label4')
                                   ->set_text('expanding border')
							   ),
							 { expand => 1 }
						   ),
						 { expand => 1 }
#                       ),
                  )
				  ->pack_end(
                    my $border6 = Curses::Toolkit::Widget::Border
                      ->new()
                      ->set_name('border6')
                      ->add_widget(
                        my $label5 = Curses::Toolkit::Widget::Label
                          ->new()
                          ->set_name('label5')
                          ->set_text('expanding border')
                      ),
				      { expand => 1 }
                  )
				  ->pack_end(
                    my $border7 = Curses::Toolkit::Widget::Border
                      ->new()
                      ->set_name('border7')
                      ->add_widget(
                        my $label6 = Curses::Toolkit::Widget::Label
                          ->new()
                          ->set_name('label6')
                          ->set_text('non expanding border')
                      ),
                  )
          );

							my $s = scalar(@spawned_windows) * 2;
							push @spawned_windows, $w;
							$w->set_coordinates(x1 => 30 + $s, y1 => 5 + $s,
												x2 => 70 + $s, y2 => 20 + $s,
											   );
							$root->add_window($w);
							$w->set_theme_property(title_width => 30 );

						});

	$root->add_window($menu_window);


# 	my $button4 = Curses::Toolkit::Widget::Button->new_with_label('This is a button 4');
# 	$window2->add_widget(
# 		my $vbox = Curses::Toolkit::Widget::VBox->new()
# 		  ->pack_end($button3, { expand => 0 })
# #		  ->pack_end($button4, { expand => 0 })
# 	);
# 	$window2->set_coordinates(x1 => '15%',   y1 => '15%',
# 							 x2 => '85%',
# 							 y2 => '85%',
# 							);
# 	$button3->set_focus(1);
	$menu_window->set_theme_property(title_width => 90 );
	POE::Kernel->run();
}
