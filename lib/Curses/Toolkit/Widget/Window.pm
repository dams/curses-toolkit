package Curses::Toolkit::Widget::Window;

use warnings;
use strict;

use parent qw(Curses::Toolkit::Widget::Border);

use Params::Validate qw(:all);

use List::MoreUtils qw(any none);

=head1 NAME

Curses::Toolkit::Widget::Window - a window

=head1 DESCRIPTION

This is a window widget

=head1 CONSTRUCTOR

=head2 new

  input : none
  output : a Curses::Toolkit::Widget::Window

=cut

sub new {
	my $class = shift;
	my $self = $class->SUPER::new(@_);
	# set window stack by default
	$self->set_property(window => stack => -1);
	# set_default title
	$self->set_title('');
	$self->set_type('normal');
#	$self->set_focused_widget($self);
	return $self;
}

=head2 set_title

Set the title of the window

  input  : the title
  output : the window widget

=cut

sub set_title {
	my $self = shift;
	my ($title) = validate_pos( @_, { type => SCALAR,
									}
							  );
	$self->{title} = $title;
	return $self;
}

=head2 get_title

Get the title of the window

  input  : none
  output : the window title

=cut

sub get_title {
	my ($self) = @_;
	return $self->{title};
}

=head2 set_coordinates

Set the coordinates (see L<Curses::Toolkit::Object::Coordinates> )

You can also set coordinates in percent of the root window width / height :

  input  : x1 : top left x (can be in percent ( ex : '42%' ) )
           y1 : top left y (can be in percent ( ex : '42%' ) )
           x2 : right bottom x (can be in percent ( ex : '42%' ) )
           y2 : right bottom y (can be in percent ( ex : '42%' ) )
    OR
  input  : x1 : top left x (can be in percent ( ex : '42%' ) )
           y1 : top left y (can be in percent ( ex : '42%' ) )
           width : width (can be in percent ( ex : '42%' ) )
           height : heigth (can be in percent ( ex : '42%' ) )
    OR
  input  : x1 : sub { ... } # returns top left x
           y1 : sub { ... } # returns top left y
           x2 : sub { ... } # returns right bottom x
           y2 : sub { ... } # returns right bottom y
    OR
  input  : a Curses::Toolkit::Object::Coordinates object

=cut

sub set_coordinates {
	my $self = shift;
	use Curses::Toolkit::Object::Coordinates;
	use Data::Dumper;
	if ( ! ref($_[0])) {
		my %params = @_;
		foreach my $x (qw(x1 x2)) {
			if ($params{$x} =~ /^(.+)%$/ ) {
				my $percent = $1;
				$params{$x} = sub { return $self->get_root_window()
									  ? $self->get_root_window()->get_shape()->width() * $percent / 100
									  : 0;
								   };
			}
		}
		foreach my $y (qw(y1 y2)) {
			if ($params{$y} =~ /^(.+)%$/ ) {
				my $percent = $1;
				$params{$y} = sub { return $self->get_root_window()
									  ? $self->get_root_window()->get_shape()->height() * $percent / 100
								      : 0;
								  };
			}
		}
		if (defined $params{width} && $params{width} =~ /^(.+)%$/ ) {
			my $percent = $1;
			$params{x2} = sub {
				my ($coord) = @_;
				$coord->x1() + ($self->get_root_window() and $self->get_root_window()->get_shape()->width() * $percent / 100);
			};
			delete $params{width};
		}
		if (defined $params{height} && $params{height} =~ /^(.+)%$/ ) {
			my $percent = $1;
			$params{y2} = sub {
				my ($coord) = @_;
				$coord->y1() + ($self->get_root_window() and $self->get_root_window()->get_shape()->height() * $percent / 100);
			};
			delete $params{height};
		}
		$self->{coordinates} = Curses::Toolkit::Object::Coordinates->new(%params);
	} else {
		$self->{coordinates} = Curses::Toolkit::Object::Coordinates->new(@_);
	}
	$self->_set_relatives_coordinates($self->{coordinates});
	# needs to take care of rebuilding coordinates from top to bottom
	$self->rebuild_all_coordinates();
	return $self;
}

=head2 set_root_window

Sets the root window ( the root toolkit object) to which this window is added 

  input  : the root toolkit object (Curses::Toolkit)
  output : the window

=cut

sub set_root_window {
	my ($self, $root_window) = @_;
	$self->{root_window} = $root_window;
	return $self;
}

=head2 get_root_window

Get the root window

  input  : none
  output : the root toolkit object (Curses::Toolkit)

=cut

sub get_root_window {
	my ($self) = @_;
	return $self->{root_window};
}

