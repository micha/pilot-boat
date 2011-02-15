#!/usr/bin/env perl

use Text::Template;
use File::Basename;
use Data::Dumper;

my $PROG  = basename($0);
my $DIR   = $ARGV[0];

our %wb = ();
our %q;
our $sections;

sub usage() {
  my $zero = basename($0);
  my $usage = <<_USAGE_
Usage: $zero <directory>
_USAGE_
}

sub p0() {
  return sprintf("%.0f", $_[0]);
}

sub p1() {
  return sprintf("%.1f", $_[0]);
}

sub p2() {
  return sprintf("%.2f", $_[0]);
}

sub p3() {
  return sprintf("%.3f", $_[0]);
}

sub err() {
  return basename($0).": ".$_[0]."\n";
}

sub do_tmpl() {
  my $t = Text::Template->new(
    TYPE        =>  'FILE',
    SOURCE      =>  $_[0],
    DELIMITERS  =>  ['[@--', '--@]']
  );

  $t->fill_in;
}

sub slurp() {
  open(F, "< ".$_[0]) or die &err("can't open file '".$_[0]."': $!");
  my @f = <F>;
  join("", @f);
}

eval(&slurp("calcs.pl"));
die $@ if $@;

my $dir = "sections";
opendir(D, $dir) or die &err("can't open dir 'sections': $!");
my @d = map { "$dir/$_" } sort(grep(/\.tmpl$/, grep(!/^\./, readdir(D))));
closedir(D) or die &err("can't close dir 'sections': $!");

foreach (@d) {
  /^(.*)\.tmpl$/;
  if (! -f "$1.tex") {
    open(F, "> $1.tex") or die &err("can't write to '$1.tex': $!");
    print(F &do_tmpl($_));
    close(F) or die &err("can't close '$1.tex': $!");
  }
  $sections .= &slurp("$1.tex")."\n";
}

#$sections = join("\n", map { &do_tmpl($_) } @d);
print &do_tmpl("index.tmpl");

__END__

sub file_tree() {
  my @D = @{$_[0]};
  my $d = join("/", @D);

  opendir(DIR, $d) or die &err("can't open directory '$d': $!");
  my @f = grep(!/^[\.]/, readdir(DIR));
  closedir(DIR) or die &err("can't close directory '$d': $!");

  my %h = map { +"$d/$_" => (-d "$d/$_" ? &file_tree([@D, $_]) : 1) } @f;
  return \%h;
}

sub do_tmpl() {
  my $t = Text::Template->new(
    TYPE=>'FILE', SOURCE=>$ARGV[0], DELIMITERS=>['[@--', '--@]']);

  my $text = $t->fill_in;

  print $text;
}
