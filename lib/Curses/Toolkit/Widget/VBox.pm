package Curses::Toolkit::Widget::VBox;

use warnings;
use strict;

use parent qw(Curses::Toolkit::Widget::Container);

use Params::Validate qw(:all);

=head1 NAME

Curses::Toolkit::Widget::VBox - a vertical box widget

=head1 DESCRIPTION

This widget can contain 0 or more widgets. The children are packed vertically.

=cut

=head1 CONSTRUCTOR

=head2 new

  input : none
  output : a Curses::Toolkit::Widget::VBox

=cut

=head1 METHODS

=head2 pack_start

Add a widget in the vertical box, at the start of the box. You can call
pack_start multiple time to add more widgets.

  input  : the child widget
           optionally, a hash containing options
  output : the current widget (not the child widget)

The hash containing options can contain :

  expand : TRUE if the new child is to be given extra space allocated to box.
  The extra space will be divided evenly between all children of box that use
  this option

  fill : TRUE if space given to child by the expand option is actually
  allocated to child, rather than just padding it. This parameter has no effect
  if expand is set to FALSE. A child is always allocated the full height of a
  GtkHBox and the full width of a GtkVBox. This option affects the other
  dimension

  padding : extra space in pixels to put between this child and its neighbors,
  over and above the global amount specified by "spacing" property. If child is
  a widget at one of the reference ends of box, then padding pixels are also
  put between child and the reference edge of box

=cut

sub pack_start {
	my $self = shift;
    my ($child_widget, $options) = validate( @_,
								   {
									{ isa => 'Curses::Toolkit::Widget' },
									{ type => HASHREF, default => {} },
								   }
								 );
	my %options = validate( $options, { expand  => { type => BOOLEAN, default => 0, can => [ 0, 1] },
										fill    => { type => BOOLEAN, default => 0, can => [ 0, 1] },
										padding => { type => INTEGER, default => 0, regex => qr/^\d+$/ },
									  }
						  );
	$child_widget->{properties}{pack}
	$self->_add_child($child_widget);
	$child->set_property(packing => \%options);
	return $self;
}

# overload _add_child from Container to pack at start

sub _add_child {
	my ($self, $child) = @_;
	unshift @{$self->{children}}, $child_widget;
	return;
}

sub {
}

1;
