#!perl -T
use strict;
use warnings;
use Test::More tests => 9;
use Hatena::API::Auth;

my $api = Hatena::API::Auth->new({
    api_key => 'test',
    secret  => 'hoge',
});

is '8d03c299aa049c9e47e4f99e03f2df53', $api->api_sig({ api_key => 'test' });
is 'http://auth.hatena.ne.jp/auth?api_key=test&api_sig=8d03c299aa049c9e47e4f99e03f2df53', $api->uri_to_login;

ok not $api->login('invalidfrob');
like $api->errstr, qr/Invalid API key/;

{
    # hacking for testing
    no warnings;
    *Hatena::API::Auth::_get_auth_as_json = sub {
        return <<EOF;
{
  status : true,
  user : {
    name : "naoya",
    image_url : "http://www.hatena.ne.jp/users/na/naoya/profile.gif",
    thumbnail_url : "http://www.hatena.ne.jp/users/na/naoya/profile_s.gif" 
  }
}
EOF
    };
}

my $user = $api->login("dummy_frob");
ok ref($user);
is ref($user), 'Hatena::API::Auth::User';
is $user->name, 'naoya';
is $user->image_url, 'http://www.hatena.ne.jp/users/na/naoya/profile.gif';
is $user->thumbnail_url, 'http://www.hatena.ne.jp/users/na/naoya/profile_s.gif';

1;