=head2 set_focused_widget

  $window->set_focused_widget($widget);

Set the widget that has focus.

  input : a Curses::Toolkit::Widget that is into this window
  output : the window

=cut

sub set_focused_widget {
	my $self = shift;
	my ($widget) = validate_pos( @_, { isa => 'Curses::Toolkit::Widget',
									   callbacks => { 'must be focusable' => sub { $_[0]->isa('Curses::Toolkit::Role::Focusable') }
													}
									 } );
	my $current_focused_widget = $self->get_focused_widget();
	if (defined $current_focused_widget && $current_focused_widget->can('set_focus')) {
		$current_focused_widget->set_focus(0);
	}
	$self->{focused_widget} = $widget;
	return $self;
}

=head2 get_focused_widget

  my $widget = $window->get_focused_widget();

Gets the focused widget.

  input : none
  output : the focused Curses::Toolkit::Widget

=cut

sub get_focused_widget {
	my ($self) = @_;
	my $focused_widget = $self->{focused_widget};
	if (defined $focused_widget && $focused_widget->can('is_focused') && $focused_widget->is_focused()) {
		return $self->{focused_widget};
	}
	return;
}

sub draw {
	my ($self) = @_;
	my $theme = $self->get_theme();
	my $c = $self->get_coordinates();
	$theme->draw_hline($c->x1(), $c->y1(), $c->width());

	my $title = $self->get_title();
	if (length $title) {
		$theme->draw_string($c->x1(), $c->y1(), $self->get_title());
	}

	$theme->draw_hline($c->x1(), $c->y2() - 1, $c->width());
	$theme->draw_vline($c->x1(), $c->y1(), $c->height());
	$theme->draw_vline($c->x2() - 1, $c->y1(), $c->height());
	$theme->draw_corner_ul($c->x1(), $c->y1());
	$theme->draw_corner_ll($c->x1(), $c->y2() - 1);
	$theme->draw_corner_ur($c->x2() - 1, $c->y1());
	$theme->draw_corner_lr($c->x2() - 1, $c->y2() - 1);
}

=head2 set_type

Set the type of the window. Default is 'normal'.
Can be : 

  input  : SCALAR : the type, one of 'normal', 'invisible', 'left_title', 'right_title'
  output : the window widget

=cut

my @possible_types = qw( normal invisible menu );
sub set_type {
	my $self = shift;
	my ($type) = validate_pos( @_, { type => SCALAR,
									 callbacks => { "one of @possible_types" => sub {
														any { $_[0] eq $_ } @possible_types;
													}
												  }
								   } );

	$self->{type} = $type;
	return $self;
}

=head2 get_type

Get the type of the window

  input : none
  output : the type

=cut

sub get_type {
	my ($self) = @_;
	return $self->{type};
}

=head1 Theme related properties

To set/get a theme properties, you should do :

$window->set_theme_property(property_name => $property_value);
$value = $window->get_theme_property('property_name')

Here is the list of properties related to the window, that can be changed in
the associated theme. See the Curses::Toolkit::Theme class used for the default
(default class to look at is Curses::Toolkit::Theme::Default)

=head2 title_width

The width (or the height if the title is displayed vertically) of the window
that will be use to display the title, in percent.

Example :
  # the title can take up to 80% of the windows border
  $window->set_theme_property(title_width => 80 );

=head2 title_position

Can be 'top', 'bottom', 'left', 'right', sets the position of the title on the window border
Example :
  # The title will appear on the left
  $window->set_theme_property(title_position => 'left');

=head2 title_brackets_characters

An ARRAYREF of 2 strings (usually 1 character long), the first one is displayed
before the title, the second one is used after the title.

Example :
  # The title will appear <like that>
  $window->set_theme_property(title_brackets_characters => [ '<', '>' ]);

=cut

my @title_positions = qw(top bottom left right);

sub _get_theme_properties_definition {
	my ($self) = @_;
	return { %{$self->SUPER::_get_theme_properties_definition() },
			 title_width => {
			   optional => 1,
			   callbacks => { "should be between 0 and 100 (percent)" => sub {
								  $_[0] <= 100 && $_[0] >= 0;
							  }
							}			    
			 },
			 title_position => {
			   optional => 1,
			   callbacks => { "should be one of @title_positions" => sub {
								  any { $_[0] eq $_ } @title_positions;
							  }
							}
			 },
			 title_brackets_characters => {
			   optional => 1,
			   type => 'ARRAY',
			   callbacks => { "should contain 2 strings" => sub {
								  @{$_->[0]} == 2 && none { ref } @{$_->[0]};
							  }
							}
			 },
		   }
}

1;
