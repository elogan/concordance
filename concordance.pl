#!/usr/bin/env perl

# always use protection
use warnings;
use strict;

# tracking vars
my %words;
my $sentence = 1;
my $maybe = 0;
my $debug = 0;

while (<>) { # We read from STDIN
    for my $token (split /\s/, $_) { # split on whitespace so e.g. 'i.e.' is a single word
        # A new sentence consists of an end-of-sentence character (one of .!?) followed by two spaces, a capital letter, quotation mark or a newline
        # The '' case covers a period followed by two spaces
        # This rule isn't exhaustive but covers most cases.
        if ($maybe && ($token eq '' || $token =~ /^[A-Z"'\n]/)) {
            print "*** New sentence\n" if $debug;
            $sentence++;
            $maybe = 0; # Don't double count
        }
        print "** found '$token' in sentence $sentence\n" if $debug;
        if ($token =~ /[\.\!\?]/) { # there are only three punctuation marks that end a sentence
            print "*** maybe end of sentence\n" if $debug;
            $maybe = 1;
        } else {
            $maybe = 0;
        }
        $token =~ tr/A-Z/a-z/; # lowercase the token
        # Destroy punctuation unless the token has some inside.  Ensures (e.g.) 'i.e.' is kept as a whole token
        $token =~ s/[[:punct:]]//g unless $token =~ /[a-z][[:punct:]][a-z]/;
        # On the other hand, these punctuation marks should be stripped always
        $token =~ s/["',:;\(\)\[\]]//g; 
        next unless $token; # It may be our token is nothing, in which case we can get on with our lives
        # There's no need to count occurrences directly, we can just count the length of the occurrence list
        # Essentially, we keep a list of sentence numbers where the word occurs
        if ($words{$token}) { # Can't coerce perl into calling undef an array reference...
            push $words{$token}, $sentence;
        } else {              # ... so make one if we have to
            $words{$token} = [$sentence];
        }
    }
}

print "@@@\n" if $debug;
for (sort keys %words) { # Print the list in alphabetical order
    print "$_ {", scalar @{$words{$_}},":";
    print join ',', @{$words{$_}};
    print "}\n";
}
