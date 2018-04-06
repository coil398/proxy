use strict;
use warnings;

use Socket;
use FileHandle;

my $request = <<'EOS';
GET /cgi-bin/cgi.pl HTTP/1.1
Host: localhost:8000
Connection: close
Accept: text/html; */*
EOS

my $line;
my $target_path;
my $target_address;
my @request = split(/\n/, $request);
foreach $line (@request) {
    if(($line =~ /GET/) or ($line =~ /POST/)){
        print "$line\n";
        $target_path = (split(/ /, $line))[1];
    }
    elsif($line =~ /Host/){
        print "$line\n";
        $target_address = (split(/ /, $line))[1];
    }
}

my $target_port;

if($target_address =~ /:/){
    ($target_address, $target_port) = split(/:/, $target_address, 2);
}
else{
    $target_port = 80;
}

my $socket;
my $response;

print "$target_address\n";
print "$target_port\n";

# get an ip address from a url.
my $target_ip = inet_aton($target_address) or die "can not connect to $target_address";
my $target_ip_string = inet_ntoa($target_ip);
my $sock_address = pack_sockaddr_in($target_port, $target_ip);

print "$target_ip_string\n";
print "$sock_address\n";

socket($socket, PF_INET, SOCK_STREAM, getprotobyname('tcp')) or die "can not create a coket on $target_address";

print "socket created.\n";

connect($socket, $sock_address) or die "can not connect a socket on $sock_address";

print "socket connected to $sock_address.\n";

print "\n";

autoflush $socket (1);

print "target_path: $target_path\n";
print "Host: $target_address\n";

print $socket "GET $target_path HTTP/1.1\n";
print $socket "Host: $target_address\n";
print $socket "Connection: close\n";
print $socket "Accept: text/html; */*\n";
print $socket "\n";


while ($response = <$socket>) {
    print $response;
}

close ($socket);
