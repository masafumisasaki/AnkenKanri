requires 'perl', '5.008005';
requires 'Mojolicious';
requires 'REST::Client';
requires 'URI::Escape';
requires 'JSON';
requires 'Encode';
requires 'Moo';
requires 'Path::Class';
requires 'Template';
requires 'Template::Provider::Encoding';
requires 'Time::Piece';
requires 'Time::Seconds';

# requires 'Some::Module', 'VERSION';

on test => sub {
    requires 'Test::More', '0.96';
};
